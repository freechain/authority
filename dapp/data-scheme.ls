require! {
    \prelude-ls : { obj-to-pairs, pairs-to-obj, map, dasherize }
    \../blockchain/.out/addresses.json
}
page = \loading
nickname = ""
account = null
balance = 0
can-buy = no
address = ""
message = ""
status = \main
checking-balance = no
current = { page, nickname, account, address, message, balance, can-buy, checking-balance, status }
module.exports = { current }