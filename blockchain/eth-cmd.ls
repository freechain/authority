require! {
  \ethereumjs-tx : \Tx
  \ethereumjs-util : \eth-util
  \fs : { read-file-sync, write-file-sync }
  \glob
  \solc
  \path
  \bignumber.js : BN
  \./config.json : { output-dir }
  \prelude-ls : { map, pairs-to-obj, obj-to-pairs, split, each }
  \./helpers/variables.js
  \./helpers/fix-spaces.js
  \./helpers/remove-doubled-solidity-version.js
  \./helpers/replace-all-imports-recursively.js
  \../services/get-token-keys.ls
  \./wallet.ls : { send-transaction, create-web3 }
}

resolve = (config, cb)->
    [_, input, output] = config.match(/resolve (.+) -> (.+)/)
    #console.log { input }
    inputFileContent = readFileSync fullPath(input), \utf8
    err, srcFiles <- glob variables.parentDir + \/**/*.sol
    variables.allSrcFiles = srcFiles
    return cb err if err?
    outputFileContent <- replaceAllImportsRecursively inputFileContent, variables.parentDir + \/
    outputFileContent = removeDoubledSolidityVersion(outputFileContent)
    outputFileContent = fixSpaces outputFileContent
    console.log '\nSize of a full source:', (outputFileContent.length / 1024).toFixed(4), 'KB'
    writeFileSync fullPath(output), outputFileContent
    console.log 'Success! Flat file is generated to ' + variables.outDir + ' directory'
    cb null
    
fullPath = (relativePath) ->
    #console.log relativePath
    path.resolve __dirname, relativePath

readFile = (filePath) ->
    readFileSync fullPath(filePath), \utf8


getContractBytecode = (contractName) ->
    readFile "#{outputDir}/#{contractName}.bytecode"

logBytecode = false

getContractAbi = (contractName) ->
  JSON.parse readFile "#{outputDir}/#{contractName}.abi.json"



injectLibsIntoBytecode = (bytecode, libs) ->
  Object.keys(libs).forEach (libName) ->
    regex = new RegExp("__:" + libName + "[_]+", \g)
    libAddr = libs[libName].replace \0x, ''
    bytecode := bytecode.replace regex, libAddr
  bytecode


deployContractWithLibs = (private-key, contractName, libs, cb) --> 
  console.log "\nDeploying a contract #{contractName}..."
  console.log "Libs:", libs if libs?
  
  bytecode = getContractBytecode contractName
  if logBytecode then console.log "\nBytecode of #{contractName}:\n#{bytecode}\n"
  if libs?
    bytecode = injectLibsIntoBytecode bytecode, libs
    if logBytecode then console.log "\nBytecode of #{contractName} AFTER libs injected:\n#{bytecode}\n"
  data = "0x#{bytecode}"
    
  err, info <- send-transaction { data, private-key }
  cb err, info
 

deploy = (context, name, libs, cb)->
  console.log "deploy", name, libs
  web3 = create-web3 context.private-key
  err, res <- deployContractWithLibs context.private-key, name, libs
  return cb err if err?
  return cb "Cannot find contractAddress" if not res.contractAddress?
  instance = new web3.eth.Contract getContractAbi(name), res.contract-address
  console.log "#{name} deployed at address:", res.contractAddress
  instance.private-key = context.private-key
  instance.contract-address = res.contract-address
  cb null, instance

export to-addr = obj-to-pairs >> (map -> [it.0, it.1.address]) >> pairs-to-obj

get-config = (config)->
    console.log \deploy, config
    [_, name, lib-str] = config.match(/^deploy (.+) libs: (.+)$/) ? config.match(/^deploy (.+)$/)
    get-libs = | lib-str? => (split ",") >> map (.trim!)
               | _ => -> it
    libs = get-libs lib-str
    #console.log name, libs
    { name, libs }
    
apply-libs = (libs, context, cb)->
  return cb null if not libs?
  return cb "Parents cannot be empty" if not context?
  return cb "libs is not an array" if typeof! libs isnt \Array
  libs |> map -> [it, context[it].address]
       |> pairs-to-obj
       |> cb null, _
  
deploy-contract = (config, context, cb)->
  { name, libs } = get-config config
  err, applied-libs <- apply-libs libs, context
  return cb err if err?
  err, contract <- deploy context, name , applied-libs
  context[name] = contract
  return cb err if err?
  result = [name, contract]
  cb null, result

run-action = (config, context, cb)->
    
    [_, invoke, arg-str] = config.match /invoke (.+) (.+)/

    [contract, method] = invoke.split \.
    
    transform-arg = (arg)->
        res = arg.match(/^(.+)\.address$/) 
        return context[res.1].address if res?
        arg
    args = arg-str |>  split \, 
                   |> map transform-arg
    data = context[contract][method].get-data(args)
    { private-key, contract-address } = context[contract]
    console.log "Contract #{contract-address} #{contract}.#{method}(#{args.map(JSON.stringify).join(',')})"
    to = contract-address
    err, info <- send-transaction { data, private-key, to }
    cb err, info
    
compile = (config, cb)->
  [_, outputSourcePath, contracts] = config.match /^compile (.+) -> (.+)$/
  solcVersion = solc.version!
  console.log "Using solc version", solcVersion

  # fullSource = tpl.build baseContractName, contractParams
  fullSource = readFileSync fullPath(outputSourcePath), \utf8
  
  console.log 'Start to compile smart contracts...'
  compiledOutput = solc.compile(fullSource, 1) # 1 activates the optimiser
  console.log 'Done: smart contracts compiled'
  
  saveCompiledContract = (name) ->
    compiledContract = compiledOutput.contracts[":#{name}"]
    throw "Contract #{name} is not compiled" if not compiledContract?
    writeFileSync fullPath("#{outputDir}/#{name}.bytecode"), compiledContract.bytecode
    writeFileSync fullPath("#{outputDir}/#{name}.abi.json"), compiledContract.interface

  contracts |> split \, 
            |> map (.trim!) 
            |> each saveCompiledContract
  cb null


export-addresses = (config, context, cb)->
  path = config.replace('export addresses ','')
  addresses =
    context |> obj-to-pairs
            |> map -> [it.0, it.1.contract-address]
            |> pairs-to-obj
  #console.log path, addresses
  write-file-sync fullPath(path), JSON.stringify(addresses, null, 4)
  
  cb null

deploy-switch = (config, context, cb)->
  return export-addresses config, context, cb if typeof! config is \String and config.match(/^export addresses/)
  return compile config, cb if typeof! config is \String and config.match(/^compile/)
  return deploy-contract config, context, cb if typeof! config is \String and config.match(/^deploy/)
  return run-action config, context, cb if typeof! config is \String and config.match(/^invoke/)
  return resolve config, cb if typeof! config is \String and config.match(/^resolve/)
  cb null

saveToFile = (path, addresses) ->
    console.log "Export to file: #{path}"
    writeFileSync fullPath(path), JSON.stringify(addresses, null, 2), \utf8


# Export addresses of smart contracts ------------

export compose = ([config, ...rest], context, cb)->
  return cb null, [] if not config?
  err, result <- deploy-switch config, context
  return cb err if err?
  err, other <- compose rest, context
  return cb err if err?
  #saveToFile "#{outputDir}/addresses.json", to-addr(context)
  cb null, context

export execute-file = (file, cb)->
    token = file.match(/([A-Z]+)\.hs/)?1
    content = read-file-sync fullPath(file), \utf8
    commands = content |> split \\n
    #get-private-key = (context)->
    { private-key } = get-token-keys token
    compose commands, { private-key }, cb