require! {
    \mobx-react : { observer }
    \mobx : { observable }
    \react
    \./router.ls : { update-router, on-href-click }
    \./pages.ls
}
.app
    @import "//fonts.googleapis.com/css?family=Titillium+Web:200,400,700"
    @import "//cdnjs.cloudflare.com/ajax/libs/material-design-iconic-font/2.2.0/css/material-design-iconic-font.min.css"
    @import "//cdnjs.cloudflare.com/ajax/libs/flexboxgrid/6.3.1/flexboxgrid.min.css"
    @font-face
        font-family: 'DS-Digital'
        src: url("//webfonts.ffonts.net/webfonts/D/S/DS-Digital/DS-Digital.ttf.woff")
    min-height: 100vh
    min-width: 1200px
    overflow-x: hidden
    font-family: 'Titillium Web', sans-serif
    color: white
    background: #2d2f39

not-found = ->
    .content.pug Page Not Found
module.exports = ({ store, io })->
    current-page =
        pages[store.current.page] ? not-found
    #console.log \render
    throw "#{store.current.page} is not a page" if typeof! current-page isnt \Function
    .app.pug
        current-page { store }