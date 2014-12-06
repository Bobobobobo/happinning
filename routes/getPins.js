/**
 * Retrieve pins from lat, lng
 */

var messageBuilder = require('../happining_modules/messageBuilder');
var async = require('async');

function getPins(res, latitude, longitude, userId, maxDistance, page, sublocality, uid, mongodb, ObjectID) {
	
	var callback = function(err, records) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		
		var likes = mongodb.collection('likes');
		var comments = mongodb.collection('comments');
		var users = mongodb.collection('users');
		
		async.eachSeries(records, function (record, callback) {
			async.parallel([
			                function(callback){
			                	if (userId === null || userId === undefined) {
			        				record.isLike = false;
			        			}else {
			        				likes.findOne(
			        						{_id: ''+record._id, 'likes.userId': userId},
			        						{_id: 0, 'likes.userId': 1}
			        				    ,
			        					function(err, result) {
			        						if (err || result === null || result === undefined) {
			        							record.isLike = false;
			        						}else {
			        							record.isLike = true;	
			        						}
			        						callback();
			        					});	
			        			}
			                },
			                function(callback){
			                	likes.findOne(
			        					{_id: ''+record._id},
			        					{_id: 0, 'likesNum': 1}
			        			    ,
			        				function(err, result) {
			        					if (err || result === null || result === undefined) {
			        						record.likesNum = 0; 
			        					}else {
			        						record.likesNum = result.likesNum;	
			        					}
			        					callback();
			        				});
			                },
			                function(callback){
			                	comments.findOne(
			    						{_id: ''+record._id},
			    						{_id: 0, 'commentsNum': 1}
			    				    ,
			    					function(err, result) {
			    						if (err || result === null || result === undefined) {
			    							record.commentsNum = 0; 
			    						}else {
			    							record.commentsNum = result.commentsNum;	
			    						}
			    						callback();
			    					});
			                },
			                function(callback) {
			                	users.findOne({_id: new ObjectID(record.userId)}, function (err, result) {
									if (err) {
										record.username = '';
										record.userImage = '';	
									}
									record.username = result.username;
									record.userImage = result.userImage;
									callback();
								});
			                }
			            ],
	            // optional callback
			    function(err){
					callback(err);
				});
		}, function(err) {
			if (err) res.send(messageBuilder.buildError(err));
	        var pins = new Object();
	        pins.pins = records;
	        res.send(messageBuilder.buildComplete(pins));
	    });
	};

	var query = { location :
	{ $near : 
		{ $geometry :{ type : "Point", coordinates : [parseFloat(longitude), parseFloat(latitude)]}, $maxDistance : parseInt(maxDistance) }
	}};
	
	if (uid !== null && uid !== undefined && uid !== '') {
		query = {userId : uid};
	}
	
	if (sublocality !== null && sublocality !== undefined && sublocality !== '') {
		query = {"location.subLocality" : sublocality };
	}
	
	if (maxDistance === null || maxDistance === undefined) {
		maxDistance = 10000;
	}
	if (page === null || page === undefined) {
		page = 1;
	}
	
	if (latitude == null && latitude === undefined && latitude === ''&&
			longitude === null && longitude === undefined && longitude === '' && 
			uid === null && uid === undefined && uid === '' &&
			sublocality === null && sublocality === undefined && sublocality === '') {
		res.send(messageBuilder.buildError('invalid input'));
		return;
	}
	
	
	if (page > 1) {
		mongodb.collection('pins').find(query).skip( (page - 1) * 20 ).limit( 20 ).toArray(callback);
	}else {
		mongodb.collection('pins').find(query).limit( 20 ).toArray(callback);
	}
}

module.exports = {
	initialize: function(res, latitude, longitude, userId, maxDistance, page, sublocality, uid, mongodb, ObjectID) {
		getPins(res, latitude, longitude, userId, maxDistance, page, sublocality, uid, mongodb, ObjectID);
	}
};
