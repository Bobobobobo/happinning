
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var pins = require('./routes/getPins');
var addPin = require('./routes/addPin');
var http = require('http');
var path = require('path');

var MongoClient = require('mongodb').MongoClient;
var mongodb;
var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.json());
app.use(express.urlencoded());
app.use(express.methodOverride());
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' === app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index);
app.get('/users', user.list);
app.get('/getPins',  function(req, res){
	pins.initialize(res, req.query.latitude, req.query.longitude, req.query.maxdistance, mongodb);
});
app.post('/addPin', function(req, res){
	var data = req.param('data', null);
	if (data.length > 1e6) {
		req.connection.destroy();
		return;
	}
	addPin.initialize(res, mongodb, data);
});

MongoClient.connect('mongodb://127.0.0.1:27017/test', function(err, db) {
	if (err) {
		throw err;
	}
	mongodb = db;
	console.log("Connected to Database ");
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
