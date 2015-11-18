//
//  WeeklySummaryViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/20/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class WeeklySummaryViewController: UIViewController, SummaryCardTableViewDelegate, CameraViewDelegate {

    /** IBOutlet to Summary Card table view. */
    @IBOutlet weak var summaryCardTableView: SummaryCardView!
    
    /** No posts label */
    @IBOutlet weak var noPostsLbl: UILabel!
    
    /** User Model. */
    var userModel : UserModel!
    
    /** Camera View. */
    var cameraViewController : CameraViewController?

    /** Should Show Back Arrow on Navigation Bar. */
    var showBackArrow : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Set view's title. */
        self.navigationItem.title = "Weekly Summary"
        
        /** Make sure that items table view is hidden and activity indicator is visible. */
        self.summaryCardTableView.tableView.hidden = true
        self.summaryCardTableView.tableLoadingIndicator.hidden = false
        self.summaryCardTableView.delegate = self
        self.summaryCardTableView.tableLoadingIndicator.startAnimating()
        
        /** Register Notifications */
        self.registerNotifications()
        
        /**  Init User model. */
        self.userModel = UserModel()
        
        /** Set selected user for model. */
        var selectedUser = AppDelegate.getAppDelegate().userTabBarController?.selectedUser as User!
        self.userModel?.selectedUser = selectedUser
        
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

        /** Get User Summary Cards. */
        self.userModel?.getSummaryCardsForCoach()
    }
    
    /** Show Coach View. */
    func showCoachView(){
        LandingViewController.showCoachView(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        /** Hide Tab Bar. */
        AppDelegate.getAppDelegate().userTabBarController?.tabBar.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** User did Press Back Button. */
    func backButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /** Register Notifications */
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: UserModel.ModelNotifications.GetListOfUserSummaryCardsNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: UserModel.ModelNotifications.GetClientInformationsNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: UserModel.ModelNotifications.UpdateSummaryCardNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: NotificationModel.ModelNotifications.GetUserNotificationCountForCoach, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: NotificationModel.ModelNotifications.GetUserNotificationCountForUser, object: nil)
    }
    
    /** Handle Notifications.*/
    func handleNotifications(notification: NSNotification) {
        
        /** Get Summary Cards List */
        if notification.name == UserModel.ModelNotifications.GetListOfUserSummaryCardsNotification {
            var notificationModel: UserModel  = notification.object as! UserModel
            
            //Check the same User Model
            if notificationModel.selectedUser.id == self.userModel?.selectedUser.id {
                //Check if No error Returned
                if let error = notification.userInfo {
                    
                }else{
                    self.userModel?.dataList = notificationModel.dataList
                    
                    if notificationModel.dataList.count == 0 && !User.currentUser()!.isCoach {
                        self.noPostsLbl.text = FoogMessages.NoSummaryCardForCurrentUser
                        self.noPostsLbl.hidden = false
                    } else {
                        self.noPostsLbl.hidden = true
                    }
                    
                    self.summaryCardTableView.dataList = self.userModel?.dataList as! [SummaryCard]
                    
                    // Update table view.
                    self.summaryCardTableView.tableView.reloadData()
                    
                    // Hide activity indicator and show items table.
                    self.summaryCardTableView.isLoadingMore = false
                    self.summaryCardTableView.tableLoadingIndicator.stopAnimating()
                    self.summaryCardTableView.tableLoadingIndicator.hidden = true
                    self.summaryCardTableView.tableView.hidden = false
                    self.summaryCardTableView.hideLoadingMoreFooterView()
                }
            }
  
        }
        /** Get Client Info */
        else if notification.name == UserModel.ModelNotifications.GetClientInformationsNotification {
            var notificationModel: UserModel  = notification.object as! UserModel
            
            //Check the same User Model
            if notificationModel.selectedUser.id == self.userModel?.selectedUser.id {
                //Check if No error Returned
                if let error = notification.userInfo {
                    
                }
            }
            
        }

        /** Update Summary Card Notification */
        else if notification.name == UserModel.ModelNotifications.UpdateSummaryCardNotification {
            var notificationModel: UserModel  = notification.object as! UserModel
            
            //Check the same User Model
            if notificationModel.selectedUser.id == self.userModel?.selectedUser.id {
                //Check if No error Returned
                if let error = notification.userInfo {
                    // Dismiss camera view.
                    self.cameraViewController?.postingFaild()
                }else{
                    // Dismiss modal activity indicator.
                    if(self.cameraViewController != nil) {
                        self.cameraViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                            
                            self.summaryCardTableView.tableView.reloadData()
                        })
                    }
                }
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
    
    /** User Did Select Expand User Image. */
    func summaryCardTableViewExpandUserImage(selectedCard : SummaryCard){
        var userImageViewController = SummaryCardUserImageViewController(nibName:"SummaryCardUserImageViewController", bundle:nil)
        userImageViewController.selectedSummaryCard = selectedCard
    
        var userImageNavigationViewController  =  UINavigationController(rootViewController: userImageViewController)
        
        userImageNavigationViewController.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        userImageViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.navigationController?.presentViewController(userImageNavigationViewController, animated: true, completion: nil)
   
    }
    
    /** Get Client Info.. */
    func getClientInfo() -> ClientInfo {
        return self.userModel.selectedClientInfo!
    }
    
    /** User Did Select Take Photo.. */
    func summaryCardTableViewTakePhoto(selectedCard : SummaryCard){
        
        /** Init Camer View Controller. */
        self.cameraViewController = nil
        self.cameraViewController = CameraViewController(nibName: "CameraViewController", bundle: nil)
        self.cameraViewController!.mode = CameraViewMode.SummaryMode
        self.cameraViewController!.delegate = self
        self.presentViewController(self.cameraViewController!, animated: true, completion: nil)
    }
    
    /** User Did Select Track User Info */
    func summaryCardTableViewTrackUserInfo(selectedCard : SummaryCard){
        var trackUserInfoViewController = TrackingUserInfoTableViewController(nibName: "TrackingUserInfoTableViewController", bundle: nil)
        trackUserInfoViewController.selectedClientInfo = self.userModel.selectedClientInfo!
        
        var trackUserInfoNavigationViewController  =  UINavigationController(rootViewController: trackUserInfoViewController)
        
        self.presentViewController(trackUserInfoNavigationViewController, animated: true , completion: nil)
    }
    
    /**
    This method is invoked when user take a photo and click "Post" button with taken photo and user's note parameter.
    This method should hide presented camera view controller.
    */
    func cameraViewDidTakePostImage(cameraViewController : CameraViewController, image : UIImage, note : String?){
        
        /** Get Summary Card. */
        var summaryCard = self.userModel?.dataList[0] as! SummaryCard
        let imageOriginal = image
        let image = imageOriginal.resizedImageWithContentMode(UIViewContentMode.ScaleAspectFit, bounds: Meal.Configration.imageFullSize, interpolationQuality: kCGInterpolationHigh)
        let thumbnail = imageOriginal.resizedImageWithContentMode(UIViewContentMode.ScaleAspectFit, bounds: Meal.Configration.imageThumbnailSize, interpolationQuality: kCGInterpolationHigh)
        let imageFile = PFFile(data: UIImageJPEGRepresentation(image, 0.95))
        let thumbnailFile = PFFile(data: UIImageJPEGRepresentation(thumbnail, 0.95))
        summaryCard.imageThumbnail = thumbnailFile
        summaryCard.imageOriginal = imageFile
        
        /** Update the Server. */
        self.userModel?.updateSummaryCard(summaryCard)

    }
    
    /** Load More Data */
    func summaryCardTableViewLoadMore() {
        if (self.userModel?.hasMoreData == true) {

        }else{
            self.summaryCardTableView.hideLoadingMoreFooterView()
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
