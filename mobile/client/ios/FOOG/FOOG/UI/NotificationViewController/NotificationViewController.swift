//
//  NotificationViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 7/16/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class NotificationViewController: UIViewController, UITableViewDelegate {

    /** UI Components */
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    /** Notification Model. */
    var notificationModel : NotificationModel!
    
    /** Notifications List. */
    var notificationsList : [AnyObject] = []
    
    /** Gradient Layer */
    var gradientLayer : CAGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /** Set Color of Navigation Controller. */
        self.edgesForExtendedLayout = UIRectEdge.None
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.translucent = false
        
        /** Set Navigation Title. */
        self.navigationItem.title = "Notifications"
        
        /** Set Gradient Color. */
        self.gradientLayer = self.view.addDefaultGradientBackground()
        
        /** Set Right Bar Item. */
        self.setupRightNavgiationBarItem()
        
        /** Register Notifications */
        self.registerNotifications()
        
        /** Init Notification Model. */
        self.notificationModel = NotificationModel(user: AppDelegate.getAppDelegate().userTabBarController!.selectedUser!)
        
        /** Register Notification Cell .*/
        self.tableView.registerNib(UINib(nibName: NotificationViewCell.CellIdentifier, bundle: nil), forCellReuseIdentifier: NotificationViewCell.CellIdentifier)
        
        /** Get Notifications List. */
        self.tableView.hidden = true
        self.loadingActivityIndicator.startAnimating()
        
        /** In case the login user is coach te Get Notifications for selected User. */
        if (User.isLoginUserCoach() == true) {
            self.notificationModel.getUserNotificationsForCoach(User.currentUser()!)
        }else{
            self.notificationModel.getUserNotifications()
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    /** Set Right Bar Item. */
    func setupRightNavgiationBarItem() {
        var cancelButon =  UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        cancelButon!.frame = CGRectMake(0, 0, 40, 40)
        cancelButon?.setImage(UIImage(named: "Cancel.png"), forState: UIControlState.Normal)
        cancelButon?.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cancelButon?.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, -10)
        cancelButon?.contentMode = UIViewContentMode.Right
        cancelButon?.addTarget(self, action: "hideNotificationView", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButon!)
    }
    
    
    /** Hide Notification View. */
    func hideNotificationView(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    /** Register Notifications */
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: NotificationModel.ModelNotifications.GetUserNotificationForCoach, object: nil)
        
        /** Reject Notification. */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: NotificationModel.ModelNotifications.GetUserNotification, object: nil)
    }
    
    /** Handle Notifications.*/
    func handleNotifications(notification: NSNotification) {
        
        /** Get User Notification  For coach */
        if notification.name == NotificationModel.ModelNotifications.GetUserNotificationForCoach {
            var model: NotificationModel  = notification.object as! NotificationModel
            
            /** Check the same Model */
            if model.selectedUser.id == self.notificationModel?.selectedUser.id {
                
                //Check if error Returned
                if let error = notification.userInfo {
                    
                }else{
                    self.notificationModel?.notificationsList = model.notificationsList
                    
                    if( self.notificationModel?.notificationsList.count > 0){
                        self.notificationsList = self.notificationModel.notificationsList
                    }else{
                        self.notificationsList = ["has empty data"]
                    }
                    
                    self.tableView.reloadData()
                    self.loadingActivityIndicator.stopAnimating()
                    self.loadingActivityIndicator.hidden = true
                    self.tableView.hidden = false
                }

            }
        }
        /** Get User Notification */
        if notification.name == NotificationModel.ModelNotifications.GetUserNotification {
            var model: NotificationModel  = notification.object as! NotificationModel
            
            /** Check the same Model */
            if model.selectedUser.id == self.notificationModel?.selectedUser.id {
                
                //Check if error Returned
                if let error = notification.userInfo {
                    
                }else{
                    self.notificationModel?.notificationsList = model.notificationsList
                    
                    if( self.notificationModel?.notificationsList.count > 0){
                        self.notificationsList = self.notificationModel.notificationsList
                    }else{
                        self.notificationsList = ["has empty data"]
                    }
                    
                    self.tableView.reloadData()
                    self.loadingActivityIndicator.stopAnimating()
                    self.loadingActivityIndicator.hidden = true
                    self.tableView.hidden = false
                }
                
            }
        }
    }
    
    /** Handle Selection of Notification Cell. */
    func handleSelectionOfNotificationCell(notification : Notification){
        /** Coach Commented Notification Or Coach Reviewed Meal Notification Or New Meals Posted Notification Or User Commented Notification. */
        if(notification.notificationType == Notification.NotificationType.CoachCommented || notification.notificationType == Notification.NotificationType.CoachReviewedMeal || notification.notificationType == Notification.NotificationType.NewMeal || notification.notificationType == Notification.NotificationType.UserCommented){
            
            if let meal = notification.targetMeal {
                var mealDetailsViewController = MealDetailsViewController(nibName:"MealDetailsViewController", bundle:nil)
                mealDetailsViewController.hidesBottomBarWhenPushed = true;
                mealDetailsViewController.selectedMeal = meal
                self.navigationController?.pushViewController(mealDetailsViewController, animated: true)
                
            }
            
            /** Decrease Badge Count. */
            if notification.viewedAt == nil {
                
                /** Update Viewed At. */
                notification.viewedAt = NSDate()
                self.notificationModel.notificationHasViewed(notification)
                
                var currentInstallation = PFInstallation.currentInstallation()
                if (User.isLoginUserCoach() == true) {
                    UIApplication.sharedApplication().applicationIconBadgeNumber = currentInstallation.badge - 1
                }else{
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                }
                currentInstallation.saveInBackground()
            }
        }
        /** Coach Review Meals Reminder Notification. */
        else if(notification.notificationType == Notification.NotificationType.CoachReviewMealsReminder){
            
            /** Decrease Badge Count. */
            if notification.viewedAt == nil {
                
                /** Update Viewed At. */
                notification.viewedAt = NSDate()
                self.notificationModel.notificationHasViewed(notification)
                
                var currentInstallation = PFInstallation.currentInstallation()
                if (User.isLoginUserCoach() == true) {
                    UIApplication.sharedApplication().applicationIconBadgeNumber = currentInstallation.badge - 1
                }else{
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                }
                currentInstallation.saveInBackground()
            }
            

            
            var userFlowViewController = UserFlowViewController(nibName:"UserFlowViewController", bundle:nil)
            userFlowViewController.showBackArrow = true
            self.navigationController?.pushViewController(userFlowViewController, animated: true)
        }
        /** Summary Available Coach Notification OR  Summary Available User Notification Or Summary Reminder End Of Week Notification. */
        else if(notification.notificationType == Notification.NotificationType.SummaryAvailableCoach || notification.notificationType == Notification.NotificationType.SummaryAvailableUser || notification.notificationType == Notification.NotificationType.SummaryReminderEndOfWeek){
            
            /** Decrease Badge Count. */
            if notification.viewedAt == nil {
                
                /** Update Viewed At. */
                notification.viewedAt = NSDate()
                self.notificationModel.notificationHasViewed(notification)
            
                var currentInstallation = PFInstallation.currentInstallation()
                if (User.isLoginUserCoach() == true) {
                    UIApplication.sharedApplication().applicationIconBadgeNumber = currentInstallation.badge - 1
                }else{
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                }
                currentInstallation.saveInBackground()
            }
            

            var weeklySummaryViewController = WeeklySummaryViewController(nibName:"WeeklySummaryViewController", bundle:nil)
            weeklySummaryViewController.showBackArrow = true
            self.navigationController?.pushViewController(weeklySummaryViewController, animated: true)
        }
        /** User Submitted No Meals Notification. */
        else if(notification.notificationType == Notification.NotificationType.UserSubmittedNoMeals){
            /** Decrease Badge Count. */
            if notification.viewedAt == nil {
                
                /** Update Viewed At. */
                notification.viewedAt = NSDate()
                self.notificationModel.notificationHasViewed(notification)
                var currentInstallation = PFInstallation.currentInstallation()
                if (User.isLoginUserCoach() == true) {
                    UIApplication.sharedApplication().applicationIconBadgeNumber = currentInstallation.badge - 1
                }else{
                    UIApplication.sharedApplication().applicationIconBadgeNumber = 0
                }
                currentInstallation.saveInBackground()
            }
            

        }
    }

}
