require! {
  \fs : { writeFileSync }
  \bignumber.js : BN
  \path
  \async/parallel
  \./config.json : { outputDir, outputSourcePath }
  \./eth-cmd.ls : { execute-file }
}

err, contracts <- execute-file \./commands/deploy.hs

return console.log err if err?

console.log "Deploy is Done"

# Export coin IDs: -----------------
# Just take instance of any race, then we will get coin IDs out of it:

#idMap = 
#  coinToAddress: {}
#  intToCoin: {}
#err, res <-! parallel Object.keys(coins).map (coin) ->
#  (cb) -> contracts.RaceOldSchool4h[coin] (err, res) ->
#    addr = res.toString!
#    int = new BN(addr).toString!
#    console.log "Address of #{coin} coin: #{addr}. Error: #{err}"
#    idMap.coinToAddress[coin] = addr
#    idMap.intToCoin[int] = coin
#    cb err, { coin, addr }
    
#return console.log err if err?

#fullPath = (relativePath) ->
#    path.resolve __dirname, relativePath
    
#saveToFile = (path, addresses) ->
#    console.log "Export to file: #{path}"
#    writeFileSync fullPath(path), JSON.stringify(addresses, null, 2), \utf8

#saveToFile "#{outputDir}/coin-ids.json", idMap