//
//  NotificationModel.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 7/15/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class NotificationModel: NSObject {
    
    /** Selected User. */
    var selectedUser : User
    
    /** Notifications List. */
    var notificationsList : [Notification] = []
    
    /** Notification Model Notifications. */
    struct ModelNotifications {
        static let GetListOfUserNotificationCountsForCoachNotification = "GetListOfUserNotificationCountsForCoachNotification"
        static let GetUserNotificationCountForCoach = "GetUserNotificationCountForCoach"
        static let GetUserNotificationCountForUser = "GetUserNotificationCountForUser"
        static let GetUserNotificationForCoach = "GetUserNotificationForCoach"
        static let GetUserNotification = "GetUserNotification"
    }
    
    /** Notification Model Errors Tags. */
    struct ModelErrorType {
        static let ErrortoGetGetListOfUserNotificationCountsForCoach = "ErrortoGetListOfUserNotificationCounts"
        static let ErrorToGetUserNotificationForCoach = "ErrorToGetUserNotificationForCoach"
        static let ErrorToGetUserNotification = "ErrorToGetUserNotification"
    }
    
    /** Default constructor of Notification Model */
    override init() {
        self.selectedUser = User()
        super.init()
    }
    
    /** Default constructor of Notification Model */
    convenience init(user : User) {
        self.init()
        self.selectedUser = user
    }
    
    /** Get User Notification Counts For Coach. */
    func getUserNotificationCountsForCoach(){
        
        // Send user's verification code to the backend to validate it.
        var parameters : [NSObject : AnyObject] = [:]
        parameters["coachId"] = self.selectedUser.objectId
        
        PFCloud.callFunctionInBackground(FoogCloudCode.getUserNotificationCounts, withParameters: parameters) { (result : AnyObject?, error : NSError?) -> Void in
            
            if (error != nil) {
                let userInfoDict  = [ModelErrorType.ErrortoGetGetListOfUserNotificationCountsForCoach: error!]
                /** send Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetListOfUserNotificationCountsForCoachNotification, object: self , userInfo:userInfoDict)
            } else {
                
                if let returnedResults = result as? [AnyObject] {
                    var unreviewedMealCountList : [String : NSNumber] = [String : NSNumber]()
                    for singleValue in returnedResults  {
                        var user = singleValue[Meal.ParseKeys.User] as! String
                        var notificationCount = singleValue["count"] as! NSNumber
                        unreviewedMealCountList[user] = notificationCount
                    }
                    
                    /** send Notification. */
                    NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetListOfUserNotificationCountsForCoachNotification, object: self , userInfo:["results": unreviewedMealCountList])
                }
            }
        }
    }
    
    /** Get User Notification Count For Coach. */
    func getUserNotificationCountForCoach(coach: User) {
        var query = PFQuery(className:Notification.parseClassName())
        query.whereKey(Notification.ParseKeys.TargetUser, equalTo:coach)
        query.whereKey(Notification.ParseKeys.User, equalTo:self.selectedUser)
        query.whereKey(Notification.ParseKeys.Coach, equalTo:coach)
        query.whereKeyDoesNotExist(Notification.ParseKeys.ViewedAt)
        query.whereKey(Notification.ParseKeys.NotificationType, notContainedIn: [Notification.NotificationType.CoachAcceptedLinkRequest,Notification.NotificationType.CoachPendingLinkRequests,Notification.NotificationType.CoachRejectedLinkRequest,Notification.NotificationType.CoachUnlinked,Notification.NotificationType.UserCancelledLinkRequest,Notification.NotificationType.UserSentLinkRequest,Notification.NotificationType.UserUnlinked,Notification.NotificationType.CoachCommented,Notification.NotificationType.CoachReviewedMeal,Notification.NotificationType.SummaryAvailableUser,Notification.NotificationType.UserSubmittedNoMeals])
        query.countObjectsInBackgroundWithBlock { (count : Int32,  error: NSError?) -> Void in
            /** The find succeeded. */
            if error == nil {
                /** send Notification. */
                AppDelegate.getAppDelegate().userTabBarController?.selectedUser.notificationCount = Int(count)
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetUserNotificationCountForCoach, object: NSNumber(int: count))
            }else{
                
            }
        }
    }
    
    
    /** Get User Notifications For Coach. */
    func getUserNotificationsForCoach(coach: User) {
        var query = PFQuery(className:Notification.parseClassName())
        query.whereKey(Notification.ParseKeys.TargetUser, equalTo:coach)
        query.whereKey(Notification.ParseKeys.User, equalTo:self.selectedUser)
        query.whereKey(Notification.ParseKeys.Coach, equalTo:coach)
        query.whereKeyDoesNotExist(Notification.ParseKeys.ViewedAt)
        query.includeKey(Notification.ParseKeys.TargetMeal)
        query.includeKey(Notification.ParseKeys.Coach)
        query.includeKey(Notification.ParseKeys.User)
        query.whereKey(Notification.ParseKeys.NotificationType, notContainedIn: [Notification.NotificationType.CoachAcceptedLinkRequest,Notification.NotificationType.CoachPendingLinkRequests,Notification.NotificationType.CoachRejectedLinkRequest,Notification.NotificationType.CoachUnlinked,Notification.NotificationType.UserCancelledLinkRequest,Notification.NotificationType.UserSentLinkRequest,Notification.NotificationType.UserUnlinked,Notification.NotificationType.CoachCommented,Notification.NotificationType.CoachReviewedMeal,Notification.NotificationType.SummaryAvailableUser,Notification.NotificationType.UserSubmittedNoMeals])
        query.findObjectsInBackgroundWithBlock { (results : [AnyObject]?, error: NSError?) -> Void in
            
            /**  TODO: Handle error if it occurred. */
            if (error != nil) {
                let userInfoDict  = [ModelErrorType.ErrorToGetUserNotificationForCoach: error!]
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationModel.ModelNotifications.GetUserNotificationForCoach, object: self, userInfo: userInfoDict)
                
            }else{
                if let notifications = results  {
                    
                    /** check if empty data returned. */
                    if(notifications.isEmpty == true ){

                        self.notificationsList = []
                        
                        /** Post Notification. */
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationModel.ModelNotifications.GetUserNotificationForCoach, object: self)
                        
                        return
                    }
                    
                    /** Clear the Data List . */
                    self.notificationsList.removeAll(keepCapacity: false)
                    
                    /** Add the Results to Model Data. */
                    for result in notifications as! [Notification] {
                        self.notificationsList.append(result)
                    }
                    
                    /** Post Notification. */
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationModel.ModelNotifications.GetUserNotificationForCoach, object: self)
                }
            }
        }
    }
    
    /** Get User Notification Count. */
    func getUserNotificationCount() {
        var query = PFQuery(className:Notification.parseClassName())
        query.whereKey(Notification.ParseKeys.TargetUser, equalTo:self.selectedUser)
        query.whereKey(Notification.ParseKeys.User, equalTo:self.selectedUser)
        query.whereKey(Notification.ParseKeys.Coach, equalTo:self.selectedUser.coach!)
        query.whereKeyDoesNotExist(Notification.ParseKeys.ViewedAt)
        query.whereKey(Notification.ParseKeys.NotificationType, notContainedIn: [Notification.NotificationType.CoachAcceptedLinkRequest,Notification.NotificationType.CoachPendingLinkRequests,Notification.NotificationType.CoachRejectedLinkRequest,Notification.NotificationType.CoachUnlinked,Notification.NotificationType.UserCancelledLinkRequest,Notification.NotificationType.UserSentLinkRequest,Notification.NotificationType.UserUnlinked,Notification.NotificationType.NewMeal,Notification.NotificationType.SummaryAvailableCoach,Notification.NotificationType.UserCommented,Notification.NotificationType.SummaryReminderEndOfWeek,Notification.NotificationType.CoachReviewMealsReminder])
        query.countObjectsInBackgroundWithBlock { (count : Int32,  error: NSError?) -> Void in
            /** The find succeeded. */
            if error == nil {
                AppDelegate.getAppDelegate().userTabBarController?.selectedUser.notificationCount = Int(count)
                /** send Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetUserNotificationCountForUser, object: NSNumber(int: count))
            }else{
                
            }
        }
    }
    
    /** Get User Notifications. */
    func getUserNotifications() {
        var query = PFQuery(className:Notification.parseClassName())
        query.whereKey(Notification.ParseKeys.TargetUser, equalTo:self.selectedUser)
        query.whereKey(Notification.ParseKeys.User, equalTo:self.selectedUser)
        query.whereKey(Notification.ParseKeys.Coach, equalTo:self.selectedUser.coach!)
        query.whereKeyDoesNotExist(Notification.ParseKeys.ViewedAt)
        query.includeKey(Notification.ParseKeys.TargetMeal)
        query.includeKey(Notification.ParseKeys.Coach)
        query.includeKey(Notification.ParseKeys.User)
        query.whereKey(Notification.ParseKeys.NotificationType, notContainedIn: [Notification.NotificationType.CoachAcceptedLinkRequest,Notification.NotificationType.CoachPendingLinkRequests,Notification.NotificationType.CoachRejectedLinkRequest,Notification.NotificationType.CoachUnlinked,Notification.NotificationType.UserCancelledLinkRequest,Notification.NotificationType.UserSentLinkRequest,Notification.NotificationType.UserUnlinked,Notification.NotificationType.NewMeal,Notification.NotificationType.SummaryAvailableCoach,Notification.NotificationType.UserCommented,Notification.NotificationType.SummaryReminderEndOfWeek,Notification.NotificationType.CoachReviewMealsReminder])
        query.findObjectsInBackgroundWithBlock { (results : [AnyObject]?, error: NSError?) -> Void in
            /**  TODO: Handle error if it occurred. */
            if (error != nil) {
                let userInfoDict  = [ModelErrorType.ErrorToGetUserNotification: error!]
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(NotificationModel.ModelNotifications.GetUserNotification, object: self, userInfo: userInfoDict)
                
            }else{
                if let notifications = results  {
                    
                    /** check if empty data returned. */
                    if(notifications.isEmpty == true ){
                        
                        self.notificationsList = []
                        
                        /** Post Notification. */
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationModel.ModelNotifications.GetUserNotification, object: self)
                        
                        return
                    }
                    
                    /** Clear the Data List . */
                    self.notificationsList.removeAll(keepCapacity: false)
                    
                    /** Add the Results to Model Data. */
                    for result in notifications as! [Notification] {
                        self.notificationsList.append(result)
                    }
                    
                    /** Post Notification. */
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationModel.ModelNotifications.GetUserNotification, object: self)
                }
            }
        }
    }
    
    /** Notification has Viewed. */
    func notificationHasViewed(notification : Notification) {
        notification.viewedAt = NSDate()
        notification.saveInBackgroundWithBlock { (isFinished : Bool, error : NSError?) -> Void in
            /** The find succeeded. */
            if error == nil {

                /** Get User Notifications. */
                if let selectedUser = AppDelegate.getAppDelegate().userTabBarController?.selectedUser {
                    selectedUser.notificationCount = selectedUser.notificationCount - 1
                    if (User.isLoginUserCoach() == true) {
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetUserNotificationCountForCoach, object: NSNumber(integer: selectedUser.notificationCount))
                    }else{
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetUserNotificationCountForUser, object: NSNumber(integer: selectedUser.notificationCount))
                    }

                }
            }else {
                /** Nothing To Do. */
            }
        }
    }
}
