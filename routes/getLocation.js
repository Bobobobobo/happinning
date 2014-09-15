/**
 * Delete comment from commentID
 */

var messageBuilder = require('../happining_modules/messageBuilder');
var maxDistance = 1000;

function getLocation(res, latitude, longitude, keyword, page, mongodb) {
	var callback = function(err, records) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		
		var location = new Object();
//		location.location = records[0].location.subLocality;
		location.locations = records;
		res.send(messageBuilder.buildComplete(location));
	};
	
	if (page === null || page === undefined) {
		page = 1;
	}else {
		maxDistance = 100000;	
	}
	
	if (keyword !== null && keyword !== undefined) {
		mongodb.collection('location').find({ 'location.subLocality' : { $regex: keyword } }).skip( (page - 1) * 20 ).toArray(callback);
		return;
	}
	
	if (latitude == null || latitude === undefined || latitude === ''||
		longitude === null || longitude === undefined || longitude === '') {
		res.send(messageBuilder.buildError('no latitude, longitude'));
		return;
	}else {
		var query = { location :
		{ $near : 
			{ $geometry :{ type : "Point", coordinates : [parseFloat(longitude), parseFloat(latitude)]}, $maxDistance : parseInt(maxDistance) }
		}};
		
		if (page > 1) {
			mongodb.collection('location').find(query).skip( (page - 1) * 20 ).limit( 20 ).toArray(callback);
		}else {
			mongodb.collection('location').find(query).limit( 20 ).toArray(callback);
		}
	}
	
}

module.exports = {
	initialize: function(res, latitude, longitude, keyword, page, mongodb) {
		getLocation(res, latitude, longitude, keyword, page, mongodb);
	}
};
