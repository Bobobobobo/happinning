/**
 * Retrieve pins from lat, lng
 */

function getPins(res, latitude, longitude, maxDistance, mongodb) {
	mongodb.collection('pins').find(
			{ location :
				{ $near : 
					{ $geometry :{ type : "Point", coordinates : [parseFloat(longitude), parseFloat(latitude)]}, $maxDistance : parseInt(maxDistance) }
				}
			}).toArray(function(err, records) {
				if (err) {
					console.log("Error "+err);
					throw err;
				}
//				console.log("Record get as "+records[0]._id);
				res.send(records);
			});

//	mongodb.collection('pins').find().toArray(function(err, records) {
//		if (err) {
//			throw err;
//		}
////		console.log("Record get as "+records[0]._id);
//		res.send(records);
//	});
}

module.exports = {
	initialize: function(res, latitude, longitude, maxDistance, mongodb) {
		getPins(res, latitude, longitude, maxDistance, mongodb);
	}
};
