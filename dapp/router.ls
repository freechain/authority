require! {
    \prelude-ls : { find, each, pairs-to-obj, map, span, even, capitalize }
    \mobx : { transaction }
    \../eth.ls : web3
}
#CONFIG PART
error-page = (err, store)->
    #Custom processing of errors
    return no-metamask-account store if err is "Default Account Is Not Found"
    store.current.page = \error
    store.current.error = err ? "Error"
no-metamask-account = (store)->
    store.current.bet.page = \metamask
restore-profile = (url, store, cb)->
    { default-account } = web3.eth 
    store.current.account = default-account
    #err, balance <- get-balance store
    #console.log err, balance
    #console.log err, balance
    #return cb err if err?
    #store.current.balance = balance
    cb null
simple-route = (page) ->
    url: (store)-> "/#{page}"
    restore: restore-page
restore-membership = (url, store, cb)->
    err <- restore-profile url, store
    return cb err if err
    cb null
restore-documentation = (url, store, cb)->
    err <- restore-profile url, store
    return cb err if err
    cb null
membership-route =
    url: (store)-> \/membership
    restore: restore-membership
    title: (store)->
        "Become a member"
documentation-route =
    url: (store)-> \/documentation
    restore: restore-documentation
    title: (store)->
        "Documentation"
main-route = 
    url: (store) -> \/
    restore: restore-profile
    title: (store)->
        "Ethnamed DAPP"
export config =
    \main : main-route
    \membership : membership-route
    \documentation : documentation-route
#GENERIC PART - DO NOT TOUCH IT
update-router = (store)->
    title = store.current.page 
    type = config[store.current.page]
    page =
        | typeof! type is \Object => type.url store
        | _ => type
    return if history.state?page is page
    history.push-state { page }, title, page
    window.scroll-to 0, 0
#
restore-item = (url, item, store)=>
    stop "Reuter is not resolved" if not item?
    stop null if typeof! item isnt \Object
    stop "Restore Router Function is Not Defined for #{item.url}" if typeof! item.restore isnt \Function
    err <- item.restore url, store
    stop err if err?
    next null
export goto = (url, store)->
    #return error-page err, store if err?
    page =
        config
            |> Object.keys 
            |> find -> url.index-of("\/#{it}") > - 1
            |> -> it ? \main
    item = config[page]
    store.current.page = \loading
    <- transaction
    err <-! restore-item url, item, store
    return error-page err, store if err?
    window.document.title = item.title?(store) ? capitalize page
    store.current.page = page
    update-router store
export reload = (store)->
    goto location.pathname, store
export on-href-click = (store, event)-->
    event.prevent-default!
    url = event.target.closest(\a).href.replace(location.origin, "")
    goto url, store
export restore-router = (store)->
    url = location.pathname 
    goto url, store