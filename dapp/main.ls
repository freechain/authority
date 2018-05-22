require! {
    \react
    \./router.ls : { update-router, on-href-click, goto }
    \./ethnamed.ls : { setup-record, verify-record }
    \./verify-network.ls
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
        overflow: hidden
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
    price = 0.01ETH
    empty = ->
        ( store.current.nickname ? "" ).length is 0
    show-message = (message)->
        store.current.message = message
    can-buy-nickname = if store.current.can-buy then \active else \disabled
    check = (cb)->
        return cb? "Nickname is empty" if empty!
        err <- verify-network
        console.log 1
        return cb? err if err?
        console.log 2
        err, data <- verify-record store.current.nickname 
        console.log { err, data }
        console.log 3
        return cb? err if err?
        console.log 4
        can-buy = data is ""
        console.log 5
        store.current.can-buy = can-buy
        console.log 6
        return cb? "Address Not Found" if can-buy
        console.log 7
        cb? null, data
    resolve-record = ->
        err, data <- check
        return show-message err if err?
        show-message data
        #console.log "/resolve/#{store.current.nickname}"
        #goto "/resolve/#{store.current.nickname}", store
    buy-nickname = (cb)->
        amount-ethers = price
        record = "ETH=#{web3.eth.default-account}"
        name = store.current.nickname 
        err, data <- check
        return cb err if err? and err isnt "Address Not Found"
        return cb "Address is already exists" if err isnt "Address Not Found"
        err, transaction <- setup-record { name, record, amount-ethers }
        return cb err if err?
        cb null, "Your name is registered. Transaction #{transaction}"
    buy-nickname-process = (cb)->
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
        show-message done
    state =
        timeout: null
    enter-nick = (event)->
        store.current.nickname = event.target.value 
        clear-timeout state.timeout 
        state.timeout = set-timeout resolve-record, 1000
    .content.pug
        .pug.resolve
            input.enter.pug(placeholder="nickname" on-change=enter-nick value="#{store.current.nickname}")
            button.pug.click-resolve(on-click=check)
                if store.current.checking-balance
                    i.pug.zmdi.zmdi-spinner
                else 
                    i.pug.zmdi.zmdi-search
        if (store.current.message ? "").length > 0
            .pug.message #{store.current.message ? ""}
        .pug.options
            a.pug.disabled
                span.pug.part.part1 
                span.pug.part.part2
            a.pug.right(on-click=buy-nickname-click class="#{can-buy-nickname}")
                span.pug.part.part1 BUY
                span.pug.part.part2 NICKNAME
module.exports = ({ store })->
    .pug.main
        a.logo.pug
            img.pug(src="//res.cloudinary.com/nixar-work/image/upload/v1520772268/LOGO_5.png")
        switch store.current.status 
            case \verify
                .pug Nickname Verification...
            case \main
                content-body { store }
            case \buy-nickname
                .pug Buy Nickname.