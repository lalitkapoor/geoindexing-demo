import pymongo

class Connection(object):
	def __init__(self, host="localhost", port=27017):
		self.host = host
		self.port = port
		self.connection = None
		
	def connect(self):
		self.connection = pymongo.Connection(self.host, self.port)
		
	def disconnect(self):
		self.connection.disconnect()
		
class Data(object):
	def __init__(self, connection, db):
		if connection.connection == None:
			raise TypeError("Connection To The Database Was Not Made")
		self.db = connection.connection[db]
		
	def _query(self, collection, query=None):
		if query==None:
			return self.db[collection].find()
		else:
			return self.db[collection].find(query)
			
	def _queryOne(self, collection, query=None):
		if query==None:
			return self.db[collection].find_one()
		else:
			return self.db[collection].find_one(query)
			
	def _insert(self, collection, obj):
		self.db[collection].insert(obj)
	
	#returns a cursor that can be iterated over
	def getHospitals(self, query=None):
		return self._query('h', query)
		
	def getUsers(self, query=None):
		return self._query('users', query)