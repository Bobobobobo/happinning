
/*
 * GET pin detail page.
 */

function pinDetail(res, mongodb, pinID) {
	res.render('pinDetail', { title: 'Happinning', 
                            pin  : { pinID: pinID, 
                                     pinTitle: 'pin title', 
                                     owner: 'name',
                                     content: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                                     location : { lattitude : 1234, longitude : 4321 },
                                     timestamp : 'hh:mm:ss DD-MM-YYYY',
                                     comments : [ { comment : { name : 'commenter 1',
                                                                content : 'blah blah',
                                                                timestamp : 'hh:mm:ss DD-MM-YYYY'
                                                              },
                                                  },
                                                  { comment : { name : 'commenter 2',
                                                                content : 'meh meh meh',
                                                                timestamp : 'hh:mm:ss DD-MM-YYYY'
                                                              },
                                                  },
                                                ],
                                    } 
                          });
}

module.exports = {
	initialize: function(res, mongodb, pinID) {
		pinDetail(res, mongodb, pinID);
	}
};