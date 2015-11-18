var utils = require("cloud/utils.js");

var NOTIFICATION_TYPE_NEW_MEAL = "NewMeal";
var NOTIFICATION_TYPE_COACH_REVIEWED_MEAL = "CoachReviewedMeal";
var NOTIFICATION_TYPE_COACH_COMMENTED = "CoachCommented";
var NOTIFICATION_TYPE_USER_COMMENTED = "UserCommented";

var NOTIFICATION_TYPE_USER_SUBMITTED_NO_MEALS_REMINDER = "UserSubmittedNoMeals";
var NOTIFICATION_TYPE_COACH_REVIEW_MEALS_REMINDER = "CoachReviewMealsReminder";

var NOTIFICATION_TYPE_USER_SENT_LINK_REQUEST = "UserSentLinkRequest";
var NOTIFICATION_TYPE_COACH_ACCEPTED_LINK_REQUEST = "CoachAcceptedLinkRequest";
var NOTIFICATION_TYPE_COACH_REJECTED_LINK_REQUEST = "CoachRejectedLinkRequest";
var NOTIFICATION_TYPE_USER_CANCELLED_LINK_REQUEST = "UserCancelledLinkRequest";
var NOTIFICATION_TYPE_USER_UNLINKED = "UserUnlinked";
var NOTIFICATION_TYPE_COACH_UNLINKED = "CoachUnlinked";

//Reminder  Pending link request
var NOTIFICATION_TYPE_COACH_PENDING_LINK_REQUESTS = "CoachPendingLinkRequests";

var NOTIFICATION_TYPE_SUMMARY_AVAIALABLE_TO_USER = "SummaryAvailableUser";
var NOTIFICATION_TYPE_SUMMARY_AVAILABLE_TO_COACH = "SummaryAvailableCoach";
var NOTIFICATION_TYPE_SUMMARY_REMINDER_END_OF_WEEK = "SummaryReminderEndOfWeek";

var messages = new Array();

messages[NOTIFICATION_TYPE_NEW_MEAL] = {
	alert : "{firstName} {lastName} submitted a new Meal",
	title : "New Meal For your Review",
	message : "{firstName} {lastName} submitted a new Meal"
};

messages[NOTIFICATION_TYPE_COACH_REVIEWED_MEAL] = {
	alert : "Coach {firstName} {lastName} reviewed your Meal",
	title : "Coach reviewed your meal",
	message : "Coach {firstName} {lastName} reviewed your Meal"
};

messages[NOTIFICATION_TYPE_COACH_COMMENTED] = {
	alert : "Coach {firstName} {lastName} commented on your Meal",
	title : "Comments on meal",
	message : "Coach {firstName} {lastName} commented on your Meal"
};

messages[NOTIFICATION_TYPE_USER_COMMENTED] = {
	alert : "{firstName} {lastName} commented on Meal",
	title : "Comments on meal",
	message : "{firstName} {lastName} commented on Meal"
};

messages[NOTIFICATION_TYPE_USER_SENT_LINK_REQUEST] = {
	alert : "{firstName} {lastName} has requested to link to you",
	title : "New Link Request",
	message : "{firstName} {lastName} has requested to link to you"
};

messages[NOTIFICATION_TYPE_COACH_ACCEPTED_LINK_REQUEST] = {
	alert : "Coach {firstName} {lastName} accepted your link request",
	title : "Link Request Accepted",
	message : "Coach {firstName} {lastName} accepted your link request"
};

messages[NOTIFICATION_TYPE_COACH_REJECTED_LINK_REQUEST] = {
	alert : "Coach {firstName} {lastName} rejected your link request",
	title : "Link Request Rejected",
	message : "Coach {firstName} {lastName} rejected your link request"
};

messages[NOTIFICATION_TYPE_USER_CANCELLED_LINK_REQUEST] = {
	alert : "{firstName} {lastName} cancelled his link request",
	title : "Link Request Cancelled",
	message : "{firstName} {lastName} cancelled his link request"
};

messages[NOTIFICATION_TYPE_USER_UNLINKED] = {
	alert : "{firstName} {lastName} unlinked with you",
	title : "User Unlinked",
	message : "{firstName} {lastName} unlinked with you"
};
messages[NOTIFICATION_TYPE_COACH_UNLINKED] = {
	alert : "Coach {firstName} {lastName} unlinked with you",
	title : "Coach Unlinked",
	message : "Coach {firstName} {lastName} unlinked with you"
};

messages[NOTIFICATION_TYPE_SUMMARY_AVAIALABLE_TO_USER] = {
	alert : "Your week summary is available",
	title : "Week Summary Available",
	message : "Your week summary is available"
};

messages[NOTIFICATION_TYPE_SUMMARY_AVAILABLE_TO_COACH] = {
	alert : "{firstName} {lastName} week summary is available",
	title : "User Week Summary available",
	message : "{firstName} {lastName} week summary is available"
};

messages[NOTIFICATION_TYPE_SUMMARY_REMINDER_END_OF_WEEK] = {
	alert : "Tomorrow is end of week for {firstName} {lastName}. Snap a photo of your client !",
	title : "End of Week Reminder",
	message : "Tomorrow is end of week for {firstName} {lastName}. Snap a photo of your client !"
};

messages[NOTIFICATION_TYPE_USER_SUBMITTED_NO_MEALS_REMINDER] = {
	alert : "You haven't submitted any new meals recently",
	title : "No Meals Submitted",
	message : "You haven't submitted any meal recently for your coach to review"
};

messages[NOTIFICATION_TYPE_COACH_REVIEW_MEALS_REMINDER] = {
	alert : "You have a non-reviewed meal for {firstName} {lastName}",
	title : "Non-Reviewed Meal",
	message : "You have non-reviewed meal for {firstName} {lastName}"
};

