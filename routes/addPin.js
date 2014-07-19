/**
 * add Pin
 */

var __dir = require('../dir').dir;
var __urlPrefixContent = require('../dir').urlPrefixContent;

var shortId = require('shortid');

function addPin(req, res, form, fs, mongodb, ObjectID) {
	
	var id;
	var sId = shortId.generate();
	var record;
	
	form.on('part', function(part){
	    if(!part.filename) return;
	    size = part.byteCount;
	});
	
	form.on('file', function(name, file){
	    console.log('tmpPath: '+file.path);
	    console.log('fileSize: '+ (size / 1024));
	    if (name === 'thumb_image') {
	    	fileName = sId + '_thumb_image.jpg';
	    }else if (name === 'image') {
	    	fileName = sId + '_image.jpg';
	    }
	    var tmp_path = file.path;
	    var target_path =  __dir + id + '/' + fileName;
	    
	    console.log('target_path: ' + target_path);
	    
	    fs.renameSync(tmp_path, target_path, function(err) {
	        console.error(err)
	    });
	    
        console.log(target_path);
        
        res.send(record);
	});
	
	form.on('field', function(name, value) {
		if (name === 'data') {
			if (value.length > 1e6) {
				req.connection.destroy();
				return;
			}
			
			var pins = mongodb.collection('pins');
			pins.ensureIndex({location:'2dsphere'}, function(err, records) {
				if (err) {
					throw err;
				}
			});
			
			id = ObjectID.createPk();
			var jsValue = JSON.parse(value);
			jsValue._id = id;
			jsValue.image = __urlPrefixContent + id + '/' + sId + '_image.jpg';
			jsValue.thumb = __urlPrefixContent + id + '/' + sId + '_thumb_image.jpg';
			
			pins.insert(jsValue, function(err, records) {
				if (err) {
					throw err;
				}
//				id = records[0]._id;
				record = records[0];
				console.log("Record added as "+record);
				
				if(!fs.existsSync(__dir + id)){
					fs.mkdir(__dir + id, 0777, function(err){
						if(err){ 
							console.error(err);
						}
					});
				}
			});
		}else {
			//TODO send message for no parameters 'data'
		}
	});
	form.parse(req);
}

module.exports = {
	initialize: function(req, res, form, fs, mongodb, ObjectID) {
		addPin(req, res, form, fs, mongodb, ObjectID);
	}
};
