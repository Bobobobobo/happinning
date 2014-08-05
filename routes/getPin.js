
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
	if (userID !== null && userID !== undefined) {
		mongodb.collection('users').findOne(query, function (err, result) {
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
						return;
					}
					pins.update(
							{_id: new ObjectID(pinID)},
							{$set:  {'ratio' : 0.1} },
					function(err, records) {
						if (err) {
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
					res.send(messageBuilder.buildComplete(result));
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
