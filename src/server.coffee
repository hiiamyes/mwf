env = process.env.NODE_ENV || 'dev'
console.log env + ' mode' # production / dev
collectionName = if env is 'production' then 'forecasts' else 'forecast_dev'

express = require 'express'
mongoose = require 'mongoose'
async = require 'async'

app = express()

app.set 'view engine', 'jade'
app.set 'views', __dirname + '/app/view'
app.use express.static(__dirname + '/')

# routing
app.get '/', (req, res) ->
	res.render 'index'

# crawler
crawler = require './hut/scripts/crawler.js'
crawler.crawl MongoClient, mongoServerUrl, collectionName

# api
forecastSchema = mongoose.Schema({
	# nameZh: String
	forecastHour: {}
	forecastDay: {}
})
Forecast = mongoose.model collectionName, forecastSchema

app.get '/api/mountains', (req, res) ->
	mongoose.connect 'mongodb://yes:yes@ds035280.mongolab.com:35280/hiking'
	db = mongoose.connection
	db.on 'error', console.error.bind(console, 'connection error:')
	db.once 'open', (callback) ->		
		
		async.series {
			query: (callback) ->
				Forecast.find {}, (err, docs) ->
					if err
						console.log 'gg'
						callback null
					else
						res.status(200).send docs
						callback null
			,
			close: (callback) ->
				mongoose.disconnect()
				callback null
		},
		(err, results) ->
			console.log 'ya'

# porting
port = Number process.env.PORT || 8080
app.listen port, () ->
	console.log 'Listening on ' + port
