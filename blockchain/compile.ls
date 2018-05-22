require! {
  \./eth-cmd.ls : { execute-file }
}

err <- execute-file \./commands/compile.hs

return console.log err if err?

console.log "Compile is Done"