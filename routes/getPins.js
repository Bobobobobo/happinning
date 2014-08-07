/**
 * Retrieve pins from lat, lng
 */

var messageBuilder = require('../happining_modules/messageBuilder');

function getPins(res, latitude, longitude, maxDistance, page, mongodb) {
	if (page === null || page === undefined) {
		page = 1;
	}
	
	var query = { location :
	{ $near : 
		{ $geometry :{ type : "Point", coordinates : [parseFloat(longitude), parseFloat(latitude)]}, $maxDistance : parseInt(maxDistance) }
	}};
	
	var callback = function(err, records) {
		if (err) {
			console.log("Error "+err);
			throw err;
		}
		console.log("Record get as "+records);
		res.send(messageBuilder.buildComplete(records));
	};
	
	if (page > 1) {
		mongodb.collection('pins').find(query).skip( (page - 1) * 20 ).limit( 20 ).toArray(callback);	
	}else {
		mongodb.collection('pins').find(query).limit( 20 ).toArray(callback);
	}

//	mongodb.collection('pins').find().toArray(function(err, records) {
//		if (err) {
//			throw err;
//		}
////		console.log("Record get as "+records[0]._id);
//		res.send(records);
//	});
}

module.exports = {
	initialize: function(res, latitude, longitude, maxDistance, page, mongodb) {
		getPins(res, latitude, longitude, maxDistance, page, mongodb);
	}
};
