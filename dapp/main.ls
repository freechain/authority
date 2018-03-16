require! {
    \react
    \./router.ls : { update-router, on-href-click, goto }
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
        height: $height
        width: 500px
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
                    font-size: 30px
                    &:hover
                        background: rgba(white, 0.1)
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
module.exports = ({ store })->
    state =
        nickname: ""
    resolve = (event)->
        console.log "/resolve/#{state.nickname}"
        goto "/resolve/#{state.nickname}", store
    enter-nick = (event)->
        state.nickname = event.target.value
        #console.log state.nickname
    .pug.main
        a.logo.pug
            img.pug(src="http://res.cloudinary.com/nixar-work/image/upload/v1520772268/LOGO_5.png")
        .content.pug
            .pug.resolve
                input.enter.pug(placeholder="nickname" on-change=enter-nick)
                button.pug.click-resolve(on-click=resolve)
                    i.pug.zmdi.zmdi-search
            .pug.options
                a.pug(href="/membership" on-click=on-href-click(store))
                    span.pug.part.part1 BECOME
                    span.pug.part.part2 REGISTRANT
                a.pug.right(href="/documentation" on-click=on-href-click(store))
                    span.pug.part.part1 I AM
                    span.pug.part.part2 REGISTRANT