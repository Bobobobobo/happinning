/**
 * login user and returns a unique id back to response
 */

//var identicon = require('identicon');
var shortId = require('shortid');
var messageBuilder = require('../happining_modules/messageBuilder');

function login(res, username, udid, mongodb) {
	if (username === null || username === 'undefined') {
		res.send(messageBuilder.buildError('no username'));
		return;
	}else if (udid === null || udid === 'undefined') {
		res.send(messageBuilder.buildError('no udid'));
		return;		
	}
	
	var query = {username: username};
	
	var users = mongodb.collection('users');
	users.findOne(query, function (err, result) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		
		if (result !== null && result !== 'undefined') {
			if (result.udid !== udid) {
				res.send(messageBuilder.buildError('udid not match'));
				// TODO send message udid not match and also send email for sending code to reset
				return;
			}
			res.send(messageBuilder.buildComplete(result));
			return;
		}
		
		var code = shortId.generate();
		var document = {username: username, udid: udid, code: code};
		
		users.insert(document, function(err, records) {
			if (err) {
				res.send(messageBuilder.buildError(error));
				throw err;
			}
			console.log("Record added as "+records[0]._id+" username: "+username+" udid: "+udid+" code: "+code);
			res.send(messageBuilder.buildComplete(records[0]));
		});
	});
}

module.exports = {
	initialize: function(res, username, udid, mongodb) {
		login(res, username, udid, mongodb);
	}
};
