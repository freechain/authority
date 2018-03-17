require! {
    \react
    \./router.ls : { on-href-click }
}
.resolve
    line-height: 100vh
    text-align: center
    >.result
        line-height: normal
        vertical-align: middle
        display: inline-block
        font-size: 20px
        color: white
        >.back>a
            color: rgba(white, 0.5)
            margin-top: 5px
            text-decoration: none
            font-size: 15px
        >.result-body
            padding: 20px
            border: 1px solid #797878
            border-radius: 10px
            min-width: 300px
            >.text 
                font-size: 25px
                .zmdi
                    font-size: 60px
                .orange
                    color: orange
module.exports = ({ store })->
    { address, nickname } = store.current
    .pug.resolve
        .pug.result
            .result-body.pug
                if address is '0x'
                    .pug.text 
                        .pug
                            i.zmdi.pug.zmdi-alert-triangle
                        .pug.orange Address Not Found
                else
                    .pug.text
                        .pug
                            i.zmdi.pug.zmdi-cloud-done
                        .pug
                            span.pug The nickname
                            span.pug.orange #{nickname}
                            span.pug is bound to address 
                            span.pug.orange #{address}
            .pug.back
                a.pug(href="/" on-click=on-href-click(store)) Back to search