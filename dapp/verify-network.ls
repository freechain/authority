module.exports = (cb)->
    return cb null if not web3?
    err, net-id <- web3.version.get-network
    host = location.host.split(\.)?0
    network =
        | net-id is \1 => \mainnet
        | net-id is \3 => \ropsten
        | _ => \registrant-dapp-askucher
    return cb "Your MetaMask is pointing to '#{network}' network but this game requires '#{host}'. Please choose '#{host}' network in MetaMask." if host isnt network
    cb null