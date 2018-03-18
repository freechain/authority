require! {
    \require-ls
    \./blockchain/.out/addresses.json
    \./blockchain/.out/NameRegistry.abi.json : registry-abi
    #\../blockchain/.out/Token.abi.json : token-abi
    #\../blockchain/.out/Tokensale.abi.json : sale-abi
    \prelude-ls : { map, pairs-to-obj }
}
get-contract-instance = (abi, addr)-> (web3)->
    Contract = web3.eth.contract abi
    Contract.at addr
export registry-contract = get-contract-instance registry-abi, addresses.NameRegistry
export topup-builder = (web3) -> (amount, cb)->
    transaction =
        to: addresses.NameRegistry
        value: web3.toWei(amount, \ether).to-string!
    err, data <- web3.eth.send-transaction transaction
    cb err, data
module.exports = (web3)->
    topup = topup-builder web3
    contract = registry-contract web3
    { topup, ...contract }