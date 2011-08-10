import operator
import time
import unicodedata
from geopy import geocoders
from geopy.geocoders.google import GQueryError, GTooManyQueriesError
from pprint import pprint
from pymongo.objectid import ObjectId
import mongo

__cache = {}

connm = mongo.Connection('localhost', 1212)
connm.connect()
mongoapi = mongo.Data(connm,'mongodc')

g=geocoders.Google('ABQIAAAAk9h3SuouSUwetLBFCjFtrhQ0qiatXSb9ypSqZ9gvVle-IeNWTRTlbKx6EHmO8VureqSwGPuoRs8zWw')

hospitals = mongoapi.getHospitals({"loc": {"$exists": False}})
count = 0
errors = []
for hospital in hospitals:
	cityStateZipCountry = hospital['City'].strip()+", "+hospital['State'].strip()+" "+str(hospital["ZIP Code"])+", USA"
	cityStateCountry = hospital['City'].strip()+", "+hospital['State'].strip()+", USA"
	
	if len(str(hospital["ZIP Code"]))<5:
		continue
	lookup = hospital["Hospital Name"].strip()+" "+hospital['City'].strip()+", "+hospital['State'].strip()+" "+str(hospital["ZIP Code"])
	lookup = unicodedata.normalize('NFKD', lookup).encode('ascii', 'ignore')
	#lookup.replace(u'\xa0', '')
	print lookup
	c=0
	ok=True
	try:
		gen = g.geocode(lookup, exactly_one=False)
		# pprint(gen)
		# print len(gen)
		# print type(gen)
		# print dir(gen)
		place, (lat, lng) = gen.pop()
		if (place.upper() == cityStateZipCountry.upper()) or (place.upper() == cityStateCountry):
			raise GQueryError #Columbus, OH 43210, USA
	except GQueryError:
		try:
			hospital["Address 1"] = hospital["Address 1"].replace("U S", "U.S.")
			lookup = hospital["Address 1"].strip()+" "+hospital['City'].strip()+", "+hospital['State'].strip()+" "+str(hospital["ZIP Code"])
			lookup = unicodedata.normalize('NFKD', lookup).encode('ascii', 'ignore')
			#lookup = lookup.replace(u'\xa0', '')
			print lookup
			gen = g.geocode(lookup, exactly_one=False)
			place, (lat, lng) = gen.pop()
			if (place.upper() == cityStateZipCountry.upper()) or (place.upper() == cityStateCountry):
				raise GQueryError #Columbus, OH 43210, USA
		except GQueryError:
			ok=False
			errors.append(hospital)
			print "ERROR UNABLE TO LOCATE HOSPITAL", hospital["Hospital Name"]
			print ""
	if ok==True:
		print "%s: %.5f, %.5f" % (place, lat, lng)
		print ""
		place = unicodedata.normalize('NFKD', place).encode('ascii', 'ignore')
		mongoapi.db.hospitals.update({"_id":hospital['_id']}, {"$set":{"loc": [lat, lng], "gAddress": str(place)}})
	time.sleep(0.3)
print count
pprint(errors)
	#print "%s: %.5f, %.5f" % (place, lat, lng)
