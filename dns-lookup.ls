require! {
    \dns
}




get-ethnamed-record = (domain, key, cb)->
    err, data <- dns.resolve-txt domain
    return cb err if err?
    name = "ethnamed-#{key}="
    value = data.filter( -> it.0.index-of(name) is 0).0?0?replace?("#{name}=", "")
    cb null, value
    
err, data <- get-ethnamed-record \microsoft.com , \eth-address

console.log err, data