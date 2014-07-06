/**
 * login user and returns a unique id back to response
 */

var shortId = require('shortid');

function login(res, user, udid, mongodb) {
	// NYI
	// console.log("Error : Not yet implemented");
	var logins = mongodb.collection('users');
	logins.ensureIndex({user: 1}, function(err, records) {
		if (err) {
			throw err;
		}	
	});
	var id = shortId.generate();
	var document = {name: user, udid: udid, code: id};

	logins.insert(document, function(err, records) {
		if (err) {
			throw err;
		}
		console.log("Record added as "+records[0]._id);
		res.send(id);
	});
}

module.exports = {
	initialize: function(res, user, udid, mongodb) {
		login(res, user, udid, mongodb);
	}
};
