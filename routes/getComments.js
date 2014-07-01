/**
 * Retrieve comments from pinID
 */

function getComments(res, pinID, page, mongodb) {
	// NYI
	console.log("Error : Not yet implemented");
	// mongodb.collection('comments').find(
	// 		{ 
	// 			
	// 		}).toArray(function(err, records) {
	// 			if (err) {
	// 				console.log("Error "+err);
	// 			}
	// 			res.send(records);
	// 		});
}

module.exports = {
	initialize: function(res, pinID, page, mongodb) {
		getComments(res, pinID, page, mongodb);
	}
};
