/**
 * add Pin
 */

var __dir = require('../dir').dir;
var __urlPrefixImage = require('../dir').urlPrefixImage;
var __urlPrefixVideo = require('../dir').urlPrefixVideo;

var shortId = require('shortid');
var date = new Date();
var messageBuilder = require('../happining_modules/messageBuilder');

function addPinMultipart(req, res, form, fs, mongodb, ObjectID) {
	
	var id = ObjectID.createPk();
	var sId = shortId.generate();
	
	var hasImage = false;
	var hasVideo = false;
	
	form.on('part', function(part){
//		console.log('part: ' + part.name);
	    if(!part.filename) return;
	    size = part.byteCount;
	});
	
	form.on('file', function(name, file){
//	    console.log('fileSize: '+ (size / 1024));
		if(!fs.existsSync(__dir + id)){
			fs.mkdir(__dir + id, 0777, function(err){
				if(err){
					throw err;
				}
			});
		}
		
	    if (name === 'thumb') {
	    	fileName = sId + '_thumb.jpg';
	    }else if (name === 'image') {
	    	fileName = sId + '_image.jpg';
	    	hasImage = true;
	    }else if (name === 'video') {
	    	fileName = sId + '_video.mp4';
	    	hasVideo = true;
	    }
	    
//	    console.log('tmpPath: '+file.path);
//	    console.log('target_path: '+ __dir + id + '/' + fileName);
	    
	    fs.rename(file.path, __dir + id + '/' + fileName, function(err) {
	    	 if (err) throw err;
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
				
				var jsValue = JSON.parse(value);
				
				var query = {_id: new ObjectID(jsValue.userId)};
				
				users.findOne(query, function (err, result) {
					if (err) {
						res.send(messageBuilder.buildError(err));
						return;
					}
					
					if (result !== null && result !== 'undefined') {
						jsValue._id = id;
						jsValue.thumb = __urlPrefixImage + id + '/' + sId + '_thumb.jpg';
						jsValue.uploadDate = date.getTime();
						if (hasImage) {
							jsValue.image = __urlPrefixImage + id + '/' + sId + '_image.jpg';
							jsValue.video = '';
						}else if (hasVideo) {
							jsValue.image = '';
							jsValue.video = __urlPrefixVideo + id + '/' + sId + '_video.mp4';	
						}
						jsValue.username = result.username;
						jsValue.userImage = 'http://identicon.org/?t='+result.username+'&s=256';
						
						pins.insert(jsValue, function(err, records) {
							if (err) {
								throw err;
							}
							console.log("Record added as "+records[0]._id);
							res.send(records[0]);
						});
					}else {
						res.send(messageBuilder.buildError('no user connect with this post'));
					}
				});
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
	
	var jsValue = JSON.parse(jsPin);
	
	var query = {_id: new ObjectID(jsValue.userId)};
	
	users.findOne(query, function (err, result) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		
		if (result !== null && result !== 'undefined') {
			jsValue._id = ObjectID.createPk();
			jsValue.uploadDate = date.getTime();
			jsValue.image = '';
			jsValue.thumb = '';
			jsValue.video = '';
			jsValue.username = result.username;
			jsValue.userImage = 'http://identicon.org/?t='+result.username+'&s=256';
			
			pins.insert(jsValue, function(err, records) {
				if (err) {
					throw err;
				}
				console.log("Record added as "+records[0]._id);
				res.send(messageBuilder.buildComplete(records[0]));
			});	
		}else {
			res.send(messageBuilder.buildError('no user connect with this post'));
		}
	});
}

//function addUserPin(userId, pinId, mongodb) {
//	var usersPin = mongodb.collection('userspin');
//	usersPin.update();
//}

module.exports = {
	addPinMultipart: function(req, res, form, fs, mongodb, ObjectID) {
		addPinMultipart(req, res, form, fs, mongodb, ObjectID);
	},
	addPin: function(res, jsPin, mongodb, ObjectID) {
		addPin(res, jsPin, mongodb, ObjectID);
	}
};
