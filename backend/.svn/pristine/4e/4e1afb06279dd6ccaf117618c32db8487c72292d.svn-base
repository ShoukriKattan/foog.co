NOTIFICATIONS_DELTA_SECONDS = 40;

exports.fieldChanged = function(fieldsChanged, fieldName) {

	return fieldsChanged.indexOf(fieldName) != -1;
};

exports.itToUserPointer = function(id) {

	var userPointer = {
		__type : 'Pointer',
		className : '_User',
		objectId : id
	};

	return userPointer;
};

exports.resetHours = function(theDate) {
	theDate.setHours(0, 0, 0, 0);
	return theDate;

};

exports.daysToMillis = function(days) {

	return days * 24 * 60 * 60 * 1000;
};

exports.formatMsg = function(msg, args) {

	for (var i = 0; i < args.length; i++) {

		msg = msg.replace("{" + args[i].key + "}", args[i].value);

	};

	return msg;

};
