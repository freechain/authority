require! {
  \ethereumjs-tx : \Tx
  \ethereumjs-util : \eth-util
  \./config.json : config
  \web3 : \Web3
  \bignumber.js : BN
}

numToHex = (inputBn) ->
    ethUtil.addHexPrefix(new BN(inputBn ? 0).toString(16))

{ useConfig } = config

{ web3-provider, etherscan-base-url } = config[useConfig]

export create-web3 = (private-key)->
  web3 = new Web3!
  #console.log typeof! web3.eth.send-raw-transaction
  address = \0x + eth-util.private-to-address(private-key).to-string \hex
  #console.log address
  web3.set-provider(new web3.providers.HttpProvider(web3-provider))
  web3.eth.default-account = address
  web3

get-address = (web3, tx-hash, cb) ->
  #console.log "\nChecking for tx to be mined: #{txHash}"
  err, tx <-! web3.eth.get-transaction tx-hash
  return cb err if err?
  return cb "Tx is not mined yet." if not tx.block-number?
  #console.log "Tx is mined in block # #{tx.blockNumber}"
  err, tx-receipt <-! web3.eth.get-transaction-receipt tx-hash
  return cb err if err?
  #return cb "Tx is mined, but contract is not created yet." if not txReceipt.contract-address?
  contract-address = txReceipt.contract-address
  contract-url = "#{etherscanBaseUrl}/address/#{contractAddress}"
  #console.log "Address of created contract: #{contractAddress}"
  #console.log "Contract URL: #{contractUrl}"
  cb null, { contract-address, contract-url }

export try-get-address = (web3, tx-hash, cb) ->
  console.log "Try get address #{tx-hash}"
  err, data <- get-address web3, tx-hash
  return cb null, data if not err?
  return cb err if err? and err isnt "Tx is not mined yet."
  <- set-timeout _, 3000
  err, data <- try-get-address web3, tx-hash
  cb err, data

export send-transaction = ({ private-key, to, value, data }, cb)->
  return cb "Private Key is required" if not private-key?
  web3 = create-web3 private-key
  err, gas-estimate <-! web3.eth.estimate-gas { data }
  #return cb err if err?
  
  #console.log "Estimated gas limit:", gas-estimate?toString!
  
  #gas-estimate = /*gas-estimate ?*/ new BN(\6000000)
  
  err, gas-price <-! web3.eth.get-gas-price
  return cb err if err?
  #console.log "Estimated gas price:", web3.fromWei(gas-price, \gwei).toString!, \gwei
  
  err, nonce <-! web3.eth.get-transaction-count web3.eth.default-account, \pending
  return cb err if err?
  #console.log "Estimated nonce:", nonce
  
  raw-tx =
    to: to
    nonce: numToHex nonce
    gas: numToHex gas-estimate
    gas-price: numToHex gas-price
    value: numToHex value
    from: web3.eth.default-account
    data: data
  #console.log \value, value, numToHex(value ? 0), value / (10 ^ 18)
  
  private-key-strip = if private-key.length is 66 
                      then private-key.replace('0x', '') 
                      else private-key
  ownerPrivateKeyHex = new Buffer(private-key-strip, \hex)
  tx = new Tx raw-tx
  # подписываем тразаацию
  tx.sign ownerPrivateKeyHex
  
  serialized-tx = tx.serialize!
  hex = serialized-tx.to-string \hex
  
  # отправляем транзакцию
  err, tx-hash <-! web3.eth.send-signed-transaction "0x#{hex}"
  return cb err if err?
  tx-url = "#{etherscanBaseUrl}/tx/#{txHash}"
  
  #console.log "Tx hash of new #{contractName}: #{txHash}"
  #console.log "View tx: #{tx-url}"
  err, res <-! try-get-address web3, tx-hash
  return cb err if err?
  
  { contract-address, contract-url } = res
  cb null, { tx-hash, tx-url, contract-address, contract-url }