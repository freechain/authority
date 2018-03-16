require! {
    \mobx-react : { observer }
    \mobx : { observable, toJS, transaction }
    \react-dom : { render }
    \react
    \./app.ls
    \prelude-ls : { obj-to-pairs, pairs-to-obj, map, each, concat, filter, find }
    \./data-scheme.ls
    \./router.ls : { restore-router, goto, reload }
}
{ parse, stringify } = JSON
store = observable data-scheme

Main = observer ({store})->
    app { store }

window.onpopstate = (event, state)-> 
    goto event.state.page, store

restore-router store

window.onload = ->
    render do
        Main.pug( store=store )
        document.body.append-child document.create-element \app