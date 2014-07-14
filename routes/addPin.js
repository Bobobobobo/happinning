/**
 * New node file
 */

var __dir = require('../dir').dir;

function addPin(req, res, form, fs, mongodb) {
	
	var id;
	var record;
	
	form.on('part', function(part){
	    if(!part.filename) return;
	    size = part.byteCount;
	});
	
	form.on('file', function(name, file){
	    console.log('tmpPath: '+file.path);
	    console.log('fileSize: '+ (size / 1024));
	    if (name === 'thumb_image') {
	    	fileName = id + '_thumb_image.jpg';
	    }else if (name === 'image') {
	    	fileName = id + '_image.jpg';
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
			
			pins.insert(JSON.parse(value), function(err, records) {
				if (err) {
					throw err;
				}
				id = records[0]._id;
				record = records[0];
//				console.log("Record added as "+id);
				
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
	initialize: function(req, res, form, fs, mongodb) {
		addPin(req, res, form, fs, mongodb);
	}
};
