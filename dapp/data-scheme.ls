require! {
    \prelude-ls : { obj-to-pairs, pairs-to-obj, map, dasherize }
    \../blockchain/.out/addresses.json
}
page = \loading
current = { page }
module.exports = { current }