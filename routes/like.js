
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
	
	var pins = mongodb.collection('pins');
	var colLike = mongodb.collection('likes');
	
	colLike.aggregate(
			[{$unwind:'$likes'},
			 {$match : {_id : pinID , 'likes.userId': jsLike.userId}},
			 {$project:{_id: 0, 'likes': 1}}],
			function(err, result) {
				if (result !== null && result !== undefined && result.length > 0) {
					if (jsLike.like == 1) {
						res.send(messageBuilder.buildComplete('like complete'));
					}else {
						addLikeQuery = {
							$pull: {'likes': {'userId': jsLike.userId}},
							$inc: {'likesNum': jsLike.like}
						};
						delete jsLike.like; // remove like from hash
						addRemoveLike(res, colLike, pinID, pins, addLikeQuery, false, ObjectID);
					}
									
				}else {
					if (jsLike.like == 1) {
						addLikeQuery = {
							$addToSet: {'likes' : jsLike},
							$inc: {'likesNum': jsLike.like}
						};
						delete jsLike.like; // remove like from hash
						addRemoveLike(res, colLike, pinID, pins, addLikeQuery, true, ObjectID);
					}else {
						res.send(messageBuilder.buildComplete('unlike complete'));
					}
				}
	});
}

function addRemoveLike(res, colLike, pinID, pins, addLikeQuery, isLike, ObjectID) {
	var ratio;
	if (isLike) {
		ratio = 0.3;
	}else {
		ratio = -0.3;
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
					{$inc:  {'ratio' : ratio} },
					function(err, records) {
						if (err) {
							return;
						}
					});
			
			res.send(messageBuilder.buildComplete('like complete'));
		});
}

module.exports = {
	initialize: function(res, pinID, mongodb, likeData, ObjectID) {
		like(res, pinID, mongodb, likeData, ObjectID);
	}
};
