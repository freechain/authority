require! {
    \prelude-ls : { find, each, pairs-to-obj, map, span, even, capitalize }
    \mobx : { transaction }
    \../eth.ls : \web3
    \./verify-network.ls 
}
#CONFIG PART
error-page = (err, store)->
    #Custom processing of errors
    return no-metamask-account store if err is "Default Account Is Not Found"
    store.current.page = \error
    store.current.error = err

plan-get-race = (race-id, store, cb)->
    repeat-get-race = ->
        get-race race-id, store, cb
    set-timeout repeat-get-race, 100

get-race = (race-id, store, cb)->
    race =
        store.races |> find (.id is race-id)
    returcb cb "Race Not Found" if not race?
    return plan-get-race(race-id, store, cb) if +race.lap is -1
    return cb null, race if +race.lap is +store.current.lap
    { lap } = store.current
    request-race = { lap, race.race-eth-address, race.id, race.name }
    err, contract-race <- race-from-contract request-race
    return cb err if err?
    contract-race.from-contract = yes
    return cb "Cars Not Found in Contract" if contract-race.cars.length is 0
    cb null, contract-race
    
restore-race = (url, store, cb)->
    [_, _, race-id, lap, car] = url.split \/
    delete store.current.race
    return cb "There are no started races" if +lap < 0
    store.current.car = car
    store.current.lap = lap
    err, race <-! get-race race-id, store
    return cb err if err?
    return cb "Expected lap #{lap}, Given: #{race.lap}" if +lap isnt +race.lap
    return cb "Race Not Found", store if not race?
    store.current.race = race
    setup-countdown store
    #store.current.page = \finish if race.win-car?
    err, me <- my-token-balance
    return cb err if err?
    store.me <<<< me
    err, data <- my-bets store.current
    store.current <<<< data
    return cb err if err?
    cb null

no-metamask-account = (store)->
    store.current.bet.page = \metamask
    
restore-profile = (url, store, cb)->
    { default-account } = web3.eth
    store.current.account = default-account
    cb null

fill-bet = (store, cb)->
    { default-account } = web3.eth
    return no-metamask-account(store) if not default-account?
    err, res <-! web3.eth.get-balance default-account
    return cb err if err?
    store.current.account = default-account
    store.current.bet.balance-wei = res.to-string!
    store.current.bet.balance = web3.from-wei res, \ether
    #console.log store.current.bet.balance
    #store.current.bet.send-eth = store.current.bet.balance
    # contract = get-contract.token store.current.race.race-eth-address
    contract = get-contract.token
    return cb err if err?
    err, res <-! contract.balance-of default-account
    balance = res
    return cb err if err?
    store.current.bet.balance-tokens18 = balance.to-string!
    store.current.bet.balance-tokens = web3.from-wei balance, \ether
    store.current.bet.send-tokens = store.current.bet.balance-tokens
    store.current.bet.page =
        if balance.eq 0 then \hasno else \has
    cb null

restore-bet = (url, store, cb)->
    err <- verify-network
    return cb err if err?
    err <-! restore-race url, store
    return cb err if err? 
    return cb "Car is not Defined" if not store.current.car?
    store.current.bet.page = \checking
    err <-! fill-bet store
    return cb err if err?
    cb null
    
restore-sale = (url, store, cb)->
    err <- verify-network
    return cb err if err?
    store.current.bet.page = \checking
    err, me <- my-token-balance
    return cb err if err?
    store.me <<<< me
    err <-! fill-bet store
    return cb err if err?
    store.current.bet.page = \hasno
    cb null
    
restore-page = (url, store, cb) ->
    { default-account } = web3.eth
    err, me <- my-token-balance
    return cb err if err?
    store.me <<<< me
    cb null

simple-route = (page) ->
    url: (store)-> "/#{page}"
    restore: restore-page
race-route =
    url: (store)-> "/race/#{store.current.race.id}/#{store.current.lap}"
    restore: restore-race
    title: (store)->
        "Race - #{store.current.race.name}"
profile-route = 
    url: (store)-> \/profile
    restore: restore-profile
    title: (store)->
        "Your profile"
sale-route = 
    url: (store)-> \/sale
    restore: restore-sale
    title: (store)->
        "Tokensale"
bet-route =
    url: (store)-> "/bet/#{store.current.race.id}/#{store.current.lap}/#{store.current.car}" 
    restore: restore-bet
    title: (store)->
       "Bet - #{store.current.car.to-upper-case!} - #{store.current.race.name}"
finish-route =
    url: (store)-> "/finish/#{store.current.race.id}/#{store.current.lap}"
    restore: restore-race
    title: (store)->
        "Finished - #{store.current.race.name}"

export config =
    \choose : \/
    \landing : \/landing
    \research : \/research
    \history : simple-route \history
    \currencyrates : simple-route \currencyrates
    \terms : simple-route \terms
    \whitepaper : simple-route \whitepaper
    \rules : simple-route \rules
    \sale : sale-route
    \bet : bet-route
    \finish : finish-route
    \profile : profile-route
    \race : race-route

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
            |> -> it ? \choose
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