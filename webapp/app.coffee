express = require 'express'
mongoose = require 'mongoose'
db = require './db'
MongoStore = require 'connect-mongo'

routes = require './routes'
config = require './config'

nowjs = require 'now'

#catch all uncaught exceptions, so our entire app doesn't die!
process.on 'uncaughtException', (err)->
  console.error(err.stack)
  console.log("Node NOT Exiting...")

app = express.createServer()
everyone = nowjs.initialize(app)
everyone.now.msg = "Hello World!"

everyone.now.update = (lat, lng, id)->
	console.log("id:"+id)
	everyone.now.getLocation lat, lng
	if id?
		db.Hospital.findOne {"_id": id}, (err, doc)->
			if err?
				console.log err
			else
				console.log doc
				everyone.now.getData lat, lng, doc
	

app.configure(->
	app.use express.logger()
	app.use express.methodOverride()
	app.use express.bodyParser()
	app.use express.cookieParser()
	app.use express.session {
		secret: "puls3s3kr3tk3ysa|t"
		store: new MongoStore {
			host: config.mongo.host
			port:config.mongo.port
			db:config.mongo.db.mongodc
		}
	}
	app.use app.router
	app.use express.static __dirname+'/static'
)

console.log __dirname+'/static'

app.configure("development", ->
	app.use express.errorHandler {
		dumpExceptions: yes
		showStack: yes
	}
)

app.configure("production", ->
	app.use express.errorHandler()
)

app.set "views", __dirname + "/views"
app.set "view engine", "jade"
app.set "view options", {layout: false, prettyprint: true}

routes.set app
app.listen 2000, "0.0.0.0", (err)->
	console.log 'ready'