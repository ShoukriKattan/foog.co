//
//  PushNotificationHandler.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 7/20/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class PushNotificationHandler : NSObject, UIAlertViewDelegate {

    static var instance: PushNotificationHandler!
    
    /** Notification. */
    var currentNotificationObjectID : String = ""
    
    /** Notification Type. */
    var currentNotificationType : String = ""
    
    /** Shared Instance. */
    class func sharedInstance() -> PushNotificationHandler {
        self.instance = (self.instance ?? PushNotificationHandler())
        return self.instance
    }
    
    /** Init. */
    override init() {
        
    }

    /** Show Push Notification Message. */
    func showPushNotoficationMessage(userInfo : [NSObject : AnyObject]) {
      
        /** Get Notification. */
        if let notificationObjectId = userInfo["objectId"] as? String{
            currentNotificationObjectID = notificationObjectId
        }else{
            currentNotificationObjectID = ""
            return
        }
        
        /** Get Notification Type. */
        self.currentNotificationType = ""
        if let tempNotificationType = userInfo["type"] as? String{
            self.currentNotificationType = tempNotificationType
        }
        
        //Get Message Title
        var messageTitle = ""
        if let title = userInfo["title"] as? String {
            messageTitle += title
        }
        
        //Get Message Body
        var messageBody = ""
        if let body = userInfo["message"] as? String {
            messageBody += body
        }
        
        if objc_getClass("UIAlertController") != nil {
            var alertViewController = UIAlertController(title: messageTitle, message: messageBody, preferredStyle: UIAlertControllerStyle.Alert)
            alertViewController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
                
                alertViewController.dismissViewControllerAnimated(true, completion: nil)
                
                self.handleAlertCancelButton()
            }))
            
            if(self.currentNotificationType != Notification.NotificationType.UserSubmittedNoMeals && self.currentNotificationType != Notification.NotificationType.UserCancelledLinkRequest  && self.currentNotificationType != Notification.NotificationType.UserUnlinked && self.currentNotificationType != Notification.NotificationType.CoachUnlinked && self.currentNotificationType != Notification.NotificationType.CoachRejectedLinkRequest && self.currentNotificationType != Notification.NotificationType.CoachAcceptedLinkRequest) {
                alertViewController.addAction(UIAlertAction(title: "View", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                    self.handleNotification()
                }))
            }

            if let rootViewController = UIApplication.topViewController() {
                    rootViewController.presentViewController(alertViewController, animated: true, completion: nil)
            }

        }
        else {
            var alertView = UIAlertView()
            alertView.title = messageTitle
            alertView.message = messageBody
            alertView.addButtonWithTitle("Ok")
            if(self.currentNotificationType != Notification.NotificationType.UserSubmittedNoMeals && self.currentNotificationType != Notification.NotificationType.UserCancelledLinkRequest  && self.currentNotificationType != Notification.NotificationType.UserUnlinked && self.currentNotificationType != Notification.NotificationType.CoachUnlinked && self.currentNotificationType != Notification.NotificationType.CoachRejectedLinkRequest && self.currentNotificationType != Notification.NotificationType.CoachAcceptedLinkRequest) {
                alertView.addButtonWithTitle("View")
            }
            alertView.delegate = self
            alertView.show()
        }
    }
    
    /** Called when a button is clicked. The view will be automatically dismissed after this call returns. */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 0){
            alertView.dismissWithClickedButtonIndex(0, animated: true)
            self.handleAlertCancelButton()
        }else{
            self.handleNotification()
        }
    }
    
    /** Handle Notification. */
    func handleNotification(){
        
        /** Get Notification. */
        if self.currentNotificationObjectID.isEmpty == false {
            var query = PFQuery(className:Notification.parseClassName())
            query.includeKey(Notification.ParseKeys.TargetMeal)
            query.includeKey(Notification.ParseKeys.Coach)
            query.includeKey(Notification.ParseKeys.User)
            query.getObjectInBackgroundWithId(self.currentNotificationObjectID, block: { (tempNotification :PFObject? ,error : NSError?) -> Void in
                
                if let notification = tempNotification as? Notification {
                    if(notification.notificationType == Notification.NotificationType.CoachCommented){
                        self.showMealDetailsView(notification)
                    }else if(notification.notificationType == Notification.NotificationType.CoachReviewedMeal){
                        self.showMealDetailsView(notification)
                    }else if(notification.notificationType == Notification.NotificationType.NewMeal){
                        self.showMealDetailsView(notification)
                    }else if(notification.notificationType == Notification.NotificationType.UserCommented){
                        self.showMealDetailsView(notification)
                    }
                    /** Coach Review Meals Reminder Notification. */
                    else if(notification.notificationType == Notification.NotificationType.CoachReviewMealsReminder){
                        self.showUserFlowView(notification)
                    }
                    /** Summary Available Coach Notification. */
                    else if(notification.notificationType == Notification.NotificationType.SummaryAvailableCoach){
                        self.showSummaryCardView(notification)
                    }
                    /** Summary Available User Notification. */
                    else if(notification.notificationType == Notification.NotificationType.SummaryAvailableUser) {
                       self.showSummaryCardView(notification)
                    }
                    /** Summary Reminder End Of Week Notification. */
                    else if(notification.notificationType == Notification.NotificationType.SummaryReminderEndOfWeek){
                        self.showSummaryCardView(notification)
                    }
                    /** User Sent Link Request Notification. */
                    else if(notification.notificationType == Notification.NotificationType.UserSentLinkRequest){
                        self.showPendingLinkRequests()
                    }
                    /** Coach has Pending Link Requests Notification. */
                    else if(notification.notificationType == Notification.NotificationType.CoachPendingLinkRequests){
                        self.showPendingLinkRequests()
                    }
                    
                }
                
                /** Update Notification Count inside the app. */
                var currentInstallation = PFInstallation.currentInstallation()
                if (User.isLoginUserCoach() == true) {
                    /** Get Users Notifications count. */
                    AppDelegate.getAppDelegate().coachViewController.notificationModel?.getUserNotificationCountsForCoach()
                    
                    if let userTab = AppDelegate.getAppDelegate().userTabBarController {
                        AppDelegate.getAppDelegate().userTabBarController?.getNotificationCount()
                    }
                }else{
                    AppDelegate.getAppDelegate().userTabBarController?.getNotificationCount()
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                }
                currentInstallation.saveInBackground()
            })
        }
    }
    
    /** Show Meal Details View. */
    func showMealDetailsView(notification : Notification) {
        if let meal = notification.targetMeal {
            /** Show User View Controller. */
            LandingViewController.showUserTabBarView(notification.user!)
            
            var mealDetailsViewController = MealDetailsViewController(nibName:"MealDetailsViewController", bundle:nil)
            mealDetailsViewController.hidesBottomBarWhenPushed = true;
            mealDetailsViewController.selectedMeal = meal
            /** Show Meal View Controller. */
            if let viewControllers = AppDelegate.getAppDelegate().userTabBarController?.viewControllers  {
                if let userFlowNavigationController = viewControllers[0] as? UINavigationController {
                    var mealDetailsViewController = MealDetailsViewController(nibName:"MealDetailsViewController", bundle:nil)
                    mealDetailsViewController.hidesBottomBarWhenPushed = true;
                    mealDetailsViewController.selectedMeal = notification.targetMeal
                    userFlowNavigationController.pushViewController(mealDetailsViewController, animated: true)
                }
                
            }
        }
    }
    
    /** Show User Flow View. */
    func showUserFlowView(notification : Notification) {
        /** Show User View Controller. */
        LandingViewController.showUserTabBarView(notification.user!)
    }
    
    /** Show Summary Card View. */
    func showSummaryCardView(notification : Notification) {
        /** Show User View Controller. */
        LandingViewController.showUserTabBarView(notification.user!)
        AppDelegate.getAppDelegate().userTabBarController?.selectedIndex = 1
    }
    
    /** Show Pending Link Requests. */
    func showPendingLinkRequests(){
        
        if let rootViewController = UIApplication.topViewController() {
            var linkRequestsViewController = LinkRequestsViewController(nibName: "LinkRequestsViewController", bundle: nil)
            var linkRequestsNavigationViewController  =  UINavigationController(rootViewController: linkRequestsViewController)
            rootViewController.navigationController?.presentViewController(linkRequestsNavigationViewController, animated: true, completion: nil)
        }
    }
    
    /** Handle Alert Cancel Button. */
    func handleAlertCancelButton() {
        /** In case User Un Link then we should take the coach to home and refresh view. */
        if( self.currentNotificationType == Notification.NotificationType.UserUnlinked) {
            LandingViewController.showCoachView(false)
        }
        /** In case Coach Un Link then we should log out the user. */
        else if( self.currentNotificationType == Notification.NotificationType.CoachUnlinked) {
            User.logOut()
            LandingViewController.showSyncViewController()
        }
        /** In case User Cancelled Link then we should take the coach to home and refresh view. */
        else if( self.currentNotificationType == Notification.NotificationType.UserCancelledLinkRequest) {
            LandingViewController.showCoachView(false)
        }
        /** In case Coach Accept Link then we should take the User to Landing Page. */
        else if( self.currentNotificationType == Notification.NotificationType.CoachAcceptedLinkRequest) {
            AppDelegate.getAppDelegate().showLandingPage()
        }
        /** In case Coach Reject Link then we should take the User to Landing Page. */
        else if( self.currentNotificationType == Notification.NotificationType.CoachRejectedLinkRequest) {
            AppDelegate.getAppDelegate().showLandingPage()
        }else{
            /** Increase Badge Count. */
            var currentInstallation = PFInstallation.currentInstallation()
            UIApplication.sharedApplication().applicationIconBadgeNumber = currentInstallation.badge + 1
            currentInstallation.saveInBackground()
            
            /** Update Notification Count inside the app. */
            if (User.isLoginUserCoach() == true) {
                
                /** Get Users Notifications count. */
                AppDelegate.getAppDelegate().coachViewController.notificationModel?.getUserNotificationCountsForCoach()
                
                if let userTab = AppDelegate.getAppDelegate().userTabBarController {
                    AppDelegate.getAppDelegate().userTabBarController?.getNotificationCount()
                }
                
            }else{
                AppDelegate.getAppDelegate().userTabBarController?.getNotificationCount()
            }
        }
    }
}
