require! {
  \ethereumjs-tx : \Tx
  \ethereumjs-util : \eth-util
  \fs : { read-file-sync, write-file-sync }
  \glob
  \solc
  \path
  \bignumber.js : BN
  \./config.json : config
  \prelude-ls : { map, pairs-to-obj, obj-to-pairs, split, each }
  \web3 : \Web3
  \./helpers/variables.js
  \./helpers/fix-spaces.js
  \./helpers/remove-doubled-solidity-version.js
  \./helpers/replace-all-imports-recursively.js
}

resolve = (config, cb)->
    [_, input, output] = config.match(/resolve (.+) -> (.+)/)
    inputFileContent = readFileSync input, \utf8
    err, srcFiles <- glob variables.parentDir + \/**/*.sol
    variables.allSrcFiles = srcFiles
    return cb err if err?
    outputFileContent <- replaceAllImportsRecursively inputFileContent, variables.parentDir + \/
    outputFileContent = removeDoubledSolidityVersion(outputFileContent)
    outputFileContent = fixSpaces outputFileContent
    console.log '\nSize of a full source:', (outputFileContent.length / 1024).toFixed(4), 'KB'
    writeFileSync output, outputFileContent
    console.log 'Success! Flat file is generated to ' + variables.outDir + ' directory'
    cb null

numToHex = (inputBn) ->
    ethUtil.addHexPrefix(inputBn.toString(16))
    
fullPath = (relativePath) ->
    path.resolve __dirname, relativePath

readFile = (filePath) ->
    readFileSync fullPath(filePath), \utf8
    

{ useConfig, outputDir } = config
console.log { useConfig }

return console.log('Please define config') if not useConfig?

{ ownerPrivateKey, ownerAddress, web3Provider, etherscanBaseUrl } = config[useConfig]

getContractBytecode = (contractName) ->
    readFile "#{outputDir}/#{contractName}.bytecode"



logBytecode = false

# Functions ----------------------

initWeb3 = ->
  web3 = new Web3!
  web3.set-provider(new web3.providers.HttpProvider(web3Provider))
  web3.eth.default-account = ownerAddress
  web3

getContractAbi = (contractName) ->
  JSON.parse readFile "#{outputDir}/#{contractName}.abi.json"

getContractInstance = (contractName, contractAddress) -->
  Contract = web3.eth.contract getContractAbi(contractName)
  Contract.at contractAddress

injectLibsIntoBytecode = (bytecode, libs) ->
  Object.keys(libs).forEach (libName) ->
    regex = new RegExp("__:" + libName + "[_]+", \g)
    libAddr = libs[libName].replace \0x, ''
    bytecode := bytecode.replace regex, libAddr
  bytecode

deployContractWithLibs = (contractName, libs, cb) --> 
  console.log "\nDeploying a contract #{contractName}..."
  console.log "Libs:", libs if libs?
  
  bytecode = getContractBytecode contractName
  if logBytecode then console.log "\nBytecode of #{contractName}:\n#{bytecode}\n"
  if libs?
    bytecode = injectLibsIntoBytecode bytecode, libs
    if logBytecode then console.log "\nBytecode of #{contractName} AFTER libs injected:\n#{bytecode}\n"
  
  err, gas-estimate <-! web3.eth.estimateGas({ data: "0x#{bytecode}" })
  return cb err if err?
  console.log "Estimated gas limit:", gas-estimate?toString!
  gas-estimate = gas-estimate ? new BN(\6000000)
  
  err, gas-price <-! web3.eth.get-gas-price
  return cb err if err?
  console.log "Estimated gas price:", web3.fromWei(gas-price, \gwei).toString!, \gwei
  
  err, nonce <-! web3.eth.get-transaction-count ownerAddress, \pending
  return cb err if err?
  console.log "Estimated nonce:", nonce
  
  raw-tx =
    nonce: numToHex nonce
    gas: numToHex gas-estimate
    gas-price: numToHex gas-price
    value: numToHex 0
    from: ownerAddress
    data: "0x#{bytecode}"
  
  # console.log "Raw tx before sending:\n", raw-tx
  
  #создаем приватный ключ со строки
  ownerPrivateKeyHex = new Buffer(ownerPrivateKey, \hex)
  tx = new Tx raw-tx
  # подписываем тразаацию 
  tx.sign ownerPrivateKeyHex
  
  serialized-tx = tx.serialize!
  hex = serialized-tx.to-string \hex
  
  # отправляем транзакцию 
  err, txHash <-! web3.eth.send-raw-transaction "0x#{hex}"
  return cb "Failed to deploy contract #{contractName}. Tx sent but with error: #{err}" if err?
  txUrl = "#{etherscanBaseUrl}/tx/#{txHash}"
  
  console.log "Tx hash of new #{contractName}: #{txHash}"
  console.log "View tx: #{txUrl}"
  err, res <-! getContractAddressByTxHash txHash
  return cb err if err?
  
  { contractAddress, contractUrl } = res
  cb null, { txHash, txUrl, contractAddress, contractUrl }


# txHash of transaction that created a contract.
getContractAddressByTxHash = (txHash, cb) ->
  console.log "\nChecking for tx to be mined: #{txHash}"
  err, tx <-! web3.eth.getTransaction txHash
  return cb err if err?
  return cb "Tx is not mined yet." if not tx.blockNumber?
  console.log "Tx is mined in block # #{tx.blockNumber}"
  err, txReceipt <-! web3.eth.getTransactionReceipt txHash
  return cb err if err?
  return cb "Tx is mined, but contract is not created yet." if not txReceipt.contractAddress?
  contractAddress = txReceipt.contractAddress
  contractUrl = "#{etherscanBaseUrl}/address/#{contractAddress}"
  console.log "Address of created contract: #{contractAddress}"
  console.log "Contract URL: #{contractUrl}"
  cb null, { contractAddress, contractUrl }

web3 = initWeb3!

deploy = (name, libs, cb)->
  console.log "deploy", name, libs
  err, res <-! deployContractWithLibs name, libs
  return cb err if err?
  return cb "Cannot find contractAddress" if not res.contractAddress?
  address = res.contractAddress
  instance = getContractInstance name, address
  console.log "#{name} deployed at address:", address
  cb null, instance

export to-addr = obj-to-pairs >> (map -> [it.0, it.1.address]) >> pairs-to-obj

get-config = (config)->
    console.log \deploy, config
    [_, name, lib-str] = config.match(/^deploy (.+) libs: (.+)$/) ? config.match(/^deploy (.+)$/)
    get-libs = | lib-str? => (split ",") >> map (.trim!)
               | _ => -> it
    libs = get-libs lib-str
    console.log name, libs
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
  err, contract <- deploy name , applied-libs
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
                   |> -> it ++ [cb]

    context[contract][method].apply null, args

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
    writeFileSync fullPath("#{outputDir}/#{name}.bytecode"), compiledContract.bytecode
    writeFileSync fullPath("#{outputDir}/#{name}.abi.json"), compiledContract.interface

  contracts |> split \, 
            |> map (.trim!) 
            |> each saveCompiledContract
  cb null

deploy-switch = (config, context, cb)->
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
  saveToFile "#{outputDir}/addresses.json", to-addr(context)
  cb null, context

export execute-file = (file, cb)->
    content = read-file-sync fullPath(file), "utf8"
    commands = content |> split \\n
    compose commands, {}, cb
        
  
