/**
 * Retrieve pins from lat, lng
 */

var messageBuilder = require('../happining_modules/messageBuilder');
var async = require('async');

function getPins(res, latitude, longitude, maxDistance, page, mongodb, ObjectID) {
	if (latitude == null || latitude === undefined || latitude === ''||
		longitude === null || longitude === undefined || longitude === '') {
		res.send(messageBuilder.buildError('no latitude, longitude'));
		return;
	}
	if (maxDistance === null || maxDistance === undefined) {
		maxDistance = 10000;
	}
	if (page === null || page === undefined) {
		page = 1;
	}
	
	var callback = function(err, records) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		async.forEach(records, function (record, callback) {
			mongodb.collection('comments').findOne(
						{_id: ''+record._id},
						{_id: 0, 'commentsNum': 1}
				    ,
					function(err, result) {
						if (err || result === null || result == undefined) {
							record.commentsNum = 0; 
							return;
						}
						record.commentsNum = result.commentsNum;
					});
			mongodb.collection('users').findOne({_id: new ObjectID(record.userId)}, function (err, result) {
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
	        var pins = new Object();
	        pins.pins = records;
	        res.send(messageBuilder.buildComplete(pins));
	    });
	};

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
