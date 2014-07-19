
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var pins = require('./routes/getPins');
var pin = require('./routes/getPin');
var addPin = require('./routes/addPin');
var pinDetail = require('./routes/pinDetail');
// var comments = require('./routes/getComments');
// var addComment = require('./routes/addComment');
// var deleteComment = require('./routes/deleteComment');
// var reportComment = require('./routes/reportComment');
var login = require('./routes/login');
var http = require('http');
var path = require('path');
var util = require('util')
var multiparty = require("multiparty");
var fs = require('fs');

var MongoClient = require('mongodb').MongoClient;
var ObjectID = require('mongodb').ObjectID;
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
app.use(multiparty);

// development only
if ('development' === app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index);
app.get('/pinDetail', function(req, res){
	pinDetail.initialize(res, mongodb, req.query.pinID);
});
app.get('/users', user.list);
app.get('/getPins',  function(req, res){
	pins.initialize(res, req.query.latitude, req.query.longitude, req.query.maxdistance, mongodb);
});
app.get('/getPin', function(req, res){
	pin.initialize(res, mongodb, req.query.pinID, req.query.userID);
});
app.post('/addPin', function(req, res){
	var form = new multiparty.Form();	
	addPin.initialize(req, res, form, fs, mongodb, ObjectID);
});

app.get('/login', function(req, res){
	login.initialize(res, req.query.name, req.query.udid, mongodb);
});

app.get('/content/:id/:name', function(req, res){
	fs.readFile(require('./dir').dir + req.params.id + '/' + req.params.name, function (err, data) {
	if (err) {
		return res.end('Error loading index.html');
	}
    res.end(data);
  });
});


// app.get('/addComment', function(req, res){
// 	var data = req.param('data', null);
// 	if (data.length > 1e6) { // ??
// 		req.connection.destroy();
// 		return;
// 	}
// 	addComment.initialize(res, pinID, mongodb, data);
// });

// app.get('/getComments', function(req, res) {
// 	comments.initialize(res, req.query.pinID, req.query.page, mongodb);
// });

// app.get('/deleteComment', function(req, res){
// 	deleteComment.initialize(res, req.query.commentID, mongodb);
// });

// app.get('/reportComment', function(req, res){
// 	reportComment.initialize(res, req.query.commentID, mongodb);
// });

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
