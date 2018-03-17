require! {
    \./contracts.ls : { registry-contract }
}
module.exports = (store, cb)->
    err, data <- registry-contract.registrants store.current.account
    return cb err if err?
    cb null, data.div(10^18).to-string!