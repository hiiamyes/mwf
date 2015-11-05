env = process.env.NODE_ENV || 'dev'
console.log env + ' mode'
collectionName = if env is 'production' then 'forecasts' else 'forecast_devs'

async = require 'async'
mongoose = require 'mongoose'
mountains = require '../../res/mountains.json'

mongoose.connect 'mongodb://yes:yes@ds035280.mongolab.com:35280/hiking'
connection = mongoose.connection
connection.on 'error', console.error.bind(console, 'connection error:')
connection.once 'open', (callback) ->
	async.series(
		dropCollection: (callback) ->
			connection.db.dropCollection collectionName, (err, result) ->
				callback(err, result)
		createCollection: (callback) ->
			connection.db.createCollection collectionName, (err, result) ->
				callback(err, result)
		insertDocuments: (callback) ->
			connection.db.collection(collectionName).insert mountains, (err, result) ->
				callback(err, result)
	, (err, results) ->
		if err then console.log 'err: ' + err
		else console.log 'done'
		process.exit()
	)
