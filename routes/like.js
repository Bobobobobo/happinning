
/*
 * POST comment
 */

var messageBuilder = require('../happining_modules/messageBuilder');

function like(res, pinID, mongodb, like, ObjectID) {
	if (pinID === null || pinID === undefined) {
 		res.send(messageBuilder.buildError('no pinID'));
 	}
	
	var jsLike = JSON.parse(like);
	jsLike._id = ObjectID.createPk();
	jsLike.likeDate = new Date().getTime();
	
	if (jsLike.userId === null || jsLike.userId === undefined || jsLike.userId === '') {
		res.send(messageBuilder.buildError('no userId'));
		return;
	}
	
	var pins = mongodb.collection('pins');
	var colLike = mongodb.collection('likes');
	
	colLike.aggregate(
			[{$unwind:'$likes'},
			 {$match : {_id : pinID , 'likes.userId': jsLike.userId}},
			 {$project:{_id: 0, 'likes': 1}}],
			function(err, result) {
				if (result !== null && result !== undefined && result.length > 0) {
					if (jsLike.like == 1) {
						var like = new Object();
						like.isLike = true;
						like.likesNum = result.length;
						res.send(messageBuilder.buildComplete(like));
					}else {
						addLikeQuery = {
							$pull: {'likes': {'userId': jsLike.userId}},
							$inc: {'likesNum': -1}
						};
						delete jsLike.like; // remove like from object
						addRemoveLike(res, colLike, pinID, pins, addLikeQuery, false, ObjectID);
					}
				}else {
					if (jsLike.like == 1) {
						addLikeQuery = {
							$addToSet: {'likes' : jsLike},
							$inc: {'likesNum': jsLike.like}
						};
						delete jsLike.like; // remove like from object
						addRemoveLike(res, colLike, pinID, pins, addLikeQuery, true, ObjectID);
					}else {
						var like = new Object();
						like.isLike = false;
						like.likesNum = 0;
						res.send(messageBuilder.buildComplete(like));
					}
				}
	});
}

function addRemoveLike(res, colLike, pinID, pins, addLikeQuery, isLike, ObjectID) {
	var ratio;
	var like = new Object();
	if (isLike) {
		ratio = 0.3;
		likesNum = 1;
		like.isLike = true;
	}else {
		ratio = -0.3;
		likesNum = -1;
		like.isLike = false;
	}
	colLike.update(
			{ _id: pinID },
			addLikeQuery,
			{ upsert: true },
		function(err, result) {
			if (err) {
				res.send(messageBuilder.buildError(err));
				return;
			}
	
			pins.update(
					{_id: new ObjectID(pinID)},
					{$inc:  {'ratio' : ratio, 'likesNum' : likesNum} },
					function(err, records) {
						if (err) {
							res.send(messageBuilder.buildError(err));
							return;
						}
						
						colLike.findOne({ _id: pinID }, function(err, result) {
							if (err) {
								res.send(messageBuilder.buildError(err));
								return;
							}
							like.pinID = pinID;
							like.likesNum = result.likesNum;
							res.send(messageBuilder.buildComplete(like));
						});
					});
		});
}

module.exports = {
	initialize: function(res, pinID, mongodb, likeData, ObjectID) {
		like(res, pinID, mongodb, likeData, ObjectID);
	}
};
