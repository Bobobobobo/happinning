/**
 * build return message
 */

function complete(message) {
	message.status = 200;
	return message; 
}

function error(message) {
	var jsMessage = new Object();
	jsMessage.status = 204;
	jsMessage.message = message;
	return JSON.stringify(jsMessage);
}

module.exports = {
	buildComplete: function(message) {
		return complete(message);
	},
	buildError: function(message) {
		return error(message);
	}
};
