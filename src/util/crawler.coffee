env = process.env.NODE_ENV || 'dev'
# console.log env + ' mode' # production / dev

async = require 'async'
moment = require 'moment'
request = require 'request'
cheerio = require 'cheerio'
mongoose = require 'mongoose'
mountains = require '../content/mountains.json'

reCrawlTime = 1 * 60 * 60 * 1000; # 1hr

module.exports = {
	crawl: (Forecast, db) ->
		do crawlOnce = ->
			console.log 'crawling start'

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
										time: moment($(this).text() + '+0800', 'HH:mm').add(dayAdd, 'd').format()
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
											time: moment($('tr:nth-child(1) td:nth-child('+(i+2)+')').text().split('星')[0] + '+0800', 'MM/DD').format()
											weather: 
												img: 'http://www.cwb.gov.tw' + $('tr:nth-child(3) td:nth-child('+(2*i+2)+')').find('img').attr('src')
												title: $('tr:nth-child(3) td:nth-child('+(2*i+2)+')').find('img').attr('title')
											probabilityOfPrecipitation: $('tr:nth-child(9) td:nth-child('+(2*i+2)+')').text()
										night:
											time: moment($('tr:nth-child(1) td:nth-child('+(i+2)+')').text().split('星')[0] + '+0800', 'MM/DD').format()
											weather: 
												img: 'http://www.cwb.gov.tw' + $('tr:nth-child(3) td:nth-child('+(2*i+2)+')').find('img').attr('src')
												title: $('tr:nth-child(3) td:nth-child('+(2*i+3)+')').find('img').attr('title')
											probabilityOfPrecipitation: $('tr:nth-child(9) td:nth-child('+(2*i+3)+')').text()
									)

								# return
								callback null, forecasts

				},
				(err, results) ->
					if err then console.log 'crawling err: ' + err
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
								if (err) then console.log 'crawling err: ' + err
								console.log results.nameZh + ' crawling done'
								# console.log('The raw response from Mongo was ', raw);
						)
				)

			setTimeout crawlOnce, reCrawlTime
}


