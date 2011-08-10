exports = module.exports

exports.toLower = (txt)->
	txt.toLowerCase()

exports.isBlank = (obj)->
	if obj=='' or obj == undefined or obj == null
		return true
	return false

exports.randomSelect = (arr)->
	arr[Math.floor Math.random() * arr.length]

exports.randomInt = (max)->
	Math.floor Math.random() * max

exports.encodeToHex= (str)->
	r=""
	e=str.length
	c=0
	while c<e
		h=str.charCodeAt(c++).toString(16)
		while h.length<3
			h="0"+h
			r+=h
	return r

exports.decodeFromHex = (str)->
	r=""
	e=str.length
	while(e>=0)
		s=e-3
		r=String.fromCharCode("0x"+str.substring(s,e))+r
		e=s
	return r

exports.sendJSON = (res, json)->
	res.contentType 'application/json'
	res.send JSON.stringify json