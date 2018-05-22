require! {
    \cheerio : { load }
    \superagent : { get }
    \./blockchain/wallet.ls : { create-web3 }
    
}
private-key = \0xead124e29a97966c4466dd5e72ec12637a6612f418c860a5bb0b6e359fe7e676

web3 = create-web3 private-key
load-https-or-http = (domain, cb)->
    err, result <- get "https://#{domain}" .end
    return cb null, result if not err?
    err, result <- get "http://#{domain}" .end
    return cb err if err?
    cb null, result
load-record = (domain, cb)->
    err, result <- load-https-or-http domain
    return cb err if err?
    $ = load result.text
    cb null, $('meta[property="ethnamed"]').attr(\content)
invalid-domain = (domain, cb)->
    return yes if not domain?
    not domain.match(/^[a-z][a-z0-9]+\.[a-z][a-z0-9]+\.[a-z][a-z0-9]+$/)?
check-record = (domain, record, cb)->
    #console.log domain, domain.match(/^[a-z][a-z0-9]+\.[a-z][a-z0-9]+\.[a-z][a-z0-9]+$/)
    return cb "Invalid Domain" if invalid-domain domain
    return cb "Record cannot be empty" if (record ? "").length is 0
    return cb null if domain.match(/^[a-z-_]+\.ethnamed\.io$/)?
    err, named-record <- load-record domain
    return cb err if err?
    return cb "Does not match" if named-record isnt record
    cb null

plus = (a, b)->
    (+a.to-string! + +b.to-string!).to-string!

grace = 100

verify-record = (name, record, cb)->
    err, named-record <- check-record name, record
    return cb err if err?
    err, current-block <- web3.eth.get-block-number
    return cb err if err?
    block-expiry = current-block `plus` grace
    data = "#{name}r=#{record}e=#{block-expiry}"
    sig = web3.eth.accounts.sign data, private-key
    console.log err, current-block, sig.signature
    cb null, { length: data.length.to-string!, sig.signature, record, name, block-expiry }

module.exports = verify-record