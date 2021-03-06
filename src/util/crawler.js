// Generated by CoffeeScript 1.9.2
(function() {
  var async, cheerio, env, moment, mongoose, mountains, reCrawlTime, request;

  env = process.env.NODE_ENV || 'dev';

  async = require('async');

  moment = require('moment');

  request = require('request');

  cheerio = require('cheerio');

  mongoose = require('mongoose');

  mountains = require('../content/mountains.json');

  reCrawlTime = 1 * 60 * 60 * 1000;

  module.exports = {
    crawl: function(Forecast, db) {
      var crawlOnce;
      return (crawlOnce = function() {
        var j, len, mountain;
        console.log('crawling start');
        for (j = 0, len = mountains.length; j < len; j++) {
          mountain = mountains[j];
          async.parallel({
            nameZh: function(callback) {
              return callback(null, mountain.nameZh);
            },
            forecastsHour: function(callback) {
              return request(mountain.forecast.urlHour, function(err, res, body) {
                var $, dayAdd, forecastOneDay, forecasts, hourPre, iPop, pop;
                if (err) {
                  return callback('Hour crawling fail.', null);
                } else {
                  $ = cheerio.load(body);
                  forecasts = [];
                  forecastOneDay = [];
                  hourPre = 0;
                  dayAdd = 0;
                  pop = '';
                  iPop = 2;
                  $('tr:nth-child(2) td span').each(function(i) {
                    var hour, popEle, popNext;
                    hour = Number.parseInt($(this).text().split(':')[0]);
                    if (hourPre > hour) {
                      dayAdd++;
                      forecasts.push(forecastOneDay);
                      forecastOneDay = [];
                    }
                    popNext = '';
                    if (pop === '') {
                      popEle = $('tr:nth-child(8) td:nth-child(' + iPop + ')');
                      pop = popEle.text();
                      iPop++;
                      if (popEle.attr('colspan') === '2') {
                        popNext = pop;
                      }
                    }
                    forecastOneDay.push({
                      time: moment.utc($(this).text(), 'HH:mm').add(dayAdd, 'd').format(),
                      weather: {
                        img: 'http://www.cwb.gov.tw' + $('tr:nth-child(3) td:nth-child(' + (i + 2) + ')').find('img').attr('src'),
                        title: $('tr:nth-child(3) td:nth-child(' + (i + 2) + ')').find('img').attr('title')
                      },
                      probabilityOfPrecipitation: pop
                    });
                    hourPre = hour;
                    return pop = popNext;
                  });
                  forecasts.push(forecastOneDay);
                  return callback(null, forecasts);
                }
              });
            },
            forecastsWeek: function(callback) {
              return request(mountain.forecast.urlWeek, function(err, res, body) {
                var $, forecasts, i, k;
                if (err) {
                  return callback('Week crawling fail.', null);
                } else {
                  $ = cheerio.load(body);
                  forecasts = [];
                  for (i = k = 0; k <= 6; i = ++k) {
                    forecasts.push({
                      daytime: {
                        time: moment.utc($('tr:nth-child(1) td:nth-child(' + (i + 2) + ')').text().split('星')[0], 'MM/DD').format(),
                        weather: {
                          img: 'http://www.cwb.gov.tw' + $('tr:nth-child(3) td:nth-child(' + (2 * i + 2) + ')').find('img').attr('src'),
                          title: $('tr:nth-child(3) td:nth-child(' + (2 * i + 2) + ')').find('img').attr('title')
                        },
                        probabilityOfPrecipitation: $('tr:nth-child(9) td:nth-child(' + (2 * i + 2) + ')').text()
                      },
                      night: {
                        time: moment.utc($('tr:nth-child(1) td:nth-child(' + (i + 2) + ')').text().split('星')[0], 'MM/DD').format(),
                        weather: {
                          img: 'http://www.cwb.gov.tw' + $('tr:nth-child(3) td:nth-child(' + (2 * i + 3) + ')').find('img').attr('src'),
                          title: $('tr:nth-child(3) td:nth-child(' + (2 * i + 3) + ')').find('img').attr('title')
                        },
                        probabilityOfPrecipitation: $('tr:nth-child(9) td:nth-child(' + (2 * i + 3) + ')').text()
                      }
                    });
                  }
                  return callback(null, forecasts);
                }
              });
            }
          }, function(err, results) {
            if (err) {
              return console.log('crawling err: ' + err);
            } else {
              return Forecast.update({
                nameZh: results.nameZh
              }, {
                $set: {
                  'forecast.hour': results.forecastsHour,
                  'forecast.week': results.forecastsWeek
                }
              }, function(err, raw) {
                if (err) {
                  console.log('crawling err: ' + err);
                }
                return console.log(results.nameZh + ' crawling done');
              });
            }
          });
        }
        return setTimeout(crawlOnce, reCrawlTime);
      })();
    }
  };

}).call(this);
