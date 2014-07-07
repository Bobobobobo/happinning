/**
 * login user and returns a unique id back to response
 */

var shortId = require('shortid');

function login(res, username, udid, mongodb) {
	// NYI
	// console.log("Error : Not yet implemented");
	var logins = mongodb.collection('usernames');
	logins.ensureIndex({username: 1}, function(err, records) {
		if (err) {
			throw err;
		}	
	});
	var id = shortId.generate();
	var document = {name: username, udid: udid, code: id};
	
	logins.insert(document, function(err, records) {
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
