/**
 * Retrieve pins from lat, lng
 */

var messageBuilder = require('../happining_modules/messageBuilder');
var async = require('async');

function getPins(res, latitude, longitude, maxDistance, page, mongodb, ObjectID) {
	if (page === null || page === undefined) {
		page = 1;
	}
	
	var users = mongodb.collection('users');
	
	var callback = function(err, records) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		async.forEach(records, function (record, callback) {
			users.findOne({_id: new ObjectID(record.userId)}, function (err, result) {
				if (err) {
					callback(err);
				}
				record.username = result.username;
				record.userImage = result.userImage;
//				console.log('fin once '+record);
				callback();
			});
		}, function(err) {
	        if (err) messageBuilder.buildError(err);
//	        console.log('all finish '+records);
	        res.send(messageBuilder.buildComplete(records));
	    });
	};

	mongodb.collection('pins').ensureIndex({coordinates:'2dsphere'}, function(err) {
		if(err) return next(err);
		console.log('err ' + err);
	});
	
	var query = { location :
	{ $near : 
		{ $geometry :{ type : "Point", coordinates : [parseFloat(longitude), parseFloat(latitude)]}, $maxDistance : parseInt(maxDistance) }
	}};
	
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
	initialize: function(res, latitude, longitude, maxDistance, page, mongodb, ObjectID) {
		getPins(res, latitude, longitude, maxDistance, page, mongodb, ObjectID);
	}
};
