//
//  FoogMessages.swift
//  FOOG
//
//  Created by Zafer Shaheen on 7/17/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

/** Representation of messages used to notify user about something. */
class FoogMessage {
    
    /** Message title. */
    var title : String
    
    /** Message content itself. */
    var message : String
    
    init (title : String, message : String) {
        self.title = title
        self.message = message
    }
    
}

/** This structure holds all messages used in the app. */
struct FoogMessages {
    
    static let MissingEmail = FoogMessage(title: "Missing Email", message: "Please enter your email address")
    
    static let WrongEmail = FoogMessage(title: "Wrong Email", message: "Please make sure you enter valid email address")
    
    static let MissingPassword = FoogMessage(title: "Missing Password", message: "Please enter your password")
    
    static let MissingPasswordConfirmation = FoogMessage(title: "Missing Password Confirmation", message: "Please confirm your password")
    
    static let PasswordsDoNotMatch = FoogMessage(title: "Passwords Do Not Match", message: "Please make sure that you confirm your password correctly")
    
    static let MissingUsername = FoogMessage(title: "Missing Username / Coach ID", message: "Please enter a username")
    
    static let EmailIsTaken = FoogMessage(title: "Error", message: "Provided email is already registered!")
    
    static let CoachIdIsTaken = FoogMessage(title: "CoachID is Taken", message: "Please choose another.")
    
    static let CouldNotSignUp = FoogMessage(title: "Error", message: "Could not signup!")
    
    static let EnterFirstName = FoogMessage(title: "Enter your first name", message: "")
    
    static let EnterLastName = FoogMessage(title: "Enter your last name", message: "")
    
    static let EnterDateOfBirth = FoogMessage(title: "Enter your date of birth", message: "")
    
    static let EnterNameOfGYM = FoogMessage(title: "Enter name of GYM", message: "")
    
    static let SetProfilePhoto = FoogMessage(title: "Please set your profile photo", message: "")
    
    static let ErrorUpdatingBio = FoogMessage(title: "Error while updating your bio", message: "")
    
    static let ErrorCameraIsNotAvailable = FoogMessage(title: "Error", message: "Camera is not available")
    
    static let ErrorCouldNotSave = FoogMessage(title: "Error", message: "Sorry, could not save your changes")
    
    static let ErrorCouldNotUnlink = FoogMessage(title: "Error", message: "Sorry, could not unlink your Coach!")
    
    static let ErrorCouldNotReachInternet = FoogMessage(title: "Error", message: "Could not reach internet")
    
    static let CouldNotSignIn = FoogMessage(title: "Could not sign in", message: "Please check your email / password")
    
    static let MissingPhoneNumber = FoogMessage(title: "Please enter your phone number with country code", message: "")
    
    static let WrongVerficationCode = FoogMessage(title: "Wrong Verification Code", message: "")
    
    static let MissingCoachID = FoogMessage(title: "Please enter Coach ID", message: "")
    
    static let ErrorCoachNotFound = FoogMessage(title: "Could not find Coach with provided ID", message: "")
    
    static let ErrorSyncRequestNotSent = FoogMessage(title: "Could not send sync request!", message: "")
    
    static let ErrorCouldNotMoveToInactive = FoogMessage(title: "Error", message: "Sorry, could not move this client to inactive!")
    
    static let ErrorPostMailFail = FoogMessage(title: "Faild to post meal", message: "Please try again")
    
    static let ErrorPostSummryCardPhotoFail = FoogMessage(title: "Faild to update summary card cover photo", message: "Please try again")
    
    static let ErrorSMSCodeNotSent = FoogMessage(title: "Could not send SMS code", message: "Please try again")
    
    static let NoActiveUsersPlaceholder = "You will find your active users here once they are connected to you."
    
    static let NoInactiveUsersPlaceholder = "You will find all inactive users here once you have them."
    
    static let NoLinkRequestsPlaceholder = "You have no link request \n at this time."
    
    static let NoMealPostForSelectedClient = "This client has not post any meal yet"
    
    static let NoMealPostForCurrentUser = "You did not post any meal yet"
    
    static let NoPinnedPostForSelectedUser = "This client has no pinned meals"
    
    static let NoSummaryCardForCurrentUser = "You do not have any summary cards yet"
    
    static let NoSpecialDiet = "No Spacial Diet"
    
    static let NoGoals = "No Goals"
    
    static let NoUserNote = "User has no note for this meal"
    
    static let NoCoachNote = "Coach has no note for this meal"
    
    static let NoNotificationForCurrentCoach = "You have no notifications \n at this time."
    
    static let AddNoteToUserMeal = "Add a note to client's meal"
    
    static let AddNoteToYourMeal = "Add a note to your meal"
    
    static let WeekSummaryPending = "WEEK %d RESULTS \n PENDING"
    
    static let WeekResultWillBePosted = "Results will be posted on %@"
    
    
    
    
    
    
}