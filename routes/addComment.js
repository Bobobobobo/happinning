
/*
 * POST comment
 */

var messageBuilder = require('../happining_modules/messageBuilder');

function addComment(res, pinID, mongodb, comment, ObjectID) {
	if (pinID === null || pinID === undefined) {
 		res.send(messageBuilder.buildError('no pinID'));
 	}
	
	var jsComment = JSON.parse(comment);
	jsComment._id = ObjectID.createPk();
	jsComment.commentDate = new Date().getTime();
	
	var pins = mongodb.collection('pins');
	var users = mongodb.collection('users');
	var pinComments = mongodb.collection('pincomments');
	
	mongodb.collection('comments').update(
			{ _id: pinID },
			{
				$push:  {'comments' : jsComment},
				$inc: {'commentsNum': 1 }
			},
			{ upsert: true },
		function(err, records) {
			if (err) {
				res.send(messageBuilder.buildError(err));
				return;
			}
			users.findOne({_id: new ObjectID(jsComment.userId)}, function (err, result) {
				if (err) {
					res.send(messageBuilder.buildError(err));
					return;
				}
				if (result === null || result === undefined) {
					res.send(messageBuilder.buildComplete(jsComment));
					return;
				}
				
				pinComments.update(
						{_id: new ObjectID(pinID)},
						{$addToSet:  {'usersId' : jsComment.userId} },
						{ upsert: true},
				function(err, result, detail) {
					if (err) {
						return;
					}
					if (detail.updatedExisting === false) {
						pins.update(
								{_id: new ObjectID(pinID)},
								{$inc:  {'ratio' : 0.2} },
							function(err, records) {
								if (err) {
									return;
								}
						});	
					}
				});
				
				jsComment.username = result.username;
				jsComment.userImage = result.userImage;
				console.log("Record added as "+jsComment);
				res.send(messageBuilder.buildComplete(jsComment));
			});
	});
}

module.exports = {
	initialize: function(res, pinID, mongodb, comment, ObjectID) {
		addComment(res, pinID, mongodb, comment, ObjectID);
	}
};
