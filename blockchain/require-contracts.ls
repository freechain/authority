require! {
    \../config.json : { ethNet }
}

module.exports = (resource) ->
    require "./.out/#{ethNet}/#{resource}"