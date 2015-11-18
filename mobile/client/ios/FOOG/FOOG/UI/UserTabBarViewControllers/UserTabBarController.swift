//
//  UserTabBarController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/5/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class UserTabBarController: UITabBarController, UITabBarControllerDelegate, CameraViewDelegate {
    
    /** Selected User . */
    var selectedUser : User!
    
    /** Meal Model. */
    var mealModel : MealModel!
    
    /** Camera View. */
    var cameraViewController : CameraViewController?
    
    /** Notification Model. */
    var notificationModel : NotificationModel?
    
    convenience init(user : User) {
        self.init()
        self.selectedUser = user
        
        /**  Init Notification Model. */
        self.selectedUser.notificationCount = 0
        self.notificationModel = NotificationModel(user: self.selectedUser)
        
        /** Get User Notifications. */
        self.getNotificationCount()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Add View Controllers. */
        self.creatUserViewControllers()
        
        /** Set tab bar delegate to this class. */
        self.delegate = self
        self.tabBar.translucent = false
        
        var selectedImages: [String]
        var unSelectedImages: [String]
        if(User.isLoginUserCoach() == true){
            selectedImages = ["FlowSelected.png", "WeeklySummary_Selected.png", "PinSelected.png","ProfileBtnSelected.png"]
            unSelectedImages = ["FlowNotSelected.png", "WeeklySummary_NotSelected.png", "PinNotSelcted.png" ,"ProfileBtn.png"]
        }else{
            selectedImages = ["FlowSelected.png",  "WeeklySummary_Selected.png","CameraBtnSelected.png", "ProfileBtnSelected.png"]
            unSelectedImages = ["FlowNotSelected.png", "WeeklySummary_NotSelected.png","CameraBtn.png", "ProfileBtn.png"]
        }
        
        var i : Int  = 0
        for barItem in self.tabBar.items as! [UITabBarItem] {
            barItem.selectedImage = UIImage(named: selectedImages[i])?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            barItem.image = UIImage(named: unSelectedImages[i])?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
            i++
        }
        
        self.tabBar.backgroundImage = UIUtilities.getGradientBlueImage(true, size: CGSizeMake(UIScreen.mainScreen().bounds.width, 49.0))
        self.tabBar.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleWidth
        self.tabBar.autoresizesSubviews = false;
        self.tabBar.clipsToBounds = true;
        
        /**  Init Meal model. */
        self.mealModel = MealModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        
    }
    
    /** Get Notification Count. */
    func getNotificationCount() {
        if (User.isLoginUserCoach() == true) {
            self.notificationModel?.getUserNotificationCountForCoach(PFUser.currentUser() as! User)
        }else{
            self.notificationModel?.getUserNotificationCount()
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        
        if (viewController == tabBarController.viewControllers![2] as! UIViewController && User.isLoginUserCoach() == false) {
            
            // Present camera view controller as modal view.
            self.cameraViewController = CameraViewController(nibName: "CameraViewController", bundle: nil)
            self.cameraViewController!.mode = CameraViewMode.MealMode
            self.cameraViewController!.delegate = self
            self.presentViewController(self.cameraViewController!, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    // MARK: CameraViewDelegate
    
    /** Post user's meal when camera view post button is clicked with taken photo. */
    func cameraViewDidTakePostImage(cameraViewController: CameraViewController, image: UIImage, note: String?) {
        /** Register Notifications */
        self.registerNotifications()
        
        self.mealModel.postMeal(self.selectedUser, imageOriginal: image, note: note!)
    }
    
    /** Register Notifications. */
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: MealModel.ModelNotifications.postMealNotification, object: nil)
    }
    
    /** Handle Notifications.*/
    func handleNotifications(notification: NSNotification) {
        /** Handle Posted Meal Notification */
        if notification.name == MealModel.ModelNotifications.postMealNotification {
            //Check if No error Returned
            if let error = notification.userInfo {
                self.cameraViewController?.postingFaild()
            }else{
                self.cameraViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        /** Remove observer. */
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    /** Creat User ViewControllers. */
    func creatUserViewControllers(){
        
        /** Create User Flow View Controller. */
        var userFlowViewController = UserFlowViewController(nibName:"UserFlowViewController", bundle:nil)
        userFlowViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "FlowNotSelected.png"), tag: 0)
        userFlowViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        var userFlowNavigationController = UINavigationController(rootViewController: userFlowViewController)
        
        /** Create Camera View Controller. */
        let cameraViewController = ChatViewController(nibName: "CameraViewController", bundle: nil)
        cameraViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "CameraBtn.png"), tag: 0)
        cameraViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        
        /** Create User Weekly Summary View Controller. */
        var weeklySummaryViewController = WeeklySummaryViewController(nibName:"WeeklySummaryViewController", bundle:nil)
        weeklySummaryViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "WeeklySummary_NotSelected.png"), tag: 0)
        weeklySummaryViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        var weeklySummaryNavigationController = UINavigationController(rootViewController: weeklySummaryViewController)
        
        if(User.isLoginUserCoach() == true){
            /** Create User Pin Flow View Controller. */
            var userPinFlowViewController = UserPinFlowViewController(nibName:"UserPinFlowViewController", bundle:nil)
            userPinFlowViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "PinNotSelcted.png"), tag: 0)
            userPinFlowViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            var userPinFlowNavigationController = UINavigationController(rootViewController: userPinFlowViewController)
            
            // Create Profile View Controller
            var userProfileViewController = UserProfileViewController(nibName:"UserProfileViewController", bundle:nil)
            userProfileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ProfileBtn.png"), tag: 0)
            userProfileViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            var userProfileNavigationController = UINavigationController(rootViewController: userProfileViewController)
            
            self.viewControllers = [userFlowNavigationController, weeklySummaryNavigationController, userPinFlowNavigationController, userProfileNavigationController]
            
        }else{
            
            // Create Client profile view controller.
            var clientProfileViewController = ClientProfileViewController(nibName: "ClientProfileViewController", bundle: nil)
            clientProfileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "ProfileBtn.png"), tag: 0)
            clientProfileViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
            var clientProfileNavigationController = UINavigationController(rootViewController: clientProfileViewController)
            
            self.viewControllers = [userFlowNavigationController, weeklySummaryNavigationController,cameraViewController, clientProfileNavigationController]
        }
        
    }
    
    /** Build User Notification Container. */
    class func buildUserNotificationContainerView(count : Int , viewController : UIViewController) -> UIView {
        var width  : CGFloat = 56.0
        var height : CGFloat = 40.0
        
        /** Container View. */
        var userNotificationContainerView = UIView(frame: CGRectMake(0, 0, width, height))
        userNotificationContainerView.backgroundColor = UIColor.clearColor()
        
        /** Init User Notification Button. */
        var userNotificationButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        userNotificationButton?.frame = CGRectMake(15, 0, width, height)
        userNotificationButton?.backgroundColor = UIColor.clearColor()
        userNotificationButton?.titleLabel?.font = UIFont(name: UIUtilities.FontsName.helveticaBoldFont, size: 15.0)
        userNotificationButton?.addTarget(viewController, action: "goToNotificationView", forControlEvents: UIControlEvents.TouchUpInside)
        userNotificationContainerView.addSubview(userNotificationButton!)
        
        /** Init Circle Image View. */
        var imageWidth : CGFloat = 35.0
        var userNotificationCircleImageView = UIImageView(frame: CGRectMake((width - imageWidth)/2 + 15, (height - imageWidth)/2, imageWidth, imageWidth))
        userNotificationCircleImageView.backgroundColor = UIColor.clearColor()
        userNotificationContainerView.addSubview(userNotificationCircleImageView)
        
        /** Setup View By Count. */
        if(count  == 0){
            userNotificationButton?.setTitleColor(UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            
            userNotificationCircleImageView.image = UIImage(named: "Gray_Notifications_Circle.png")
        }else{
            userNotificationButton?.setTitleColor(UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: userNotificationButton!.frame.size)), forState: UIControlState.Normal)
            
            userNotificationCircleImageView.image = UIImage(named: "Green_Notifications_Circle.png")
        }
        
        userNotificationButton?.setTitle(String(count), forState: UIControlState.Normal)
    
        return userNotificationContainerView
    }
}
