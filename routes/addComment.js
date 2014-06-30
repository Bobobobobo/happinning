
/*
 * POST comment
 */

function addComment(res, pinID, mongodb, comment) {
	// NYI
	console.log("Error : Not yet implemented");
	// var comments = mongodb.collection('comments');
	// comments.ensureIndex(
	// 	{_id: 1}, function(err, records) {
	// 		if (err) {
	// 			throw err;
	// 		}	
	// 	}
	// );
	// comments.findAndModify(
	//   { _id: pinID }, // query
	//   {}},  // sort order
	//   {$push: JSON.parse(comment)}, // replacement, replaces only the field "hi"
	//   {}, // options
	//   function(err, object) {
	//       if (err){
	//           console.warn("addComment" + err.message);  // returns error if no matching object found
	//       }else{
	//           console.dir(object);
	//       }
	//   });
	// });

}

module.exports = {
	initialize: function(res, pinID, mongodb, comment) {
		addComment(res, pinID, mongodb, comment);
	}
};
