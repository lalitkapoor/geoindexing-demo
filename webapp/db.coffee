config = require './config'
mongoose = require 'mongoose'
mongooseTypes = require 'mongoose-types'
utils = require './utils'
sys = require 'sys'

exports = module.exports

# connect to database
exports.db = mongoose.connect config.mongo.host, config.mongo.db.mongodc, config.mongo.port, (err, conn)->
	if err?
		console.log err
		logger.info 'error connecting to db'
	else
		console.log 'successfully connected to db'

mongooseTypes.loadTypes(mongoose)
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
Email = mongoose.SchemaTypes.Email
Url = mongoose.SchemaTypes.Url

# This is my fix for a bug that exists in mongoose that doesn't
# expose these methods if using a named scope

#add some missing cursor methods to model object
['limit', 'skip', 'maxscan', 'snapshot'].forEach (method) ->
  mongoose.Model[method] = (v)->
    cQuery
    if (cQuery = this._cumulativeQuery)
      cQuery.options[method] = v
    this

####################
# Hospital #########
####################
Hospital = new Schema {
	address1: String
	address2: String
	address3: String
	city: String
	gAddress: String
	loc: [Number]
	name: String
	num: Number
	phone: Number
	state: String
	zip: String
	logins: []
}

#compound indexes
Hospital.index {"name": 1}
Hospital.index {"loc": "2d"}

####################
# User #############
####################
User = new Schema {
	email: {type: String, index: true, unique:true, set: utils.toLower, validate: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/}
	password: {type: String, validate:/.{5,}/}
	created: {type: Date, default: Date.now, index: true}
	logins: []
	currentLocation:{
		x: Number
		y: Number
	}
}

#compound indexes
User.index {email:1, password:1}

#static functions
User.static {
	authenticate: (email, password, callback)->
		this.findOne {email: email, password: password}, (err, user)->
			if(err)
				return callback err, user
			if user?
				return callback err, user
			else
				return callback "invalid username password"
		return
}

mongoose.model 'User', User
mongoose.model 'Hospital', Hospital

exports.User = mongoose.model 'User'
exports.Hospital = mongoose.model 'Hospital'

exports.models = {
	User: User
	Hospital: Hospital
}