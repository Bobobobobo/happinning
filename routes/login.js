/**
 * login user and returns a unique id back to response
 */

var shortId = require('shortid');

function login(res, username, udid, mongodb) {
	if (username === null || username === 'undefined') {
		// TODO send message no username
		return;
	}else if (udid === null || udid === 'undefined') {
		// TODO send message no udid
		return;		
	}
	
	var users = mongodb.collection('users');
	users.ensureIndex({username: 1}, function(err, records) {
		if (err) {
			throw err;
		}	
	});
	
	var query = { username: username};
	users.findOne(query, function (err, result) {
		if (err) {
			// TODO send message error try again
			return;
		}
		
		if (result.username !== null && result.username !== 'undefined') {
			if (result.udid !== udid) {
				res.status(404);
				res.send('error');
				// TODO send message udid not equals and also email for sending short id
				return;
			}
			res.send(result);
			return;
		}
		
		var id = shortId.generate();
		var document = {username: username, udid: udid, code: id};
		
		users.insert(document, function(err, records) {
			if (err) {
				// TODO send message error try again
				console.log("error in login " + err);
				throw err;
			}
			console.log("Record added as "+records[0]._id+" username: "+username+" udid: "+udid+" hID: "+id);
			res.send(records[0]);
		});
	});
}

module.exports = {
	initialize: function(res, username, udid, mongodb) {
		login(res, username, udid, mongodb);
	}
};
