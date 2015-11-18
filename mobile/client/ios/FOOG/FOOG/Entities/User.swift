//
//  User.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/14/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit


import Parse

class User: PFUser, PFSubclassing {

    /** Parse User Keys. */
    struct ParseKeys {
        static let CoachID = "coachId"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let GymName = "gymName"
        static let Image = "image"
        static let Sex = "sex"
        static let DateOfBirth = "dateOfBirth"
        static let IsCoach = "isCoach"
        static let CreatedAt = "CreatedAt"
        static let PhoneNumber = "phone"
        static let IsPhoneVerified = "phoneVerified"
        static let VerificationCode = "verificationCode"
        static let ObjectID = "objectId"
        static let Coach = "coach"
        static let Timezone = "timezone"
    }
    
    /** Coach ID */
    var id : String {
        get{
            if let coachID = self.objectForKey(ParseKeys.CoachID) as? String {
                return coachID
            }else{
                return ""
            }
        }
        set(newID){
            self.setObject(newID, forKey:ParseKeys.CoachID)
        }
    }
    
    /** First Name */
    var firstName : String {
        get{
            if let userFirstName = self.objectForKey(ParseKeys.FirstName) as? String {
                return userFirstName
            }else{
                return ""
            }
        }
        set(newFirstName){
            self.setObject(newFirstName, forKey:ParseKeys.FirstName)
        }
    }
    
    /** Last Name */
    var lastName : String {
        get{
            if let userLastName = self.objectForKey(ParseKeys.LastName) as? String {
                return userLastName
            }else{
                return ""
            }
        }
        set(newLastName){
            self.setObject(newLastName, forKey: ParseKeys.LastName)
        }
    }
    
    /** Gym Name */
    var gymName : String{
        get{
            if let userGymName = self.objectForKey(ParseKeys.GymName) as? String {
                return userGymName
            }else{
                return ""
            }
        }
        set(newGymName){
            self.setObject(newGymName, forKey: ParseKeys.GymName)
        }
    }
    
    /** photo file. */
    var image : PFFile? {
        get{
            if let userImage = objectForKey(ParseKeys.Image) as? PFFile {
                return userImage
            }else{
                return nil
            }
        }
        set (newUserImage){
            self.setObject(newUserImage!, forKey: ParseKeys.Image)
        }
        
        
    }
    
    /* Sex. */
    var sex : SexType {
        get{
            if let userSex = self.objectForKey(ParseKeys.Sex) as? String {
                if userSex.capitalizedString == SexType.Male.rawValue {
                    return SexType.Male
                }else{
                    return SexType.Female
                }
            }else{
                return SexType.Male
            }
        } set(newUserSex){
            if newUserSex == SexType.Male {
                self.setObject(newUserSex.rawValue, forKey: ParseKeys.Sex)
            }else{
                self.setObject(newUserSex.rawValue, forKey: ParseKeys.Sex)
            }
            
        }
    }
    
    /** Date Of Birth */
    var dateOfBirth : NSDate? {
        get{
            if let userDateOfBirth = objectForKey(ParseKeys.DateOfBirth) as? NSDate {
                return userDateOfBirth
            }else{
                return nil
            }
        }
        set (newBirthOfDate){
            self.setObject(newBirthOfDate!, forKey: ParseKeys.DateOfBirth)
        }
        
        
    }
    
    /** Is Coach */
    var isCoach : Bool{
        get{
            if let currentIsCoach = self.objectForKey(ParseKeys.IsCoach) as? Bool {
                return currentIsCoach
            }else{
                return false
            }
        }
        set(newIsCoach){
            self.setObject(newIsCoach, forKey: ParseKeys.IsCoach)
        }
    }
    
    /** This user's Phone number. */
    var phone : String? {
        get {
            return self.objectForKey(ParseKeys.PhoneNumber) as! String?
        }
        set (newValue) {
            self.setObject(newValue!, forKey: ParseKeys.PhoneNumber)
        }
    }
    
    /** Boolean value indicate if this user has verified his phone number or not. */
    var isPhoneVerified : Bool {
        get {
            if let isVerified = self.objectForKey(ParseKeys.IsPhoneVerified) as? Bool {
                return isVerified
            } else {
                return false
            }
        }
        set (newValue) {
            self.setObject(newValue, forKey: ParseKeys.IsPhoneVerified)
        }
    }

    /** Coach. */
    var coach : User? {
        get {
            if let tempCoach = self.objectForKey(User.ParseKeys.Coach) as? User {
                return tempCoach 
            }else{
                return nil
            }
        }set(newCoach) {
            self.setObject(PFUser(withoutDataWithObjectId: newCoach!.objectId), forKey: ParseKeys.Coach)
        }
    }
    
    var timezone : String {
        get {
            return self[ParseKeys.Timezone] as! String
        }
        set (v) {
            self[ParseKeys.Timezone] = v
        }
    }
    
    /** Notification Count. */
    var notificationCount : Int  = 0

    /** Unreviewed Meal Notification Count. */
    var unreviewedNotificationCount : Int  = 0
    
    /** Is Active. */
    var isActive : Bool = false
    
    /** Is Login User Coach. */
    class func isLoginUserCoach() -> Bool {
        var user = PFUser.currentUser() as! User
        return user.isCoach
    }
}
