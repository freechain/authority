require! {
    \./ethnamed.ls : { registrants }
}
module.exports = (store, cb)->
    return cb "Account is not defined" if not store?current?account
    err, data <- registrants store.current.account
    return cb err if err?
    cb null, data.div(10^18).to-string!