
/*
 * GET pin detail page.
 */

function pinDetail(res, mongodb, pinID) {
	res.render('pinDetail', { title: 'Happinning', pinID: pinID });
}

module.exports = {
	initialize: function(res, mongodb, pinID) {
		pinDetail(res, mongodb, pinID);
	}
};