//
//  CoachViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/5/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit
import Parse

class CoachViewController: UIViewController , CoachCollectionViewDelegate {

    /** UI Components */
    @IBOutlet weak var collectionView: CoachCollectionView!
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var inActiveButton: UIButton!
    @IBOutlet weak var noUsersLbl: UILabel!
    
    
    /** Coach Model */
    var activeCoachModel : CoachModel?
    var inActiveCoachModel : CoachModel?
    
    /** Notification Model. */
    var notificationModel : NotificationModel?
    
    /** Temp Coach User and i will remove it after implenting the login */
    var currentCoach : User?
    
    /** Handler for click event on settings button at navigation bar. */
    func settingsBtnClicked() {
        
        // Show settings view.
        let settingsViewController = CoachSettingsViewController(nibName: "CoachSettingsViewController", bundle: nil)
        self.navigationController?.pushViewController(settingsViewController, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)

        /** Set Delegate */
        self.collectionView.delegate = self
        
        /** init Coach Model. */
        self.activeCoachModel  = CoachModel(coach: PFUser.currentUser() as! User)
        
        /** Init Notification Model. */
        self.notificationModel = NotificationModel(user: PFUser.currentUser() as! User)
    
        
        /** Register Notifications */
        self.registerNotifications()
        
        /** Set Buttons Images */
        self.inActiveButton.setBackgroundImage(UIUtilities.getGradientBlueImage(true, size: self.inActiveButton.bounds.size), forState: UIControlState.Normal)
        self.activeButton.setBackgroundImage(UIUtilities.getGradientGreenImage(true, size: self.activeButton.bounds.size), forState: UIControlState.Normal)
        
        /** Add Pending Users Icon. */
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "No_Pending_User_Request.png"), style: UIBarButtonItemStyle.Plain, target:self, action: Selector("goToPendingUsersList"))
        
        /** Add settings button to navigation bar. */
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "SettingsBarItem.png"), style: UIBarButtonItemStyle.Plain, target:self, action: Selector("settingsBtnClicked"))
    
        /** Add Foog  Icon to Navigation Bar. */
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Foog_Icon.png"))
        
        //Set Color of Navigation Controller
        self.edgesForExtendedLayout = UIRectEdge.None
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.translucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /** Get Active Users. */
        if self.collectionView.tableType == CoachCollectionView.CoachTableViewType.ActiveType {
            self.getActiveUsersList(true)
        }else{
           self.coachDidSelectInActiveUsers(self.inActiveButton)
        }
     
    }
    
    /** Reset Values. */
    func resetValues() {
        /** init Coach Model. */
        self.activeCoachModel?.selectedCoach = PFUser.currentUser() as! User
        
        /** Init Notification Model. */
        self.notificationModel?.selectedUser = PFUser.currentUser() as! User
    }
    
    /** Register Notifications */
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: CoachModel.ModelNotifications.GetListOfActiveUsersByCoachNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: CoachModel.ModelNotifications.GetListOfInActiveUsersByCoachNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: NotificationModel.ModelNotifications.GetListOfUserNotificationCountsForCoachNotification, object: nil)
    }

    /** Handle Notifications.*/
    func handleNotifications(notification: NSNotification) {
    
        /** Get Active Users */
        if notification.name == CoachModel.ModelNotifications.GetListOfActiveUsersByCoachNotification {
            var notificationModel: CoachModel  = notification.object as! CoachModel
            /** Check the same Coach Model */
            if notificationModel.selectedCoach.id == self.activeCoachModel?.selectedCoach.id {
                self.activeCoachModel?.userList = notificationModel.userList
                
                /** Get Un reviewed Meals count. */
                self.notificationModel?.getUserNotificationCountsForCoach()
                
            }
        }
        /** Get In Active Users */
        else if notification.name == CoachModel.ModelNotifications.GetListOfInActiveUsersByCoachNotification {
            var notificationModel: CoachModel  = notification.object as! CoachModel
            /** Check the same Coach Model */
            if notificationModel.selectedCoach.id == self.inActiveCoachModel?.selectedCoach.id {
                self.inActiveCoachModel?.userList = notificationModel.userList
                
                /** Update Data in Table in case we are in In active View */
                if self.collectionView.tableType == CoachCollectionView.CoachTableViewType.InActiveType {
                    
                    /** Show placeholder label if there is no users. */
                    if notificationModel.userList.count == 0 {
                        self.noUsersLbl.text = FoogMessages.NoInactiveUsersPlaceholder
                        self.noUsersLbl.hidden = false
                    } else {
                        self.noUsersLbl.hidden = true
                    }
                    
                    
                    self.collectionView?.dataList = self.inActiveCoachModel!.userList
                    self.collectionView?.collectionTableView.reloadData()
                    
                    /** Show Table. */
                    //self.collectionView.collectionTableView.hidden = false
                }

            }
        }
        /** Get In Active Users */
        else if notification.name == NotificationModel.ModelNotifications.GetListOfUserNotificationCountsForCoachNotification {
            var notificationModel: NotificationModel  = notification.object as! NotificationModel
            /** Check the same Coach Model */
            if notificationModel.selectedUser.id == self.notificationModel?.selectedUser.id {
               
                /** Get Values. */
                if let userInfo = notification.userInfo as? Dictionary<String,[String : AnyObject]> {
                
                    if let results = userInfo["results"] {
                        /** Update Data in Table in case we are in In active View */
                        if self.collectionView.tableType == CoachCollectionView.CoachTableViewType.ActiveType {
                            var dataListMap : [String : NSNumber] = [String : NSNumber]()
                            for (var i : Int = 0 ; i < self.activeCoachModel?.userList.count ; i++ ){
                                var user = self.activeCoachModel?.userList[i]
                                dataListMap[user!.objectId!] = NSNumber(integer: i)
                            }
                        
                            for  (key, value) in results  {
                                if let index = dataListMap[key] {
                                    var user = self.activeCoachModel?.userList[index.integerValue]
                                    user?.unreviewedNotificationCount = value.integerValue
                                }
                            }
                    
                                
                            /** Show placeholder label if there is no users. */
                            if self.activeCoachModel!.userList.count == 0 {
                                self.noUsersLbl.text = FoogMessages.NoActiveUsersPlaceholder
                                self.noUsersLbl.hidden = false
                            } else {
                                self.noUsersLbl.hidden = true
                            }
                            
                
                            self.collectionView?.dataList = self.activeCoachModel!.userList
                        
                            self.collectionView?.collectionTableView.reloadData()

                        }
                    }
                }
            }
        }
    }
    
    /** Coach Did Select Active Users */
    @IBAction func coachDidSelectActiveUsers(sender: UIButton) {
        self.getActiveUsersList(false)
    }
    
    /** Get Active Users For Coach */
    func getActiveUsersList(keepData : Bool){
        /** Make sure that no clients label is hidden. */
        self.noUsersLbl.hidden = true
        
        /** Hide Table. */
        self.collectionView.collectionTableView.hidden = false
        
        /** Set View Type */
        self.collectionView.tableType = CoachCollectionView.CoachTableViewType.ActiveType
        
        if(keepData == false){
            self.collectionView.dataList.removeAll(keepCapacity: false)
            self.collectionView?.collectionTableView.reloadData()
        }
        
        self.inActiveButton?.setBackgroundImage(UIUtilities.getGradientBlueImage(true, size: self.inActiveButton.bounds.size), forState: UIControlState.Normal)
        self.activeButton?.setBackgroundImage(UIUtilities.getGradientGreenImage(true, size: self.activeButton.bounds.size ), forState: UIControlState.Normal)
        
        if self.activeCoachModel == nil {
            self.activeCoachModel  = CoachModel()
            self.activeCoachModel!.selectedCoach = self.currentCoach!
        }
        
        self.activeCoachModel!.getActiveCoachUsers()
    }
    
    /** Coach Did Select In Active Users */
    @IBAction func coachDidSelectInActiveUsers(sender: UIButton) {
        
        // Make sure that no clients label is hidden.
        self.noUsersLbl.hidden = true
        
        /** Hide Table. */
        self.collectionView.collectionTableView.hidden = false
        
        /** Set View Type */
        self.collectionView.tableType = CoachCollectionView.CoachTableViewType.InActiveType
        
        self.collectionView.dataList.removeAll(keepCapacity: false)
        self.collectionView?.collectionTableView.reloadData()
        
        self.inActiveButton?.setBackgroundImage(UIUtilities.getGradientGreenImage(true, size: self.inActiveButton.bounds.size), forState: UIControlState.Normal)
        self.activeButton?.setBackgroundImage(UIUtilities.getGradientBlueImage(true, size: self.activeButton.bounds.size), forState: UIControlState.Normal)
        
        if self.inActiveCoachModel == nil {
            self.inActiveCoachModel  = CoachModel()
            self.inActiveCoachModel!.selectedCoach = PFUser.currentUser() as! User
        }
        
        self.inActiveCoachModel!.getInActiveCoachUsers()
    }
    
    /** Go To Pending Users List. */
    func goToPendingUsersList() {
        var linkRequestsViewController = LinkRequestsViewController(nibName: "LinkRequestsViewController", bundle: nil)
        var linkRequestsNavigationViewController  =  UINavigationController(rootViewController: linkRequestsViewController)
        self.navigationController?.presentViewController(linkRequestsNavigationViewController, animated: true, completion: nil)
    }
    
    /** Coach did select a user */
    func cooachCollectionViewDidSelectUser(user :  User) {
        var selectedUser  = user
        if(selectedUser.coach == nil) {
          selectedUser.coach = PFUser.currentUser() as? User
        }
        LandingViewController.showUserTabBarView(selectedUser)
    }
}



