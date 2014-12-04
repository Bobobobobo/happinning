/**
 * login user and returns a unique id back to response
 */

//var identicon = require('identicon');
var shortId = require('shortid');
var messageBuilder = require('../happining_modules/messageBuilder');

function login(res, email, password, username, fbId, mongodb) {
	if (email === null || email === undefined) {
		res.send(messageBuilder.buildError('no email'));
		return;
	}else if (password === null || password === undefined) {
		res.send(messageBuilder.buildError('no password'));
		return;
	}else if (username === null || username === undefined) {
		res.send(messageBuilder.buildError('no username'));
		return;
	}
	
	var userImage = 'http://identicon.org/?t='+username+'&s=256'
	if (fbId !== null && fbId !== undefined) {
		userImage = 'http://graph.facebook.com/v2.2/'+fbId+'/picture?type=large';
	}
	
	var query = {email: email};
	
	var users = mongodb.collection('users');
	users.findOne(query, function (err, result) {
		if (err) {
			res.send(messageBuilder.buildError(err));
			return;
		}
		
		if (result !== null && result !== undefined) {
			if (result.password !== password) {
				res.send(messageBuilder.buildError('password is incorrect'));
				// TODO send message password not match and also send email for sending code to reset
				return;
			}
			if (result.username !== username) {
				users.update({_id: result._id}, {$set: {'username': username, 'userImage': userImage}},
						function(err, records) {
						if (err) {
							console.error('login.js - login'+err);
						}
					});
			}
			
			res.send(messageBuilder.buildComplete({_id: result._id, username: result.username, userImage: result.userImage}));
			return;
		}
		
		var code = shortId.generate();
		var document = {email: email, password: password, code: code, username: username, userImage: userImage};
		
		users.insert(document, function(err, records) {
			if (err) {
				res.send(messageBuilder.buildError(error));
				throw err;
			}
			console.log("Record added as "+records[0]._id);
			res.send(messageBuilder.buildComplete({_id: records[0]._id, username: records[0].username, userImage: records[0].userImage}));
		});
	});
}

module.exports = {
	initialize: function(res, email, password, username, fbId, mongodb) {
		login(res, email, password, username, fbId, mongodb);
	}
};
