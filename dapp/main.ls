require! {
    \react
    \./router.ls : { update-router, on-href-click, goto }
    \./ethnamed.ls : { register-name, registry, topup }
    \./verify-network.ls
    \./get-balance.ls
}
.main
    .logo
        position: absolute
        left: 20px
        top: 20px
        line-height: normal
    text-align: center
    line-height: 100vh
    >.content
        $height: 160px
        $font: 20px
        $border: #CCC
        line-height: normal
        min-height: $height
        width: 700px
        display: inline-block
        vertical-align: middle
        border: 1px solid $border
        box-shadow: 0px 0px 5px $border
        border-radius: 5px
        background: rgba(white, 0.01)
        >.resolve
            >*
                display: inline-block
                box-sizing: border-box
                vertical-align: top
                height: $height / 2
                background: transparent
                border: 0
                font-size: $font
                &.enter
                    width: 70%
                    padding: 10px 30px
                    color: white
                    font-size: $font
                    outline: none
                &.click-resolve
                    border-left: 1px solid $border
                    width: 30%
                    color: white
                    cursor: pointer
                    font-size: 45px
                    &:hover
                        background: rgba(white, 0.1)
        >.message
            background: rgba(white, 0.1)
            padding: 10px
            border-top: 1px solid white
        >.options
            >a
                width: 50%
                cursor: pointer
                font-size: $font
                box-sizing: border-box
                height: $height / 2
                line-height: $height / 2
                border-top: 1px solid $border
                display: inline-block
                color: white
                text-decoration: none
                &.right
                    border-left: 1px solid $border
                &:hover
                    background: rgba(white, 0.1)
                >.part
                    display: inline-blcok
                    &.part1
                        color: orange
                        margin-right: 2px
                    &.part2
                &.disabled
                    .part1, .part2
                        color: rgba(gray, 0.5)
                    &:hover
                        background: transparent
module.exports = ({ store })->
    empty = ->
        ( store.current.nickname ? "" ).length is 0
    alert = (message)->
        store.current.message = message
    check = (cb)->
        return cb "Nickname is empty" if empty!
        err <- verify-network
        return cb err if err?
        err, data <- registry store.current.nickname
        return cb err if err?
        can-buy = data is \0x0000000000000000000000000000000000000000
        store.current.can-buy = can-buy
        return cb "Address Not Found" if can-buy
        cb null, data
    resolve = (event)->
        err, data <- check
        return alert err if err?
        alert data
        #console.log "/resolve/#{store.current.nickname}"
        #goto "/resolve/#{store.current.nickname}", store
    topup-balance = (event)->
        err <- topup 0.1
        return alert err if err?
        err, balance <- get-balance store
        store.current.balance = balance
    can-buy-nickname = if store.current.can-buy and +store.current.balance >= 0.1 then \active else \disabled
    buy-nickname = (event)->
        return if store.current.can-buy isnt yes
        err, data <- check
        return alert err if err? and err isnt "Address Not Found"
        return alert "Address is already exists" if err isnt "Address Not Found"
        err, transaction <- register-name store.current.nickname, store.current.account
        return alert err if err?
        alert "Your name is registered. Transaction #{transaction}"
    enter-nick = (event)->
        store.current.nickname = event.target.value
        #console.log state.nickname
    .pug.main
        a.logo.pug
            img.pug(src="//res.cloudinary.com/nixar-work/image/upload/v1520772268/LOGO_5.png")
        .content.pug
            .pug.resolve
                input.enter.pug(placeholder="nickname" on-change=enter-nick)
                button.pug.click-resolve(on-click=resolve)
                    i.pug.zmdi.zmdi-search
            if (store.current.message ? "").length > 0
                .pug.message #{store.current.message}
            .pug.options
                a.pug(on-click=topup-balance)
                    span.pug.part.part1 TOPUP
                    span.pug.part.part2 BALANCE (#{store.current.balance} ETH)
                a.pug.right(on-click=buy-nickname class="#{can-buy-nickname}")
                    span.pug.part.part1 BUY
                    span.pug.part.part2 NICKNAME