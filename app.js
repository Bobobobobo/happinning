
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var userPins = require('./routes/getUserPins');
var pins = require('./routes/getPins');
var pin = require('./routes/getPin');
var location = require('./routes/getLocation');
var addPin = require('./routes/addPin');
var pinDetail = require('./routes/pinDetail');
var comments = require('./routes/getComments');
var addComment = require('./routes/addComment');
var like = require('./routes/like');
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
	pins.initialize(res, req.query.latitude, req.query.longitude, req.query.userId, req.query.maxdistance, req.query.page, mongodb, ObjectID);
});
app.get('/getPin', function(req, res){
	pin.initialize(res, mongodb, req.query.pinID, req.query.userId, ObjectID);
});
app.get('/getLocation',  function(req, res){
	location.initialize(res, req.query.latitude, req.query.longitude, mongodb);
});
app.get('/getUserPins', function(req, res){
	userPins.initialize(res, req.query.userId, req.query.page, mongodb, ObjectID);
});
app.post('/addPin', function(req, res){
	var data = req.param('data', null);
	if (data !== null && data !== undefined) {
		if (data.length > 1e6) {
			//TODO send message for error 'spam'
			return;
		}
		addPin.addPin(res, data, mongodb, ObjectID);
	}else {
		var form = new multiparty.Form();
		addPin.addPinMultipart(req, res, form, fs, mongodb, ObjectID);
	}
});
app.post('/login', function(req, res){
	login.initialize(res, req.param('email', null), req.param('password', null), req.param('username', null), mongodb);
});
app.get('/image/:id/:name', function(req, res){
	fs.readFile(require('./dir').dir + req.params.id + '/' + req.params.name, function (err, data) {
		if (err) {
			return res.end('Error loading index.html');
		}
		res.end(data);
	});
});
app.get('/video/:id/:name', function(req, res){
	var path = require('./dir').dir + req.params.id + '/' + req.params.name;
	var stat = fs.statSync(path);
	var total = stat.size;
	if (req.headers['range']) {
		var range = req.headers.range;
	    var parts = range.replace(/bytes=/, "").split("-");
	    var partialstart = parts[0];
	    var partialend = parts[1];
	 
	    var start = parseInt(partialstart, 10);
	    var end = partialend ? parseInt(partialend, 10) : total-1;
	    var chunksize = (end-start)+1;
	    console.log('RANGE: ' + start + ' - ' + end + ' = ' + chunksize);
	 
	    var file = fs.createReadStream(path, {start: start, end: end});
	    res.writeHead(206, { 'Content-Range': 'bytes ' + start + '-' + end + '/' + total, 'Accept-Ranges': 'bytes', 'Content-Length': chunksize, 'Content-Type': 'video/mp4' });
	    file.pipe(res);
	}else {
		console.log('ALL: ' + total);
	    res.writeHead(200, { 'Content-Length': total, 'Content-Type': 'video/mp4' });
	    fs.createReadStream(path).pipe(res);
	}
});
app.post('/addComment', function(req, res){
 	var data = req.param('data', null);
 	var pinID = req.param('pinID', null);
 	if (data.length > 1e6) { // ??
 		req.connection.destroy();
 		return;
 	}
 	addComment.initialize(res, pinID, mongodb, data, ObjectID);
});
app.get('/getComments', function(req, res) {
 	comments.initialize(res, req.query.pinID, req.query.page, mongodb, ObjectID);
});
app.post('/like', function(req, res){
 	var data = req.param('data', null);
 	var pinID = req.param('pinID', null);
 	if (data.length > 1e6) { // ??
 		req.connection.destroy();
 		return;
 	}
 	like.initialize(res, pinID, mongodb, data, ObjectID);
});

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
	mongodb.collection('pins').ensureIndex({location:'2dsphere'}, function(err, records) {
		if (err) {
			throw err;
		}
	});
	console.log("Connected to Database ");
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
