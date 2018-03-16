require! {
    \react
}
.error
    text-align: center
    padding: 7%
    >.head
        font-size: 150px
        color: red
        text-aling: center
        >*
            display: inline-block
            max-width: 600px
    >.title
        font-size: 25px
    >.message
        font-size: 20px
        

standard = ->
    i.zmdi.zmdi-error
choose-ropsten = ->
    img.pug(src="http://res.cloudinary.com/thedapper/image/upload/v1519312076/metamask-ropsten-mainnet.gif")
choose-mainnet = ->
    img.pug(src="http://res.cloudinary.com/thedapper/image/upload/v1519312075/metamask-mainnet-ropsten.gif")
show-example = (message)->
    | not message? => null
    | message.index-of("Your MetaMask is pointing to 'mainnet' network") > -1 => choose-ropsten!
    | message.index-of("Your MetaMask is pointing to 'ropsten' network") > -1 => choose-mainnet!
    | _ => standard!
module.exports = ({ store })->
    err = store.current.error
    message = err.message ? err
    .pug.error 
        .pug.head
            show-example message
        .pug.title Oops!
        .pug.message #{message}