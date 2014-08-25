
/*
 * GET pin detail req.
 */

var messageBuilder = require('../happining_modules/messageBuilder');

function getPin(res, mongodb, pinID, userID, ObjectID) {
	if (pinID === null || pinID === undefined) {
		res.send(messageBuilder.buildError('no pinID'));
		return;
	}
	
	var pins = mongodb.collection('pins');
	var users = mongodb.collection('users');
	if (userID !== null && userID !== undefined) {
		users.findOne(query, function (err, result) {
			if (err) {
				// do nothing
				return;
			}
			
			if (result !== null && result !== undefined) {
				mongodb.collection('pinviews').update(
						{_id: new ObjectID(pinID)},
						{$push:  {'usersId' : userID} },
						{ upsert: true },
				function(err, records) {
					if (err) {
						res.send(messageBuilder.buildError(err));
						return;
					}
					pins.update(
							{_id: new ObjectID(pinID)},
							{$set:  {'ratio' : 0.1} },
					function(err, records) {
						if (err) {
							res.send(messageBuilder.buildError(err));
							return;
						}
					});
				});
			}
		});
	}
	
	try {
		pins.findOne({ _id : new ObjectID(pinID) },
				function(err, result) {
					if (err) {
						res.send(messageBuilder.buildError(err));
						return;
					}else if (result === null || result == undefined) {
						res.send(messageBuilder.buildError('no pin found'));
						return;
					}
					users.findOne({_id: new ObjectID(result.userId)}, function (err, resultUser) {
						if (err) {
							res.send(messageBuilder.buildError(err));
							return;
						}
						result.username = resultUser.username;
						result.userImage = resultUser.userImage;
						res.send(messageBuilder.buildComplete(result));
					});
				});
	}catch (err) {
		res.send(messageBuilder.buildError('no pin found'));
	}
}

module.exports = {
  initialize: function(res, mongodb, pinID, userID, ObjectID) {
    getPin(res, mongodb, pinID, userID, ObjectID);
  }
};
