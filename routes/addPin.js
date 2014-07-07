/**
 * New node file
 */

function addPin(res, mongodb, jsPin) {
	var pins = mongodb.collection('pins');
	pins.ensureIndex({location:'2dsphere'}, function(err, records) {
		if (err) {
			throw err;
		}
	});
	pins.insert(JSON.parse(jsPin), function(err, records) {
		if (err) {
			throw err;
		}
		console.log("Record added as "+records[0]._id);
		res.send(records[0]);
	});
}

module.exports = {
	initialize: function(res, mongodb, jsPin) {
		addPin(res, mongodb, jsPin);
	}
};
