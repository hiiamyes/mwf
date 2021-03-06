// Generated by CoffeeScript 1.9.2
(function() {
  var Forecast, app, async, collectionName, crawler, db, env, express, forecastSchema, mongoose, port;

  if (process.env.NODE_ENV === 'production') {
    require('newrelic');
  }

  env = process.env.NODE_ENV || 'dev';

  console.log(env + ' mode');

  collectionName = env === 'production' ? 'forecasts' : 'forecast_dev';

  express = require('express');

  mongoose = require('mongoose');

  async = require('async');

  crawler = require('./util/crawler.js');

  app = express();

  app.set('view engine', 'jade');

  app.set('views', __dirname + '/content');

  app.use(express["static"](__dirname + '/../'));

  app.get('/', function(req, res) {
    return res.render('index');
  });

  forecastSchema = mongoose.Schema({
    nameZh: String,
    forecast: {
      week: [],
      hour: []
    }
  });

  Forecast = mongoose.model(collectionName, forecastSchema);

  mongoose.connect('mongodb://yes:yes@ds035280.mongolab.com:35280/hiking');

  db = mongoose.connection;

  db.on('error', console.error.bind(console, 'connection error:'));

  db.once('open', function(callback) {
    crawler.crawl(Forecast, db);
    return app.get('/api/mountains', function(req, res) {
      return Forecast.find({}, function(err, docs) {
        if (err) {
          return console.log('api call err: ' + err);
        } else {
          res.status(200).send(docs);
          return console.log('api call success');
        }
      });
    });
  });

  port = Number(process.env.PORT || 8080);

  app.listen(port, function() {
    return console.log('Listening on ' + port);
  });

}).call(this);
