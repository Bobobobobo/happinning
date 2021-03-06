/**
 * build return message
 */

function complete(message) {
	message.status = 200;
	message.message = 'success';
	return message; 
}

function error(message) {
	var jsMessage = new Object();
	jsMessage.status = 204;
	jsMessage.message = message;
	return jsMessage;
}

module.exports = {
	buildComplete: function(message) {
		return complete(message);
	},
	buildError: function(message) {
		return error(message);
	}
};
