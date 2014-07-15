
/*
 * GET pin detail req.
 */

function getPin(res, mongodb, pinID, userID) {
    mongodb.collection('pins').find(
      { pinID : pinID }).toArray(function(err, records) {
        if (err) {
//          throw err;
          console.log("Error "+err);
        }
//        console.log("Record get as "+records[0]._id);
        // TODO: check if pin is voted by userID
        // TODO: query media gallery and add to record
        res.send(records);
      });
}

module.exports = {
  initialize: function(res, mongodb, pinID, userID) {
    getPin(res, mongodb, pinID, userID);
  }
};
