//
//  UserProfileViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class UserProfileViewController: UIViewController {
    
    // MARK: - UserProfileViewController
    
    /** IBOutlet to Client Since UI label. */
    @IBOutlet weak var clientSinceLbl: UILabel!
    
    /** IBOutlet to user's Gender UI label. */
    @IBOutlet weak var genderLbl: UILabel!
    
    /** IBOutlet to user's Age UI label. */
    @IBOutlet weak var ageLbl: UILabel!
    
    /** IBOutlet to user's Start of Week UI label. */
    @IBOutlet weak var weekStartLbl: UILabel!
    
    /** IBOutlet to user's Height UI label. */
    @IBOutlet weak var heightLbl: UILabel!
    
    /** IBOutlet to user's weight UI label. */
    @IBOutlet weak var weightLbl: UILabel!
    
    /** IBOutlet to user's Body Fat UI label. */
    @IBOutlet weak var bodyFatLbl: UILabel!
    
    /** IBOutlet to user's Special Diet UI label. */
    @IBOutlet weak var dietLbl: UILabel!
    
    /** IBOutlet to user's Goals UI text view. */
    @IBOutlet weak var goalsTV: UITextView!
    
    /** IBOutlet to Move to Inactive / Active UI button. */
    @IBOutlet weak var moveToInactiveBtn: UIButton!
    
    /** User Model. */
    var userModel : UserModel!
    
    /** Reference to selected client. */
    var selectedClient : User!
    
    /** Main activity indicator in view's center UI field. */
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /** View Did Load. */
    override func viewDidLoad() {
        super.viewDidLoad()

        /** Set view's title to current user name. */
        self.selectedClient = AppDelegate.getAppDelegate().userTabBarController?.selectedUser
        self.navigationItem.title = "\(self.selectedClient.firstName) \(self.selectedClient!.lastName)"
        
        /** setup Navigation Bar Items. */
        self.setupNavigationBarItems()
        
        /** Register Notifications */
        self.registerNotifications()
        
        /**  Init User model. */
        self.userModel = UserModel()

        /** Set selected user for model. */
        self.userModel?.selectedUser = AppDelegate.getAppDelegate().userTabBarController?.selectedUser as User!
        
        /** Set gradient highlight to "Move To" button. */
        self.moveToInactiveBtn.setFoogDefaultTitleGradientColor()
        
        /** Add Back to Coach View in case the login user is coach. */
        if (User.isLoginUserCoach() == true) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back_To _Coach_View.png"), style: UIBarButtonItemStyle.Plain, target:self, action: Selector("showCoachView"))
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /** Start animating the indicator. */
        self.activityIndicator.startAnimating()
        self.activityIndicator.hidden = false
        
        /** Disable Move to Active/ Inactive button. */
        self.moveToInactiveBtn.enabled = false
        
        /** Get Client Info First. */
        self.userModel.getClientInfoBy(self.userModel.selectedUser, coach: self.userModel.selectedUser.coach!)
    }
    
    /** Show Coach View. */
    func showCoachView(){
        LandingViewController.showCoachView(false)
    }
    
    /** setup Navigation Bar Items. */
    func setupNavigationBarItems() {
        /** Set right Edit button. */
        let editButton = UIButton()
        editButton.setTitle("Edit", forState: UIControlState.Normal)
        editButton.addTarget(self, action: Selector("editBtnClicked"), forControlEvents: UIControlEvents.TouchUpInside)
        editButton.sizeToFit()
        editButton.setFoogDefaultTitleGradientColor()
        editButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
        let editBarItem = UIBarButtonItem(customView: editButton)
        self.navigationItem.rightBarButtonItem = editBarItem
    }
    
    /** Handler for click event of Edit button at navigation bar. */
    func editBtnClicked() {
        /** Show edit Bio view controller. */
        let editBioViewController = FHEditBioViewController(nibName: "FHEditBioViewController", bundle: nil)
        editBioViewController.user = self.userModel.selectedUser
        
        // Set gradient highlight to "Move To" button.
        self.moveToInactiveBtn.setFoogDefaultTitleGradientColor()
        editBioViewController.clientInfo = self.userModel.selectedClientInfo
        editBioViewController.clientInfo.user = self.userModel.selectedUser
        self.navigationController?.pushViewController(editBioViewController, animated: true)
    }
    
    /** Handler for click event on "Move To" button. */
    @IBAction func moveToInactiveBtnClicked(sender: AnyObject) {
        
        // Show modal activity view.
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: true, completion: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleInactiveUserNotification:"), name: CoachModel.ModelNotifications.InactiveUserNotification, object: nil)
        let coachModel = CoachModel()
        coachModel.moveUserToInactive(self.selectedClient, coach: User.currentUser()!)
        
    }
    
    /** Register Notifications. */
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: UserModel.ModelNotifications.GetClientInformationsNotification, object: nil)
    }
    
    /** Handle Notifications.*/
    func handleNotifications(notification: NSNotification) {
        /** Get Client Info */
        if notification.name == UserModel.ModelNotifications.GetClientInformationsNotification {
            var notificationModel: UserModel  = notification.object as! UserModel
        
            //Check the same User Model
            if notificationModel.selectedUser.id == self.userModel?.selectedUser.id {
                
                /** Stop animating the indicator. */
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                
                //Check if No error Returned
                if let error = notification.userInfo {
                
                }else{

                    var clientInfo = notificationModel.selectedClientInfo!
                    
                    // Assigne client info to UI fields.
                    if let createdDate = clientInfo.createdAt  {
                        self.clientSinceLbl.text = FoogDateUtilities.formattedDateFromDate(createdDate)
                    }else{
                        self.clientSinceLbl.text = ""
                    }

                    self.genderLbl.text = self.userModel.selectedUser.sex.rawValue
                    self.weekStartLbl.text = clientInfo.weekStartDay
                    self.heightLbl.text = clientInfo.height
                    self.weightLbl.text = clientInfo.weight
                    self.bodyFatLbl.text = "\(floor(clientInfo.bodyFatPercentage))"
                    if clientInfo.diet == "" {
                        self.dietLbl.text = FoogMessages.NoSpecialDiet
                        self.dietLbl.textColor = UIColor.lightGrayColor()
                    } else {
                        self.dietLbl.text = clientInfo.diet
                        self.dietLbl.textColor = UIColor.whiteColor()
                    }
                    if clientInfo.goals == "" {
                        self.goalsTV.text = FoogMessages.NoGoals
                        self.goalsTV.textColor = UIColor.lightGrayColor()
                    } else {
                        self.goalsTV.text = clientInfo.goals
                        self.goalsTV.textColor = UIColor.whiteColor()
                    }
                    self.goalsTV.selectable = false
                    // Calculate client's age.
                    let clientAge = NSCalendar.currentCalendar().components(NSCalendarUnit.YearCalendarUnit, fromDate: self.userModel.selectedUser.dateOfBirth!, toDate: NSDate(), options: NSCalendarOptions.MatchFirst).year
                    self.ageLbl.text = "\(clientAge) (\(FoogDateUtilities.formattedDateFromDate(self.userModel.selectedUser.dateOfBirth!)))"
                    
                    //Enable Move to Active/ inactive button
                    if(AppDelegate.getAppDelegate().userTabBarController?.selectedUser.isActive == true){
                       self.moveToInactiveBtn.enabled = true
                    }else{
                        self.moveToInactiveBtn.setTitle("User is Inactive", forState: UIControlState.Normal)
                        self.moveToInactiveBtn.enabled = false
                    }
                    

                }
            }
        }
    }
    
    /** Handle inactive user notification. */
    func handleInactiveUserNotification(notification : NSNotification) {
        
        // Hide modal activity view.
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            if let error = notification.userInfo {
                
                // TODO: Handle error.
                FoogAlert.show(FoogMessages.ErrorCouldNotMoveToInactive, context: self)
                
            } else {
                
                // Hide "Move to Inactive" button.
                self.moveToInactiveBtn.hidden = true
                
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: CoachModel.ModelNotifications.InactiveUserNotification, object: nil)
            
        })
        
    }
    
    
}
