//TODO: HuGE BUG , PASS BY REFERENCE DOES NOT FUCKING WORK IN PROMISES
var moment = require('cloud/moment-timezone-with-data.js');

var REMINDER_DAYS_COACH_HAS_LINKS = 5;

var MEAL_REVIEW_REMINDER_DAYS = 3;

var SUMMARY_SET_REMINDER_DAYS = 4;

var NO_MEALS_SUBMITTED_REMINDER_DAYS = 1;

var remindCoachUserLinks = function() {

	var today = moment();
	var xDaysAgo = today.clone().subtract(REMINDER_DAYS_COACH_HAS_LINKS, 'days');

	var CoachUserLink = Parse.Object.extend("CoachUserLink");

	//Not linked, not rejected, not cancelled, last reminder x days ago.
	var remindedBeforeXDays = new Parse.Query(CoachUserLink);
	remindedBeforeXDays.doesNotExist('linkedAt');
	remindedBeforeXDays.doesNotExist('rejectedAt');
	remindedBeforeXDays.doesNotExist('cancelledAt');
	remindedBeforeXDays.lessThan('remindedAt', xDaysAgo.toDate());

	console.log("RemindCoachUserLinks Running to remind of links before " + xDaysAgo.format());

	return remindedBeforeXDays.find().then(function(coachUserLinks) {

		console.log("RemindCoachUserLinks: Processing  " + coachUserLinks.length + " links");
		var promises = new Array();

		for (var i = 0; i < coachUserLinks.length; i++) {

			var link = coachUserLinks[i];
			link.set('remindedAt', new Date());
			promises.push(link.save());
		}

		return Parse.Promise.when(promises);
	});

};

var remindNonReviewedMeals = function() {

	var today = moment();
	var xDaysAgo = today.clone().subtract(MEAL_REVIEW_REMINDER_DAYS, 'days');

	var Meal = Parse.Object.extend("Meal");

	// Try to find meals , which are old, but have no date Reviewed.
	var remindedBeforeXDays = new Parse.Query(Meal);
	remindedBeforeXDays.doesNotExist('coachReviewedAt');
	// Coach has not reviewed them.
	remindedBeforeXDays.doesNotExist('summaryCreatedAt');
	// No summary created for them.
	remindedBeforeXDays.lessThan('appCreatedAt', xDaysAgo.toDate());
	// Created before x days
	//TODO: take reminded at into account as well. Dont remind every day... ...

	console.log("remindNonReviewedMeals Running to remind of meals not reviewed before " + xDaysAgo.format());

	return remindedBeforeXDays.find().then(function(meals) {

		// Send a general reminder, that coach has not reviewed meals.
		// Depending on who the coach is

		var promises = new Array();

		console.log("Reminding users of  " + meals.length + " meals total");

		for (var i = 0; i < meals.length; i++) {

			// Simple ... set a date and save.

			var meal = meals[i];
			meal.set('coachRemindedAt', new Date());

			promises.push(meal.save());
		}
		return Parse.Promise.when(promises);
	});

};

// Change reminders to be sent out daily  ...
var remindUserNoMealsSubmitted = function() {

	console.log("remindUserNoMealsSubmitted Running");
	// For all fucking users. for each user, check last meal submitted date time.

	var today = moment();
	var xDaysAgo = today.clone().subtract(NO_MEALS_SUBMITTED_REMINDER_DAYS, 'days');

	var ClientInfo = Parse.Object.extend("ClientInfo");
	var clientInfoQuery = new Parse.Query(ClientInfo);

	return clientInfoQuery.find().then(function(clientInfoResults) {

		console.log("remindUserNoMealsSubmitted Reminding all " + clientInfoResults.length + " users");

		// See last date of meals .. and notify immediately.. or if meals are ok, then ... also set remindedAt
		var promises = new Array();

		for (var i = 0; i < clientInfoResults.length; i++) {

			var clientInfo1 = clientInfoResults[i];

			var user = clientInfo1.get("user");
			var coach = clientInfo1.get("coach");

			console.log("User " + i + " " + JSON.stringify(user) + "with Coach" + JSON.stringify(coach) + " checking if having  meals submitted  after " + xDaysAgo.format());

			// Try to find one meal that has been created after x days ago. if there is one ... good
			var query = new Parse.Query("Meal");
			query.equalTo("user", user);
			query.equalTo("coach", coach);
			query.doesNotExist("summaryCreatedAt");
			query.greaterThanOrEqualTo("appCreatedAt", xDaysAgo.toDate());
			query.ascending("appCreatedAt");

			var promise = new Parse.Promise.when(query.first(), i, clientInfo1, user, coach, xDaysAgo).then(updateMealReminderinfo);

			promises.push(promise);

		}

		return Parse.Promise.when(promises);

	});

};

var updateMealReminderinfo = function(theMeal, i, clientInfo1, user, coach, xDaysAgo) {

	console.log("User " + i + " " + JSON.stringify(user) + "with Coach" + JSON.stringify(coach) + "Check coming back");
	if (!theMeal) {
		console.log("User " + i + " " + JSON.stringify(user) + "with Coach" + JSON.stringify(coach) + " has no meals after " + xDaysAgo.format());
		// return notify
		clientInfo1.set("mealReminderDate", new Date());
		return clientInfo1.save();
	} else {
		console.log("User " + i + " " + JSON.stringify(user) + "with Coach" + JSON.stringify(coach) + " is submitting meals nicely after " + xDaysAgo.format());
		return Parse.Promise.as('UserIsSubmittingMeals');
	}

};

exports.runReminders = function() {

	// Once we remind, we need to save new date....

	var promises = new Array();
	promises.push(remindCoachUserLinks());
	promises.push(remindNonReviewedMeals());
	promises.push(remindUserNoMealsSubmitted());

	return Parse.Promise.when(promises);
};
