/**
 * Retrieve comments from pinID
 */

var messageBuilder = require('../happining_modules/messageBuilder');
var async = require('async');

function getComments(res, pinID, page, mongodb, ObjectID) {
	if (pinID === null || pinID === undefined) {
 		res.send(messageBuilder.buildError('no pinID'));
 	}
	if (page === null || page === undefined) {
 		page = 1;
 	}
	
	try {
		var users = mongodb.collection('users');
		mongodb.collection('comments').findOne({ _id : pinID },
				function(err, result) {
					if (err) {
						res.send(messageBuilder.buildError(err));
						return;
					}else if (result === null || result == undefined) {
						res.send(messageBuilder.buildComplete({ _id : pinID, comments : [] }));
						return;
					}
					async.forEach(result.comments, function (record, callback) {
						users.findOne({_id: new ObjectID(record.userId)}, function (err, result) {
							if (err) {
								callback(err);
							}
							if (result !== null && result !== undefined) {
								record.username = result.username;
								record.userImage = result.userImage;	
							}else {
								record.username = '';
								record.userImage = '';
							}
							callback();
						});
					}, function(err) {
				        if (err) messageBuilder.buildError(err);
				        res.send(messageBuilder.buildComplete(result));
				    });
				});
	}catch (err) {
		res.send(messageBuilder.buildError('no comment found'));
	}
}

module.exports = {
	initialize: function(res, pinID, page, mongodb, ObjectID) {
		getComments(res, pinID, page, mongodb, ObjectID);
	}
};
