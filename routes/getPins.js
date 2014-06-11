/**
 * Retrieve pins from lat, lng
 */

function getPins(res, latitude, longitude, maxDistance, mongodb) {
	mongodb.collection('pins').ensureIndex({coordinates:'2d'});
	mongodb.collection('pins').ensureIndex({coordinates:'2dsphere'});
	mongodb.collection('pins').find(
			{ coordinates :
				{ $near : [longitude, latitude]}
				{ $near : 
					{ $geometry :
						{ type : "Point",
						coordinates : [longitude, latitude]
						},
					$maxDistance : maxDistance
					}
				}
			}).toArray(function(err, records) {
				if (err) {
					throw err;
				}
//				console.log("Record get as "+records[0]._id);
				res.send(records);
			});
=======
//	mongodb.collection('pins').ensureIndex({coordinates:'2d'});
//	mongodb.collection('pins').find(
//			{ coordinates :
//				{ $near : [longitude, latitude]}
//			}).toArray(function(err, records) {
//				if (err) {
//					throw err;
//				}
////				console.log("Record get as "+records[0]._id);
//				res.send(records);
//			});
>>>>>>> FETCH_HEAD
	
//	mongodb.collection('pins').find().toArray(function(err, records) {
//		if (err) {
//			throw err;
//		}
//		res.send(records);
//	});
}

module.exports = {
	initialize: function(res, latitude, longitude, maxDistance, mongodb) {
		getPins(res, latitude, longitude, maxDistance, mongodb);
	}
};
