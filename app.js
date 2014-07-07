
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var pins = require('./routes/getPins');
var addPin = require('./routes/addPin');
var pinDetail = require('./routes/pinDetail');
// var comments = require('./routes/getComments');
// var addComment = require('./routes/addComment');
// var deleteComment = require('./routes/deleteComment');
// var reportComment = require('./routes/reportComment');
var login = require('./routes/login');
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
app.use(express.bodyParser({ keepExtensions: true, uploadDir: "/Users/Llvve/mongodb/content" }));

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
app.post('/addPin', function(req, res){
	var data = req.param('data', null);
	if (data.length > 1e6) {
		req.connection.destroy();
		return;
	}
	console.log(req.body);
    console.log(req.files);
    
    var thumbnail = request.files.thumbnail;
	var videoCover = request.files.videocover;
	var content = request.files.content;
	
	console.log("thumbnail size "+thumbnail.size);
	console.log("thumbnail path "+thumbnail.path);
	console.log("thumbnail name "+thumbnail.name);
	console.log("thumbnail type "+thumbnail.type);
	
	console.log("videoCover size "+videoCover.size);
	console.log("videoCover path "+videoCover.path);
	console.log("videoCover name "+videoCover.name);
	console.log("videoCover type "+videoCover.type);
	
	console.log("content size "+content.size);
	console.log("content path "+content.path);
	console.log("content name "+content.name);
	console.log("content type "+content.type);
	
    console.log(req.files);
    
	addPin.initialize(res, mongodb, data);
});
app.post("/upload", function (request, response) {
    // request.files will contain the uploaded file(s),
    // keyed by the input name (in this case, "file")

    // show the uploaded file name
    
    

    response.end("upload complete");
});
app.get('/login', function(req, res){
	login.initialize(res, req.query.name, req.query.udid, mongodb);
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
