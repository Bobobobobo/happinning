/**
 * add Pin
 */

var __dir = require('../dir').dir;
var __urlPrefixContent = require('../dir').urlPrefixContent;

var shortId = require('shortid');

function addPinMultipart(req, res, form, fs, mongodb, ObjectID) {
	
	var id = ObjectID.createPk();
	var sId = shortId.generate();
	
	form.on('part', function(part){
//		console.log('part: ' + part.name);
	    if(!part.filename) return;
	    size = part.byteCount;
	});
	
	form.on('file', function(name, file){
//	    console.log('tmpPath: '+file.path);
//	    console.log('fileSize: '+ (size / 1024));
		if(!fs.existsSync(__dir + id)){
			fs.mkdir(__dir + id, 0777, function(err){
				if(err){ 
					console.error(err);
				}
			});
		}
		
	    if (name === 'thumb') {
	    	fileName = sId + '_thumb.jpg';
	    }else if (name === 'image') {
	    	fileName = sId + '_image.jpg';
	    }
	    
	    var tmp_path = file.path;
	    var target_path =  __dir + id + '/' + fileName;
	    
//	    console.log('target_path: ' + target_path);
	    
	    fs.renameSync(tmp_path, target_path, function(err) {
	        console.error(err)
	    });
	    
	});
	
	form.parse(req, function(err, fields) {
		var hasData = false;
		Object.keys(fields).forEach(function(name) {
			if (name === 'data') {
				var value = fields.data;
				hasData = true;
				if (value.length > 1e6) {
					//TODO send message for error 'spam'
					return;
				}
					
				var pins = mongodb.collection('pins');
				pins.ensureIndex({location:'2dsphere'}, function(err, records) {
					if (err) {
						throw err;
					}
				});
				
				var jsValue = JSON.parse(value);
				jsValue._id = id;
				jsValue.image = __urlPrefixContent + id + '/' + sId + '_image.jpg';
				jsValue.thumb = __urlPrefixContent + id + '/' + sId + '_thumb.jpg';
				
				pins.insert(jsValue, function(err, records) {
					if (err) {
						// TODO send message insert error
						throw err;
					}
					console.log("Record added as "+records[0]._id);
					res.send(records[0]);
				});
			}
		  });
		  if(hasData) {
			  //TODO send message for no parameters 'data'
		  }
	});
}

function addPin(res, jsPin, mongodb, ObjectID) {
	var pins = mongodb.collection('pins');
	pins.ensureIndex({location:'2dsphere'}, function(err, records) {
		if (err) {
			throw err;
		}
	});
	
	var jsValue = JSON.parse(jsPin);
	jsValue._id = ObjectID.createPk();
	jsValue.image = '';
	jsValue.thumb = '';
	
	pins.insert(jsValue, function(err, records) {
		if (err) {
			// TODO send message insert error
			throw err;
		}
		console.log("Record added as "+records[0]._id);
		res.send(records[0]);
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
