require! {
    \../blockchain/.out/addresses.json
    \../blockchain/.out/NameRegistry.abi.json : registry-abi
    #\../blockchain/.out/Token.abi.json : token-abi
    #\../blockchain/.out/Tokensale.abi.json : sale-abi
    \prelude-ls : { map, pairs-to-obj }
    \../eth.ls : web3
}
get-contract-instance = (abi, addr) ->
    Contract = web3.eth.contract abi
    Contract.at addr
#export token-contract = getContractInstance token-abi, addresses.HeroToken
#export sale-contract = getContractInstance sale-abi, addresses.Tokensale
export registry-contract = get-contract-instance registry-abi, addresses.NameRegistry