require! {
    \prelude-ls : { obj-to-pairs, pairs-to-obj, map, dasherize }
    \../blockchain/.out/addresses.json
}
page = \loading
nickname = ""
account = ""
balance = 0
address = ""
message = ""
current = { page, nickname, account, address, message, balance }
module.exports = { current }