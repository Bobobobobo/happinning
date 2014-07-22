/**
 * login user and returns a unique id back to response
 */

var shortId = require('shortid');

function login(res, username, udid, mongodb) {
	// NYI
	// console.log("Error : Not yet implemented");
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
	var id = shortId.generate();
	var document = {username: username, udid: udid, code: id};
	
	users.insert(document, function(err, records) {
		if (err) {
			console.log("error in login " + err);
			throw err;
		}
		console.log("Record added as "+records[0]._id+" username: "+username+" udid: "+udid+" hID: "+id);
		res.send(id);
	});
}

module.exports = {
	initialize: function(res, username, udid, mongodb) {
		login(res, username, udid, mongodb);
	}
};
