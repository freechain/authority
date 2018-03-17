require! {
    \prelude-ls : { obj-to-pairs, pairs-to-obj, map, dasherize }
    \../blockchain/.out/addresses.json
}
page = \loading
nickname = ""
account = ""
address = ""
current = { page, nickname, account, address }
module.exports = { current }