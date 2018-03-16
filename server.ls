require! {
   \./config.json : { port }
   \body-parser
   \require-ls
   \http
   \fs : { read-file-sync }
}

get-index = ->
   read-file-sync \./dapp/.compiled/client-index.html , \utf8

server = http.create-server (req, res)->
  res.writeHead 200, {'Content-Type': 'text/html'}
  res.end get-index!

server.listen port ? 8080

process.on \uncaughtException ,  (err)->
   console.log err