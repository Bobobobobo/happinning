/**
 * login user and returns a unique id back to response
 */

 var shortid = requires('../shortid');

function login(res, user, udid, mongodb) {
	// NYI
	console.log("Error : Not yet implemented");
	// pins.ensureIndex({user: 1}, function(err, records) {
	// 	if (err) {
	// 		throw err;
	// 	}	
	// });
	// pins.insert(JSON.parse(jsPin), function(err, records) {
	// 	if (err) {
	// 		throw err;
	// 	}
	// 	console.log("Record added as "+records[0]._id);
	// 	res.send(records[0]);
	// });
}

module.exports = {
	initialize: function(res, user, udid, mongodb) {
		login(res, user, udid, mongodb);
	}
};
