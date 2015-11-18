var SummaryModule = require("cloud/summary.js");
var Reminders = require('cloud/reminders.js');

// At 12am EST - Run Summary Job
exports.summaryJob = function(request, status) {

	// This runs past midnight ... every night ...
	// if this runs midnight ... then it needs to process day before ... or Start day is Today ...

	// End of week = Start of week -1
	// Start of week = end + 1

	// This job wakes up daily, checks day of week

	// Loads all users whose end of week day is set to be same as today
	// For each of them, labels the weeks , and creates end of week summary

	// Set up to modify user data
	Parse.Cloud.useMasterKey();

	SummaryModule.processUsersSummary().then(function() {
		status.success("Summary Run Successfully");
	}, function(error) {
		status.error("Error Running Summary " + JSON.stringify(error));
	});

};

exports.remindersJob = function(request, status) {

	// At 12 pm EST run Reminder Summary .

	Reminders.runReminders().then(function() {
		status.success("Reminders Run Successfully");
	}, function(error) {
		status.error("Error running Reminders " + JSON.stringify(error));
	});

};
