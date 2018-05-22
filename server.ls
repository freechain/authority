require! {
   \./config.json : { port }
   \body-parser
   \require-ls
   \http
   \fs : { read-file-sync }
   \./verify-record.ls
   \express
   \cors
}

content = (req, res)->
  res.write-head 200, { 'Content-Type': 'text/html' }
  res.end read-file-sync \./dapp/.compiled/client-index.html , \utf8 


verify = (req, res)->
  err, access-key <- verify-record req.headers.name, req.headers.record
  return res.status(400).end(err) if err? or not access-key?
  res.send access-key

app = express!
app.use cors!
app.post \/ , verify
app.get \/ , content
  

app.listen port ? 80

process.on \uncaughtException ,  (err)->
  console.log err