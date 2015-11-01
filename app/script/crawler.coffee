env = process.env.NODE_ENV || 'dev'
console.log env + ' mode' # production / dev
collectionName = if env is 'production' then 'forecasts' else 'forecast_dev'

async = require 'async'
moment = require 'moment'
request = require 'request'
cheerio = require 'cheerio'
mongoose = require 'mongoose'
mountains = require '../res/mountains.json'

forecastSchema = mongoose.Schema({
	nameZh: String
	forecast: {
		week:[],
		hour:[]
	}
})
Forecast = mongoose.model collectionName, forecastSchema

mongoose.connect 'mongodb://yes:yes@ds035280.mongolab.com:35280/hiking'
connection = mongoose.connection
connection.on 'error', console.error.bind(console, 'connection error:')
connection.once 'open', (callback) ->
	for mountain in mountains
		async.parallel({
			nameZh: (callback) -> callback null, mountain.nameZh
			,
			forecastsHour: (callback) ->
				request mountain.forecast.urlHour, (err, res, body) ->
					if err then callback 'Hour crawling fail.', null
					else
						$ = cheerio.load body

						forecasts = []		
						forecastOneDay = []				
						hourPre = 0
						dayAdd = 0
						pop = ''
						iPop = 2

						# parser
						$('tr:nth-child(2) td span').each (i) ->
							hour = Number.parseInt $(this).text().split(':')[0]
							if hourPre > hour
								dayAdd++				
								forecasts.push forecastOneDay
								forecastOneDay = []

							popNext = ''
							if pop == ''
								popEle = $('tr:nth-child(8) td:nth-child('+iPop+')')
								pop = popEle.text()
								iPop++
								if popEle.attr('colspan') == '2'
									popNext = pop

							forecastOneDay.push(
								time: moment($(this).text(), 'HH:mm').add(dayAdd, 'd').format()
								weather: 
									img: 'http://www.cwb.gov.tw' + $('tr:nth-child(3) td:nth-child('+(i+2)+')').find('img').attr('src') 
									title: $('tr:nth-child(3) td:nth-child('+(i+2)+')').find('img').attr('title')
								probabilityOfPrecipitation: pop
							)
															
							hourPre = hour
							pop = popNext

						# push the forecast of last day
						forecasts.push forecastOneDay

						# return
						callback null, forecasts
			,
			forecastsWeek: (callback) ->
				request mountain.forecast.urlWeek, (err, res, body) ->
					if err then callback 'Week crawling fail.', null
					else
						$ = cheerio.load body

						forecasts = []
						
						# parser
						for i in [0..6]
							forecasts.push(
								daytime:
									time: moment().add(i,'d').format()
									weather: 
										img: 'http://www.cwb.gov.tw' + $('tr:nth-child(3) td:nth-child('+(2*i+2)+')').find('img').attr('src')
										title: $('tr:nth-child(3) td:nth-child('+(2*i+2)+')').find('img').attr('title')
									probabilityOfPrecipitation: $('tr:nth-child(9) td:nth-child('+(2*i+2)+')').text()
								night:
									time: moment().add(i,'d').format()
									weather: 
										img: 'http://www.cwb.gov.tw' + $('tr:nth-child(3) td:nth-child('+(2*i+2)+')').find('img').attr('src')
										title: $('tr:nth-child(3) td:nth-child('+(2*i+3)+')').find('img').attr('title')
									probabilityOfPrecipitation: $('tr:nth-child(9) td:nth-child('+(2*i+3)+')').text()
							)

						# return
						callback null, forecasts

		},
		(err, results) ->
			if err then console.log 'Crawling fail: ' + err
			else
				Forecast.update(
					{
						nameZh: results.nameZh
					},{
						$set: {
							'forecast.hour': results.forecastsHour
							'forecast.week': results.forecastsWeek
						}
					},
					(err, raw) ->
						if (err) then console.log 'gg'
						console.log 'done'
						# console.log('The raw response from Mongo was ', raw);
				)
		)
