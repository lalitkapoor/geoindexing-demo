db = require '../db'
config = require '../config'
mongoose = require 'mongoose'
utils = require '../utils'
smsified = require 'smsified'
sys = require 'sys'

gv = require 'google-voice'

voiceClient = new gv.Client({
    email: config.voice.email
    password: config.voice.password
    rnr_se: config.voice.rnr_se
})

#exports = module.exports

User = db.User
Hospital = db.Hospital


exports = module.exports

exports.notify = (req, res)->
	sms = new SMSified config.sms.username, config.sms.password
	message = 'NAME may be in need of medical assistance, track him here: http://localhost:2000/location.html'
	options = {
		senderAddress: 'YOUR_SMS_PHONE_NUMBER'
		address: 'NUMBER_YOU_WISH_TO_SMS'
		message: message
	}
	sms.sendMessage options, (result)->
		sys.puts(sys.inspect(result))
	
	voiceClient.sendSMS [NUMBER_YOU_WISH_TO_SMS],message,(body,response)->
		console.log(body);
	
	utils.sendJSON res, {success: true}
	return

exports.near = (req, res)->
	#Hospital.find {'loc': {$near: [req.params.lat, req.params.lng]} },{},{sort:{loc:1},limit:5}, (err, docs)->
	mongoose.connection.db.executeDbCommand {geoNear : "hospitals", near : [parseFloat(req.params.lat), parseFloat(req.params.lng)], spherical : true, maxDistance : 50},  (err, docs)->
		if err?
			console.log err.stack
			res.send ''
		else
			#console.log docs
			res.send docs
	return