env = process.env.NODE_ENV || 'dev'
console.log env + ' mode' # production / dev
collectionName = if env is 'production' then 'forecasts' else 'forecast_dev'

express = require 'express'
mongoose = require 'mongoose'
async = require 'async'
crawler = require './util/crawler.js'

app = express()

app.set 'view engine', 'jade'
app.set 'views', __dirname + '/content'
app.use express.static(__dirname + '/../')

# routing
app.get '/', (req, res) ->
	res.render 'index'

# model
forecastSchema = mongoose.Schema({
	nameZh: String
	forecast: {
		week:[],
		hour:[]
	}
})
Forecast = mongoose.model collectionName, forecastSchema

# db connection
mongoose.connect 'mongodb://yes:yes@ds035280.mongolab.com:35280/hiking'
db = mongoose.connection
db.on 'error', console.error.bind(console, 'connection error:')
db.once 'open', (callback) ->		

	# crawler
	crawler.crawl Forecast, db

	# api
	app.get '/api/mountains', (req, res) ->
		Forecast.find {}, (err, docs) ->
			if err then	console.log 'api call err: ' + err
			else
				res.status(200).send docs
				console.log 'api call success'

# porting
port = Number process.env.PORT || 8080
app.listen port, () ->
	console.log 'Listening on ' + port
