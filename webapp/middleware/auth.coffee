exports = module.exports = (options)->
	options= options or {}
	path = options.path or '/';
	
	return (req, res, next)->
		if req.session.user
			next()
		else
			url = path+'?redir='+req.url
			res.redirect url