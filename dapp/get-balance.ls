require! {
    \./ethnamed.ls : { registrants }
}
module.exports = (store, cb)->
    return cb "Current is not defined" if not store?current?
    err, data <- registrants store.current.account
    return cb err if err?
    cb null, data.div(10^18).to-string!