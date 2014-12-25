/**
 * add Pin
 */

var __dir = require('../dir').dir;
var __urlPrefixImage = require('../dir').urlPrefixImage;
var __urlPrefixVideo = require('../dir').urlPrefixVideo;

var shortId = require('shortid');
var messageBuilder = require('../happining_modules/messageBuilder');
var async = require('async');

function addPinMultipart(req, res, form, fs, mongodb, ObjectID) {
	
	var id = ObjectID.createPk();
	var sId = shortId.generate();
	
	var hasImage = false;
	var hasVideo = false;
	
//	form.on('part', function(part){
//		console.log('part: ' + part.name);
//	    if(!part.filename) return;
//	    size = part.byteCount;
//	});
	
	form.on('file', function(name, file){
//	    console.log('fileSize: '+ (size / 1024));
		var fileName;
  	  	if (name === 'thumb') {
  		  fileName = sId + '_thumb.jpg';
  	  	}else if (name === 'image') {
  		  fileName = sId + '_image.jpg';
  		  hasImage = true;
  	  	}else if (name === 'video') {
  		  fileName = sId + '_video.mp4';
  		  hasVideo = true;
  	  	}
//  	console.log(id+' '+name);
		async.series([
		      //Create folder first
		      function(callback) {
		    	  if(!fs.existsSync(__dir + id)) {
		    		  fs.mkdir(__dir + id, 0777, function(err){
		    			  if (err) return callback(err);
		    			  callback();
		    		  });
		    	  }else {
		    		  callback();
		    	  }
		      },
		      //Rename and move file from tmp to folder
		      function(callback) {
//		    	  console.log(id+' '+fileName);
		    	  fs.rename(file.path, __dir + id + '/' + fileName, function(err) {
		    		  if (err) return callback(err);
		    	  });
		      }
		      ],
		      function(err) { //This function gets called after the two tasks have called their "task callbacks"
				if (err) return next(err);
		});
	});
	
	form.parse(req, function(err, fields) {
		var hasData = false;			  
		Object.keys(fields).forEach(function(name) {
			if (name === 'data') {
				var value = fields.data;
				hasData = true;
				if (value.length > 1e6) {
					res.send(messageBuilder.buildError('length unacceptable'));
					return;
				}
				
				var pins = mongodb.collection('pins');
				var users = mongodb.collection('users');
//				pins.ensureIndex({location:'2dsphere'}, function(err, records) {
//					if (err) {
//						throw err;
//					}
//				});
				try {
					var jsValue = JSON.parse(value);
					var query = {_id: new ObjectID(jsValue.userId)};
					users.findOne(query, function (err, result) {
						if (err) {
							res.send(messageBuilder.buildError(err));
							return;
						}
						
						if (result !== null && result !== undefined) {
							jsValue._id = id;
							jsValue.thumb = __urlPrefixImage + id + '/' + sId + '_thumb.jpg';
							jsValue.uploadDate = new Date().getTime();
							if (hasImage) {
								jsValue.image = __urlPrefixImage + id + '/' + sId + '_image.jpg';
								jsValue.video = '';
							}else if (hasVideo) {
								jsValue.image = '';
								jsValue.video = __urlPrefixVideo + id + '/' + sId + '_video.mp4';	
							}else {
								jsValue.image = '';
								jsValue.video = '';
							}
							jsValue.ratio = 0.0;
							
							pins.insert(jsValue, function(err, records) {
								if (err) {
									res.send(messageBuilder.buildError(err));
									return;
								}
								console.log("Record added as "+records[0]._id);
								records[0].username = result.username;
								records[0].userImage = result.userImage;
								records[0].isLike = false;
								records[0].likesNum = 0;
								records[0].commentsNum = 0;
								
								var pins = new Object();
						        pins.pins = [records[0]];
								res.send(messageBuilder.buildComplete(pins));
							});
							
							addKeywordLocation(jsValue.location, mongodb, ObjectID);
						}else {
							res.send(messageBuilder.buildError('no user connect with this post'));
						}
					});
				}catch (e) {
					res.send(messageBuilder.buildError(e));
				}
			}
		  });
		  if(!hasData) {
			  res.send(messageBuilder.buildError('param data is required'));
		  }
	});
}

function addPin(res, jsPin, mongodb, ObjectID) {
	var pins = mongodb.collection('pins');
	var users = mongodb.collection('users');
//	pins.ensureIndex({location:'2dsphere'}, function(err, records) {
//		if (err) {
//			throw err;
//		}
//	});
	
	try {
		var jsValue = JSON.parse(jsPin);
		var query = {_id: new ObjectID(jsValue.userId)};
		users.findOne(query, function (err, result) {
			if (err) {
				res.send(messageBuilder.buildError(err));
				return;
			}
			
			if (result !== null && result !== undefined) {
				jsValue._id = ObjectID.createPk();
				jsValue.uploadDate = new Date().getTime();
				jsValue.image = '';
				jsValue.thumb = '';
				jsValue.video = '';
				jsValue.ratio = 0.0;
				
				pins.insert(jsValue, function(err, records) {
					if (err) {
						res.send(messageBuilder.buildError(err));
						return;
					}
					console.log("Record added as "+records[0]._id);
					records[0].username = result.username;
					records[0].userImage = result.userImage;
					records[0].isLike = false;
					records[0].likesNum = 0;
					records[0].commentsNum = 0;
					
					var pins = new Object();
			        pins.pins = [records[0]];
					res.send(messageBuilder.buildComplete(pins));
				});
				
				addKeywordLocation(jsValue.location, mongodb, ObjectID);
			}else {
				res.send(messageBuilder.buildError('no user connect with this post'));
			}
		});	
	}catch (e) {
		res.send(messageBuilder.buildError(e));
	}
}

function addKeywordLocation(location, mongodb, ObjectID) {
	if (location.subLocality === null || location.subLocality === undefined || location.subLocality === '') {
		return;
	}
	
	var objLocation = new Object();
	objLocation._id = ObjectID.createPk();
	objLocation.location = location;
	
	mongodb.collection('location').findOne({'location.subLocality': location.subLocality}, function (err, result) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		if (result === null || result === undefined) {
			mongodb.collection('location').insert(objLocation,
			function(err, records) {
				if (err) {
					console.error('addPin.js - addKeywordLocation'+err);
				}
			});
		}
	});
}

module.exports = {
	addPinMultipart: function(req, res, form, fs, mongodb, ObjectID) {
		addPinMultipart(req, res, form, fs, mongodb, ObjectID);
	},
	addPin: function(res, jsPin, mongodb, ObjectID) {
		addPin(res, jsPin, mongodb, ObjectID);
	}
};
