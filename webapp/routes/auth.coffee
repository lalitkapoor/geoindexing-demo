db = require '../db'
utils = require '../utils'

#exports = module.exports

User = db.User

exports.register = (req, res)->
	res.send {success: true}
	return

exports.login = (req, res)->
	if utils.isBlank req.body.email or utils.isBlank req.body.password
		console.log "one of the required fields is blank"
		res.send {error: "one of the required fields is blank"}
	else
		User.authenticate req.body.email, req.body.password, (err, user)->
			if err
				console.log err
				res.send {error: err}
			else
				req.session.user = user
				res.send {success: true}
				#res.redirect req.query.redir or '/dashboard'
				console.log "user successfully logged in"
	return

exports.logout = (req, res)->
	delete req.session.user
	res.redirect '/'
	return