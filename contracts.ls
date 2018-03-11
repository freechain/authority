require! {
    \../contracts/.out/addresses.json
    \../contracts/.out/HeroRegistry.abi.json : registry-abi
    \../contracts/.out/HeroToken.abi.json : token-abi
    \../contracts/.out/Tokensale.abi.json : sale-abi
    \prelude-ls : { map, pairs-to-obj }
    \../eth.ls : web3
}
getContractInstance = (abi, addr) ->
    Contract = web3.eth.contract abi
    Contract.at addr

export token-contract = getContractInstance token-abi, addresses.HeroToken

export sale-contract = getContractInstance sale-abi, addresses.Tokensale

export registry-contract getContractInstance registry-abi, addresses.Registry