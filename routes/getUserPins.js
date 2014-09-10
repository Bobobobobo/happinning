/**
 * Retrieve pins from lat, lng
 */

var messageBuilder = require('../happining_modules/messageBuilder');
var async = require('async');

function getUserPins(res, userId, page, mongodb, ObjectID) {
	if (userId === null || userId === undefined || userId === '') {
		res.send(messageBuilder.buildError('no userId'));
		return;
	}
	if (page === null || page === undefined) {
		page = 1;
	}
	
	var callback = function(err, record) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		if (record === null || record === undefined) {
			res.send(messageBuilder.buildError('no user'));
			return;
		}
		
		var likes = mongodb.collection('likes');
		var comments = mongodb.collection('comments');
		var users = mongodb.collection('users');
		var pins = mongodb.collection('pins');
		
		var pinIds = [];
		async.forEach(record.pinIds.slice((page - 1) * 20, (page * 20)), function (record, callback) {
			pinIds.push(new ObjectID(record));
			callback();
		}, function(err) {
			if (err) res.send(messageBuilder.buildError(err));
        	pins.find({_id : {$in : pinIds}}).toArray(function(err, result) {
    			if (err || result === null || result === undefined) {
    				// do something
    				return;
    			}
    			async.forEachSeries(result, function (record, callback) {
//    				if (userId === null || userId === undefined) {
//    					record.isLike = false;
//    				}else {
//    					likes.findOne(
//    							{_id: ''+record._id, 'likes.userId': userId},
//    							{_id: 0, 'likes.userId': 1}
//    					    ,
//    						function(err, result) {
//    							if (err || result === null || result === undefined) {
//    								record.isLike = false; 
//    								return;
//    							}
//    							record.isLike = true;
//    						});	
//    				}
    				likes.findOne(
    						{_id: ''+record._id},
    						{_id: 0, 'likesNum': 1}
    				    ,
    					function(err, result) {
    						if (err || result === null || result === undefined) {
    							record.likesNum = 0; 
    							return;
    						}
    						record.likesNum = result.likesNum;
    					});
    				comments.findOne(
    							{_id: ''+record._id},
    							{_id: 0, 'commentsNum': 1}
    					    ,
    						function(err, result) {
    							if (err || result === null || result === undefined) {
    								record.commentsNum = 0; 
    								return;
    							}
    							record.commentsNum = result.commentsNum;
    						});
    				users.findOne({_id: new ObjectID(record.userId)}, function (err, result) {
    					if (err) {
    						callback(err);
    					}
    					record.username = result.username;
    					record.userImage = result.userImage;
//    					console.log('fin once '+record);
    					callback();
    				});
    			}, function(err) {
    				if (err) res.send(messageBuilder.buildError(err));
//    		        console.log('all finish '+records);
    		        var pins = new Object();
    		        pins.pins = result;
    		        res.send(messageBuilder.buildComplete(pins));
    		    });
    		}); 
		});
		
	};

	if (page > 1) {
		mongodb.collection('userpins').findOne({ _id : new ObjectID(userId)}, {_id: 0, 'pinIds': 1}, callback);
	}else {
		mongodb.collection('userpins').findOne({ _id : new ObjectID(userId)}, {_id: 0, 'pinIds': 1}, callback);
	}
}

module.exports = {
	initialize: function(res, userId, page, mongodb, ObjectID) {
		getUserPins(res, userId, page, mongodb, ObjectID);
	}
};
