require! {
    \web3 : \Web3
    \./config.json : { ethNet, guest-account }
    \./networks.json
}

{ ownerAddress, web3Provider } = networks[ethNet]

init-custom = (ownerAddress)->
    web3 = new Web3(new Web3.providers.HttpProvider(web3Provider))
    web3.eth.default-account = ownerAddress
    web3

init-metamask = ->
    #console.log \default, window?web3?eth?default-account
    return window.web3 if window?web3?eth?default-account?
    return init-custom guest-account if window?

module.exports = init-metamask! ? init-custom(ownerAddress)
