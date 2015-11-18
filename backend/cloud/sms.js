var twilio = require("twilio");
//PROD
twilio.initialize("AC0463c01b6d65f010f1325d5fd03582f7", "34a35b1fad86893238e6d3b96ca692e9");

//twilio.initialize("AC45cfaa560c32a9fbe8c44f265f007253", "90ebf372f8a70424f79489dd6d8db7de");



exports.confirmPhoneNumber = function(request, response) {

	var random4Digit = ("" + Math.random()).substring(2, 6);

	var msg = "Your verification code is " + random4Digit;

	var dUser = request.params.duser;
	var cellNumber = request.params.number;

	var User = Parse.Object.extend("_User");
	var query = new Parse.Query(User);

	query.get(dUser, {
		success : function(userOb) {// Query success

			// Now save the random 4 digit
			userOb.set("phone", cellNumber);
			userOb.set("verificationCode", random4Digit);
			userOb.save();

			twilio.sendSMS({
				From : "+16473602076",
				To : cellNumber,
				Body : msg
			}, {
				success : function(httpResponse) {
					console.log(httpResponse);
					response.success("success");
				},
				error : function(httpResponse) {
					console.error(httpResponse);
					response.error("smsFailed");
				}
			});
			// send of send SMS

		},
		error : function(object, error) {// error with Query to get a User
			// error is a Parse.Error with an error code and message.
			console.error("Query failed " + JSON.stringify(error));
			response.error("unableToLoadUser");
		}
	});
	// end of query.get

};

exports.validateVerificationCode = function(request, response) {

	var dUser = request.params.duser;
	var digits = request.params.digits;

	var User = Parse.Object.extend("_User");
	var query = new Parse.Query(User);

	query.get(dUser, {

		success : function(userOb) {

			var savedCode = userOb.get("verificationCode");

			if (savedCode == digits) {

				userOb.set("phoneVerified", true);
				userOb.save();

				response.success("verified");

			} else {

				response.error("confirmationCodeNotMatching");

			}

		},
		error : function(object, error) {

			console.error("Query failed " + JSON.stringify(error));
			response.error("unableToLoadUser");

		}
	});
	// end query.get

};
