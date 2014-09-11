/**
 * Delete comment from commentID
 */

var messageBuilder = require('../happining_modules/messageBuilder');
var maxDistance = 100;

function getLocation(res, latitude, longitude, mongodb) {
	if (latitude == null || latitude === undefined || latitude === ''||
		longitude === null || longitude === undefined || longitude === '') {
		res.send(messageBuilder.buildError('no latitude, longitude'));
		return;
	}
		
	var callback = function(err, records) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		
		if (records.length === 0) {
			if (maxDistance < 300) {
				console.log(maxDistance + ' ' + records);
				maxDistance = maxDistance + 100;
				getLocation(res, latitude, longitude, mongodb);	
			}else {
				var location = new Object();
				location.location = '';
				res.send(messageBuilder.buildComplete(location));		
			}
			return;
		}
		
		var location = new Object();
		location.location = records[0].location.subLocality;
		res.send(messageBuilder.buildComplete(location));
	};

	var query = { location :
	{ $near : 
		{ $geometry :{ type : "Point", coordinates : [parseFloat(longitude), parseFloat(latitude)]}, $maxDistance : parseInt(maxDistance) }
	}};
	
	mongodb.collection('pins').find(query).limit( 20 ).toArray(callback);
}

module.exports = {
	initialize: function(res, latitude, longitude, mongodb) {
		getLocation(res, latitude, longitude, mongodb);
	}
};