messages[NOTIFICATION_TYPE_COACH_PENDING_LINK_REQUESTS] = {
	alert : "You have a pending link request from {firstName} {lastName}",
	title : "Link Request Pending",
	message : "You have a pending link request from {firstName} {lastName}"
};

getPushData = function(notificationType, dstUser, notificationObjectId) {

	var firstName = dstUser.get('firstName');
	var lastName = dstUser.get('lastName');
	var dstUserId=dstUser.id;

	var formatObject = [{
		key : "firstName",
		value : firstName
	}, {
		key : "lastName",
		value : lastName
	}];

	var alert = utils.formatMsg(messages[notificationType].alert, formatObject);
	var title = utils.formatMsg(messages[notificationType].title, formatObject);
	var message = utils.formatMsg(messages[notificationType].message, formatObject);

	return {
		alert : alert,
		type : notificationType,
		objectId : notificationObjectId,
		userId: dstUserId,
		badge : 'Increment',
		title : title,
		message : message

	};
};

/**
 *
 * @param {Object} targetUser
 * @param {Object} notificationType
 * @param {Object} user
 * @param {Object} coach
 * @param {Object} targetMeal
 * @param {Object} targetSummary
 * @param {Object} scheduleDate
 */
var sendNotification = function(targetUser, notificationType, user, coach, targetMeal, targetSummary, scheduleDate) {

	var Notifications = Parse.Object.extend("Notifications");

	var notification = new Notifications();

	notification.set('user', user);
	notification.set('coach', coach);
	notification.set('targetUser', targetUser);
	notification.set('targetMeal', targetMeal);
	notification.set('targetSummary', targetSummary);
	notification.set('notificationType', notificationType);

	return notification.save().then(function(theNotification) {

		// Load the user, load the coach, format messages, then send the notification.

		var toRetrieve = user;

		if (targetUser == user) {
			toRetrieve = coach;
		}

		var query = new Parse.Query(Parse.User);

		return query.get(toRetrieve.id).then(function(fullUser) {

			var pushData = getPushData(notificationType, fullUser, notification.id);

			return sendPush(targetUser, pushData, scheduleDate);

		});

	});

};

var sendPush = function(user, pushData, scheduleDate) {

	var pushQuery = pushQueryForUser(user);

	//TODO: If we need scheduling timezone stuff
	//TODO: Do you need a reference to the modified object ...
	//TODO : I can pass a dictionary of shit

	//var pushTime = new Date();
	//pushTime.setTime(pushTime.getTime()+(30*1000));

	var sendParams = {
		where : pushQuery,
		//push_time: pushTime,
		data : pushData
	};

	if (scheduleDate) {
		console.log("Scheduled Date is "+scheduleDate);
		sendParams.push_time = scheduleDate;
	}

	return Parse.Push.send(sendParams);

};

var pushQueryForUser = function(userRef) {

	var pushQuery = new Parse.Query(Parse.Installation);
	pushQuery.equalTo("user", userRef);

	return pushQuery;

};

exports.NOTIFICATION_TYPE_NEW_MEAL = NOTIFICATION_TYPE_NEW_MEAL;
exports.NOTIFICATION_TYPE_COACH_REVIEWED_MEAL = NOTIFICATION_TYPE_COACH_REVIEWED_MEAL;
exports.NOTIFICATION_TYPE_COACH_COMMENTED = NOTIFICATION_TYPE_COACH_COMMENTED;
exports.NOTIFICATION_TYPE_USER_COMMENTED = NOTIFICATION_TYPE_USER_COMMENTED;
exports.NOTIFICATION_TYPE_USER_SENT_LINK_REQUEST = NOTIFICATION_TYPE_USER_SENT_LINK_REQUEST;
exports.NOTIFICATION_TYPE_COACH_ACCEPTED_LINK_REQUEST = NOTIFICATION_TYPE_COACH_ACCEPTED_LINK_REQUEST;
exports.NOTIFICATION_TYPE_COACH_REJECTED_LINK_REQUEST = NOTIFICATION_TYPE_COACH_REJECTED_LINK_REQUEST;
exports.NOTIFICATION_TYPE_USER_CANCELLED_LINK_REQUEST = NOTIFICATION_TYPE_USER_CANCELLED_LINK_REQUEST;
exports.NOTIFICATION_TYPE_USER_UNLINKED = NOTIFICATION_TYPE_USER_UNLINKED;
exports.NOTIFICATION_TYPE_COACH_UNLINKED = NOTIFICATION_TYPE_COACH_UNLINKED;
exports.NOTIFICATION_TYPE_SUMMARY_AVAIALABLE_TO_USER = NOTIFICATION_TYPE_SUMMARY_AVAIALABLE_TO_USER;
exports.NOTIFICATION_TYPE_SUMMARY_AVAILABLE_TO_COACH = NOTIFICATION_TYPE_SUMMARY_AVAILABLE_TO_COACH;
exports.NOTIFICATION_TYPE_SUMMARY_REMINDER_END_OF_WEEK = NOTIFICATION_TYPE_SUMMARY_REMINDER_END_OF_WEEK;
exports.NOTIFICATION_TYPE_COACH_PENDING_LINK_REQUESTS = NOTIFICATION_TYPE_COACH_PENDING_LINK_REQUESTS;
exports.NOTIFICATION_TYPE_USER_SUBMITTED_NO_MEALS_REMINDER = NOTIFICATION_TYPE_USER_SUBMITTED_NO_MEALS_REMINDER;
exports.NOTIFICATION_TYPE_COACH_REVIEW_MEALS_REMINDER = NOTIFICATION_TYPE_COACH_REVIEW_MEALS_REMINDER;

exports.sendNotification = sendNotification;

