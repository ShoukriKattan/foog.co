//
//  UserPinFlowViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/5/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class UserPinFlowViewController: UIViewController , UserFlowTableViewDelegate {
    
    /** IBOutlet to Pinnd Meals table view. */
    @IBOutlet weak var userPinnedMealTableView: MealsFlowTableView!
    
    /** No posts label */
    @IBOutlet weak var noPostsLbl: UILabel!
    
    /** User Model. */
    var userModel : UserModel?

    /** Should Show Back Arrow on Navigation Bar. */
    var showBackArrow : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /** Make sure that items table view is hidden and activity indicator is visible. */
        self.userPinnedMealTableView.tableView.hidden = true
        self.userPinnedMealTableView.activityIndicator.hidden = false
        self.userPinnedMealTableView.activityIndicator.startAnimating()
        
        /** Register Notifications */
        self.registerNotifications()
        
        /** Set Delegate */
        self.userPinnedMealTableView.delegate = self
        
        /**  Init User Model. */
        self.userModel = UserModel()
        var selectedUser = AppDelegate.getAppDelegate().userTabBarController?.selectedUser as User!
        self.userModel?.selectedUser = selectedUser
        
        /** Get List of User Pinned Meals Flow. */
        self.userModel?.pageNumber = 0
        self.userModel?.getUserPinnedMealsFlow()
        
        if(self.showBackArrow == false){
            /** Add Back to Coach View in case the login user is coach. */
            if (User.isLoginUserCoach() == true) {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back_To _Coach_View.png"), style: UIBarButtonItemStyle.Plain, target:self, action: Selector("showCoachView"))
            }
            
            /** Add User Notification Bar Item. */
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: UserTabBarController.buildUserNotificationContainerView(selectedUser.notificationCount,viewController: self))
        }else{
            /** Add Back Button Bar Item. */
            var backBarItem = UIBarButtonItem(image: UIImage(named: "Back_Button.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonPressed")
            self.navigationItem.leftBarButtonItem = backBarItem
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Pin"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** User did Press Back Button. */
    func backButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /** Show Coach View. */
    func showCoachView(){
        LandingViewController.showCoachView(false)
    }
    
    /** Register Notifications. */
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: UserModel.ModelNotifications.GetListOfUserPinnedMealsNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: MealModel.ModelNotifications.mealHasReviewedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: MealModel.ModelNotifications.mealHasPinnedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: MealModel.ModelNotifications.mealHasUnPinnedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: NotificationModel.ModelNotifications.GetUserNotificationCountForCoach, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: NotificationModel.ModelNotifications.GetUserNotificationCountForUser, object: nil)
    }
    
    //Handle Notifications
    func handleNotifications(notification: NSNotification) {
        
        //Get Active Users
        if notification.name == UserModel.ModelNotifications.GetListOfUserPinnedMealsNotification {
            var notificationModel: UserModel  = notification.object as! UserModel
            
            
            //Check the same User Model
            if notificationModel.selectedUser.id == self.userModel?.selectedUser.id {
                
                //Check if No error Returned
                if let error = notification.userInfo {
                    
                }else{
                    self.userModel?.dataList = notificationModel.dataList
                    
                    if notificationModel.dataList.count == 0 {
                        self.noPostsLbl.text = FoogMessages.NoPinnedPostForSelectedUser
                        self.noPostsLbl.hidden = false
                    } else {
                        self.noPostsLbl.hidden = true
                    }
                    
                    self.userPinnedMealTableView.dataList = self.userModel?.dataList as! [[AnyObject]]
                    
                    // Update table view.
                    self.userPinnedMealTableView.tableView.reloadData()
                    
                    // Hide activity indicator and show items table.
                    self.userPinnedMealTableView.isLoadingMore = false
                    self.userPinnedMealTableView.activityIndicator.hidden = true
                    self.userPinnedMealTableView.tableView.hidden = false
                    self.userPinnedMealTableView.hideLoadingMoreFooterView()
                }
            }
        }
        /** Handle Meal Has Reviewed Notification */
        else if notification.name == MealModel.ModelNotifications.mealHasReviewedNotification {
            var notificationModel: MealModel  = notification.object as! MealModel
            
            /** find Meal in List. */
            for (var i : Int = 0 ; i < self.userModel?.dataList.count ; i++ ) {
                var mealsList = self.userModel?.dataList[i] as! [Meal]
                for (var j : Int = 0 ; j < mealsList.count ; j++ ) {
                    var meal = mealsList[j]
                    if(meal.objectId == notificationModel.selectedMeal.objectId){
                        mealsList[j] = notificationModel.selectedMeal
                        self.userModel?.dataList[i]  = mealsList
                        self.userPinnedMealTableView.dataList = self.userModel?.dataList as! [[AnyObject]]
                        
                        // Update table view.
                        self.userPinnedMealTableView.tableView.reloadData()
                        break
                    }
                }
            }
        }
        /** Handel Meal Pinned/Un Pinned Notification */
        else if (notification.name == MealModel.ModelNotifications.mealHasUnPinnedNotification || notification.name == MealModel.ModelNotifications.mealHasPinnedNotification) {
            var notificationModel: MealModel  = notification.object as! MealModel
            
            //Check if No error Returned
            if let error = notification.userInfo {
                
            }else{
                /** Get User Flow. */
                self.userModel?.pageNumber = 0
                self.userModel?.dataList.removeAll(keepCapacity: false)
                self.userModel?.getUserPinnedMealsFlow()
            }
        }
        /** Handle Notification Count for User by Coach and For UserNotification */
        if (notification.name == NotificationModel.ModelNotifications.GetUserNotificationCountForCoach ||  notification.name == NotificationModel.ModelNotifications.GetUserNotificationCountForUser){
            //Check if No error Returned
            if let error = notification.userInfo {
            }else{
                /** Add User Notification Bar Item. */
                if let count = notification.object as? NSNumber {
                    if(self.showBackArrow == false){
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: UserTabBarController.buildUserNotificationContainerView(Int(count.intValue), viewController: self))
                    }
                }
            }
        }
    }
    
    /** User did select a Meal */
    func userFlowTableViewDidSelectMeal(meal: Meal) {
        var mealDetailsViewController = MealDetailsViewController(nibName:"MealDetailsViewController", bundle:nil)
        mealDetailsViewController.hidesBottomBarWhenPushed = true;
        mealDetailsViewController.selectedMeal = meal
        self.navigationController?.pushViewController(mealDetailsViewController, animated: true)
        
    }
    
    /** Load More Data */
    func loadMore() {
        if (self.userModel?.hasMoreData == true) {
            self.userModel?.getUserPinnedMealsFlow()
        }else{
            self.userPinnedMealTableView.hideLoadingMoreFooterView()
        }
    }
    
    /** Go to Notification View. */
    func goToNotificationView() {
        var notificationViewController = NotificationViewController(nibName:"NotificationViewController", bundle:nil)
        notificationViewController.hidesBottomBarWhenPushed = true;
        var notificationNavigationController = UINavigationController(rootViewController: notificationViewController)
        
        self.navigationController?.presentViewController(notificationNavigationController, animated: true, completion: nil)
    }

}
