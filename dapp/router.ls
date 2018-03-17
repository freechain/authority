require! {
    \prelude-ls : { find, each, pairs-to-obj, map, span, even, capitalize }
    \mobx : { transaction }
    \../eth.ls : \web3
    \./verify-network.ls
    \./contracts.ls : { registry-contract }
}
#CONFIG PART
error-page = (err, store)->
    #Custom processing of errors
    return no-metamask-account store if err is "Default Account Is Not Found"
    store.current.page = \error
    store.current.error = err
no-metamask-account = (store)->
    store.current.bet.page = \metamask
restore-profile = (url, store, cb)->
    { default-account } = web3.eth
    store.current.account = default-account
    cb null
simple-route = (page) ->
    url: (store)-> "/#{page}"
    restore: restore-page
restore-resolve = (url, store, cb)->
    [_, page, nickname] = url.split \/
    store.current.nickname = nickname
    err, address <- registry-contract.registry nickname
    return cb err if err?
    store.current.address = address
    <- restore-profile url, store
    cb null
restore-membership = (url, store, cb)->
    <- restore-profile url, store
    cb null
restore-documentation = (url, store, cb)->
    <- restore-profile url, store
    cb null
resolve-route =
    url: (store)-> "/resolve/#{store.current.nickname}"
    restore: restore-resolve
    title: (store)->
        "Resolve #{store.current.nickname}"
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
export config =
    \main : \/
    \resolve : resolve-route 
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
restore-item = (url, item, store, cb)->
    return cb "Reuter is not resolved" if not item?
    return cb null if typeof! item isnt \Object
    return cb "Restore Router Function is Not Defined for #{item.url}" if typeof! item.restore isnt \Function
    err <-! item.restore url, store
    return cb err if err?
    cb null
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