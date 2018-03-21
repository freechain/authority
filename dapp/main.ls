require! {
    \react
    \./router.ls : { update-router, on-href-click, goto }
    \./ethnamed.ls : { register-name, registry, topup }
    \./verify-network.ls
    \./get-balance.ls
}
.main
    @keyframes rotate
        0%
            transform: rotate(0deg) 
        100%
            transform: rotate(15deg)
    .logo
        position: absolute
        left: 20px
        top: 20px
        line-height: normal
    text-align: center
    line-height: 100vh
    .zmdi-spinner
        transform: rotate(360deg)
        transition-duration: 1s
        transition-delay: now
        animation-timing-function: linear
        animation-iteration-count: infinite
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
content-body = ({ store })->
    price = 0.05ETH
    empty = ->
        ( store.current.nickname ? "" ).length is 0
    show-message = (message)->
        store.current.message = message
    can-buy-nickname = if store.current.can-buy then \active else \disabled
    check = (cb)->
        return cb? "Nickname is empty" if empty!
        store.current.checking-balance = yes
        err <- verify-network
        return cb? err if err?
        err, data <- registry store.current.nickname
        store.current.checking-balance = no
        return cb? err if err?
        can-buy = data is \0x0000000000000000000000000000000000000000
        store.current.can-buy = can-buy
        return cb? "Address Not Found" if can-buy
        cb? null, data
    resolve = ->
        err, data <- check
        return show-message err if err?
        show-message data
        #console.log "/resolve/#{store.current.nickname}"
        #goto "/resolve/#{store.current.nickname}", store
    topup-balance = (cb)->
        return cb null if +store.current.balance >= price
        err <- topup price
        return cb err if err?
        err, balance <- get-balance store
        return cb err if err?
        store.current.balance = balance
        cb null, balance
    buy-nickname = (cb)->
        { nickname, account } = store.current
        #return cb "Please topup a balance before" if +store.current.balance < 0.01
        err, data <- check
        return cb err if err? and err isnt "Address Not Found"
        return cb "Address is already exists" if err isnt "Address Not Found"
        err, transaction <- register-name nickname, account
        return cb err if err?
        cb null, "Your name is registered. Transaction #{transaction}"
    buy-nickname-process = (cb)->
        store.current.status = \topup
        err <- topup-balance
        return cb err if err?
        store.current.status = \buy-nickname
        err, done <- buy-nickname
        return cb err if err?
        cb null
    buy-nickname-click = (event)->
        return if store.current.can-buy isnt yes
        err, done <- buy-nickname-process
        store.current.status = \main
        return show-message(err.message ? err) if err?
        store.current.can-buy = no
        <- resolve
    state =
        timeout: null
    enter-nick = (event)->
        store.current.nickname = event.target.value
        clear-timeout state.timeout
        state.timeout = set-timeout resolve, 1000
        #console.log state.nickname
    .content.pug
        .pug.resolve
            input.enter.pug(placeholder="nickname" on-change=enter-nick value="#{store.current.nickname}")
            button.pug.click-resolve(on-click=resolve)
                if store.current.checking-balance
                    i.pug.zmdi.zmdi-spinner
                else 
                    i.pug.zmdi.zmdi-search
        if (store.current.message ? "").length > 0
            .pug.message #{store.current.message}
        .pug.options
            a.pug.disabled
                span.pug.part.part1 YOUR 
                span.pug.part.part2 BALANCE (#{store.current.balance})
            a.pug.right(on-click=buy-nickname-click class="#{can-buy-nickname}")
                span.pug.part.part1 BUY
                span.pug.part.part2 NICKNAME
module.exports = ({ store })->
    .pug.main
        a.logo.pug
            img.pug(src="//res.cloudinary.com/nixar-work/image/upload/v1520772268/LOGO_5.png")
        switch store.current.status
            case \main
                content-body { store }
            case \topup
                .pug Please TOPUP the account on 0.01 ETH to buy one name
            case \buy-nickname
                .pug Buy Nickname. Your balance is #{store.current.balance}