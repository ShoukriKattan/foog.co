//
//  Notification.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 7/15/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class Notification: PFObject , PFSubclassing {
    
    /** Parse Notification Keys. */
    struct ParseKeys {
        static let Coach = "coach"
        static let User = "user"
        static let TargetUser = "targetUser"
        static let TargetMeal = "targetMeal"
        static let TargetSummary = "targetSummary"
        static let ViewedAt = "viewedAt"
        static let NotificationType = "notificationType"
    }
    
    /** Notification Type. */
    struct NotificationType  {
         static let NewMeal = "NewMeal"
         static let CoachReviewedMeal = "CoachReviewedMeal"
         static let CoachCommented = "CoachCommented"
         static let UserCommented = "UserCommented"
         static let UserSubmittedNoMeals = "UserSubmittedNoMeals"
         static let CoachReviewMealsReminder = "CoachReviewMealsReminder"
         static let UserSentLinkRequest = "UserSentLinkRequest"
         static let CoachAcceptedLinkRequest = "CoachAcceptedLinkRequest"
         static let CoachRejectedLinkRequest = "CoachRejectedLinkRequest"
         static let UserCancelledLinkRequest = "UserCancelledLinkRequest"
         static let UserUnlinked = "UserUnlinked"
         static let CoachUnlinked = "CoachUnlinked"
         static let CoachPendingLinkRequests = "CoachPendingLinkRequests"
         static let SummaryAvailableUser = "SummaryAvailableUser"
         static let SummaryAvailableCoach = "SummaryAvailableCoach"
         static let SummaryReminderEndOfWeek = "SummaryReminderEndOfWeek"
    }
    
    /** Display Name for Parse. */
    var displayName: String? {
        get {
            return self["displayName"] as? String
        }
        set {
            self["displayName"] = newValue
        }
    }
    
    
    /** Parse Class Name. */
    class func parseClassName() -> String {
        return "Notifications"
    }
    
    
    /** Coach. */
    var coach : User? {
        get {
            if let tempCoach = self.objectForKey(Notification.ParseKeys.Coach) as? User {
                return tempCoach
            }else{
                return nil
            }
        }set(newCoach) {
            self.setObject(PFUser(withoutDataWithObjectId: newCoach!.objectId), forKey: Notification.ParseKeys.Coach)
        }
    }
    
    /** User. */
    var user  : User? {
        get {
            if let tempUser = self.objectForKey(Notification.ParseKeys.User) as? User {
                return tempUser
            }else{
                return nil
            }
        }set(newUser) {
            self.setObject(PFUser(withoutDataWithObjectId: newUser!.objectId), forKey: Notification.ParseKeys.User)
        }
    }
    
    /** Target User. */
    var targetUser : User? {
        get {
            if let tempTargetUser = self.objectForKey(Notification.ParseKeys.TargetUser) as? User {
                return tempTargetUser
            }else{
                return nil
            }
        }set(newTargetUser) {
            if let modifiedNewTargetUser = newTargetUser {
                self.setObject(PFUser(withoutDataWithObjectId: modifiedNewTargetUser.objectId), forKey: Notification.ParseKeys.TargetUser)
            }
        }
    }
    
    /** Target Meal. */
    var targetMeal : Meal? {
        get {
            if let tempTargetMeal = self.objectForKey(Notification.ParseKeys.TargetMeal) as? Meal {
                return tempTargetMeal
            }else{
                return nil
            }
        }set(newTargetMeal) {
            if let modifiedNewTargetMeal = newTargetMeal {
                self.setObject(Meal(withoutDataWithObjectId: modifiedNewTargetMeal.objectId), forKey: Notification.ParseKeys.TargetMeal)
            }
        }
    }
    
    /** Target Summary. */
    var targetSummary : SummaryCard? {
        get {
            if let tempTargetSummary = self.objectForKey(Notification.ParseKeys.TargetSummary) as? SummaryCard {
                return tempTargetSummary
            }else{
                return nil
            }
        }set(newTargetSummary) {
            if let modifiedTargetSummary = newTargetSummary {
                self.setObject(SummaryCard(withoutDataWithObjectId: modifiedTargetSummary.objectId), forKey: Notification.ParseKeys.TargetSummary)
            }
 
        }
    }
    
    /** Viewed At. */
    var viewedAt : NSDate? {
        get {
            if let tempViewedAt = self.objectForKey(Notification.ParseKeys.ViewedAt) as? NSDate {
                return tempViewedAt
            }else{
                return nil
            }
        }set(newViewedAt) {
            self.setObject(newViewedAt!, forKey: Notification.ParseKeys.ViewedAt)
        }
    }
    
    /* Notification Type. */
    var notificationType : String {
        get{
            if let tempNotificationType = self.objectForKey(Notification.ParseKeys.NotificationType) as? String {
                return tempNotificationType
            }else{
                return NotificationType.NewMeal
            }
        } set(newNotificationType){
            switch (newNotificationType){
            case NotificationType.NewMeal , NotificationType.CoachReviewedMeal,  NotificationType.CoachCommented, NotificationType.UserCommented , NotificationType.UserSubmittedNoMeals, NotificationType.CoachReviewMealsReminder, NotificationType.CoachReviewMealsReminder,  NotificationType.UserSentLinkRequest, NotificationType.CoachAcceptedLinkRequest,  NotificationType.CoachRejectedLinkRequest, NotificationType.UserCancelledLinkRequest, NotificationType.UserUnlinked, NotificationType.CoachUnlinked, NotificationType.CoachPendingLinkRequests, NotificationType.SummaryAvailableUser, NotificationType.SummaryAvailableCoach,  NotificationType.SummaryReminderEndOfWeek:
                    self.setObject(newNotificationType, forKey: Notification.ParseKeys.NotificationType)
                    break;
            default :
                self.setObject(NotificationType.NewMeal, forKey: Notification.ParseKeys.NotificationType)
            }
            
        }
    }
}
