auth = require './middleware/auth'

apps = {
	landing: require('./routes/landing')
	geo: require('./routes/geo')
	url: require('./routes/url')
	auth: require('./routes/auth')
}

routes = {}
routes.set = (app)->
	
	### SITE ###
	
	#landing
	app.get '/', apps.landing.index
	
	#authentication
	app.post '/auth/register', apps.auth.register
	app.post '/auth/login', apps.auth.login
	app.get '/auth/logout', apps.auth.logout
	#app.post '/auth/deregister', auth(), apps.auth.deregister
	
	#geo
	app.get '/geo/notify/:lat/:lng/:id', apps.geo.notify
	app.get '/geo/near/:lat/:lng', apps.geo.near
	
	#notify
	#app.get '/notify'
	
	return
	
module.exports = routes