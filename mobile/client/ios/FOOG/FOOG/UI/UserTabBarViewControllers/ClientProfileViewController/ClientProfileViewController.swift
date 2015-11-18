//
//  FHClientProfileViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 7/11/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class ClientProfileViewController: UIViewController, UITextFieldDelegate {
    
    /** IBOutlet to main scroll view which contains all view's UI field. */
    @IBOutlet weak var scrollView: UIScrollView!
    
    /** IBOutlet to space from main scroll view to view's bottom edge. */
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    /** IBOutlet to user's first name UI input text field. */
    @IBOutlet weak var firstNameTF: UITextField!
    
    /** IBOutlet to user's last name UI input text field. */
    @IBOutlet weak var lastNameTF: UITextField!
    
    /** IBOutlet to user's date of birth UI input text field. */
    @IBOutlet weak var dobTF: UITextField!
    
    /** IBOutlet to male UI button. */
    @IBOutlet weak var maleBtn: UIButton!
    
    /** IBOutlet to female UI button. */
    @IBOutlet weak var femaleBtn: UIButton!
    
    /** IBOutlet to unlink with coach UI button. */
    @IBOutlet weak var unlinkWithCoachBtn: UIButton!
    
    /** IBOutlet to log out UI button. */
    @IBOutlet weak var logOutBtn: UIButton!
    
    /** Reference to selected date of birth. */
    var dob : NSDate! = nil
    
    /** Reference to Save button should be shown / hidden at navigation bar. */
    var saveBarItem : UIBarButtonItem!
    
    /** Reference to Cancel button should be shown / hidden at navigation bar. */
    var cancelBarItem : UIBarButtonItem!
    
    /** Handler for clicking male UI button. */
    @IBAction func maleBtnClicked(sender: AnyObject) {
        if !self.maleBtn.selected {
            self.maleBtn.selected = true
            self.femaleBtn.selected = false
            self.setSaveAndCancelButtonsHidden(false)
        }
    }

    /** Handler for clicking female UI button. */
    @IBAction func femaleBtnClicked(sender: AnyObject) {
        if !self.femaleBtn.selected {
            self.maleBtn.selected = false
            self.femaleBtn.selected = true
            self.setSaveAndCancelButtonsHidden(false)
        }
    }
    
    /** Handler for clicking Unlink with Coach UI button. */
    @IBAction func unlinkWithCoachBtnClicked(sender: AnyObject) {
        // Show modal activity view.
        let modalActivityView = ModalActivityViewController.modalActivityViewController(self)
        self.presentViewController(modalActivityView, animated: true) { () -> Void in
            // Unlink current User from his current Coach.
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleUnlinkUserFromHisCoachNotofication:"), name: UserModel.ModelNotifications.UnlinkUserFromHisCoachNotification, object: nil)
            let currentUser = User.currentUser()!
            let userModel = UserModel()
            userModel.unlinkUserFromHisCoach(currentUser)
        }
        
    }
    
    /** Handler for clicking Log out UI button. */
    @IBAction func logOutBtnClicked(sender: AnyObject) {
        // Log out user and go back to Path view.
        User.logOut()
        LandingViewController.showPathViewController()
    }
    
    /** Resize scroll view to keep all fields visible when keyboard show up. */
    func keyboardWillShow(notification : NSNotification) {
        UIView.animateWithDuration(1, animations: { () -> Void in
            let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
            let keyboardHeight = keyboardFrame.CGRectValue().height
            self.scrollViewBottomSpaceConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        })
    }
    
    /** Resize scroll view to fill the whole view when keyboard hides. */
    func keyboardWillHide() {
        UIView.animateWithDuration(1, animations: { () -> Void in
            self.scrollViewBottomSpaceConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    /** Changed selected DOB when date picker value change. */
    func dobPickerValueChanged() {
        let datePicker = self.dobTF.inputView as! UIDatePicker
        self.dob = datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        self.dobTF.text = dateFormatter.stringFromDate(self.dob!)
        
        // Make sure that Save and Cancel buttons are visible.
        self.setSaveAndCancelButtonsHidden(false)
    }
    
    /** Save user's changes and hide Save and Cancel buttons. */
    func saveBtnClicked() {
        // Hide keyboard.
        self.view.endEditing(true)
        
        // Show modal activity view.
        let modalActivityView = ModalActivityViewController.modalActivityViewController(self)
        self.presentViewController(modalActivityView, animated: true) { () -> Void in
            
            // Save user's changes to Parse backend.
            if let currentUser = User.currentUser() {
                currentUser.firstName = self.firstNameTF.text
                currentUser.lastName = self.lastNameTF.text
                currentUser.dateOfBirth = self.dob
                currentUser.sex = self.maleBtn.selected ? SexType.Male : SexType.Female
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleSaveUserNotification:"), name: UserModel.ModelNotifications.SaveUserNotification, object: nil)
            
                var userModel = UserModel()
                userModel.saveUser(currentUser)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
        }
    }
    
    /** Handle save user notification. */
    func handleSaveUserNotification(notification : NSNotification) {
        
        // Hide modal activity view.
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            if let error = notification.userInfo {
                
                // TODO: Handle error.
                FoogAlert.show(FoogMessages.ErrorCouldNotSave, context: self)
                
            } else {
                
                self.setSaveAndCancelButtonsHidden(true)
                
            }
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UserModel.ModelNotifications.SaveUserNotification, object: nil)
            
        })
        
    }
    
    /** Handle unlink user from his coach notification. */
    func handleUnlinkUserFromHisCoachNotofication(notification : NSNotification) {
        
        // Hide modal activity view.
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            if let error = notification.userInfo {
                
                // TODO: Handle error.
                FoogAlert.show(FoogMessages.ErrorCouldNotUnlink, context: self)
                
            } else {
                
                // Show Sync View.
                let syncViewController = SyncViewController(nibName: "SyncViewController", bundle: nil)
                let syncNavigationController = UINavigationController(rootViewController: syncViewController)
                let window = UIApplication.sharedApplication().delegate!.window
                window!!.rootViewController = syncNavigationController
                
            }
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UserModel.ModelNotifications.UnlinkUserFromHisCoachNotification, object: nil)
        })
        
    }
    
    /** Restore user's info and hide Save and Cancel buttons. */
    func cancelBtnClicked() {
        // Hide keyboard.
        self.view.endEditing(true)
        
        self.assignCurrentUserInfoToUI()
        self.setSaveAndCancelButtonsHidden(true)
    }
    
    /** Show or hide Save and Cancel buttons at navigation bar. */
    func setSaveAndCancelButtonsHidden(hidden : Bool) {
        if hidden {
            self.navigationItem.setLeftBarButtonItem(nil, animated: true)
            self.navigationItem.setRightBarButtonItem(nil, animated: true)
        } else {
            self.navigationItem.setLeftBarButtonItem(self.cancelBarItem, animated: true)
            self.navigationItem.setRightBarButtonItem(self.saveBarItem, animated: true)
        }
    }
    
    /** Assign current client info to UI. */
    func assignCurrentUserInfoToUI() {
        if let currentClient = User.currentUser() {
            self.firstNameTF.text = currentClient.firstName
            self.lastNameTF.text = currentClient.lastName
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            self.dob = currentClient.dateOfBirth!
            self.dobTF.text = dateFormatter.stringFromDate(self.dob)
            let datePicker = self.dobTF.inputView as! UIDatePicker
            datePicker.setDate(self.dob, animated: true)
            if currentClient.sex == SexType.Male {
                self.maleBtn.selected = true
                self.femaleBtn.selected = false
            } else {
                self.maleBtn.selected = false
                self.femaleBtn.selected = true
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    /** Move focus over differnt input UI fields. */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.firstNameTF {
            self.lastNameTF.becomeFirstResponder()
        } else if textField == self.lastNameTF {
            self.dobTF.becomeFirstResponder()
        }
        
        return false
    }
    
    /** Make sure that Save and Cancel buttons are visible when user input change. */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Make sure that Save and Cancel buttons are visible.
        self.setSaveAndCancelButtonsHidden(false)
        
        return true
    }
    

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set default FOOG gradient background.
        self.view.addDefaultGradientBackground()
        
        // Add app icon to navigation bar.
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Foog_Icon.png"))
        
        // Set proper selected / unselected backgrounds for male and female buttons.
        self.maleBtn.setBackgroundImage(UIImage(named: "SegmentLeftUnselected.png"), forState: UIControlState.Normal)
        self.maleBtn.setBackgroundImage(UIImage(named: "SegmentLeftSelected.png"), forState: UIControlState.Selected)
        self.maleBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.maleBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
        self.femaleBtn.setBackgroundImage(UIImage(named: "SegmentRightUnselected.png"), forState: UIControlState.Normal)
        self.femaleBtn.setBackgroundImage(UIImage(named: "SegmentRightSelected.png"), forState: UIControlState.Selected)
        self.femaleBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.femaleBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
        
        // Hide keyboard when user scroll down.
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        
        // Register for keyboard notifications to resize scroll view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardWillHideNotification, object: nil)
        
        // Setup date picker for date of birth text field.
        let datePicker = UIDatePicker()
        datePicker.maximumDate = NSDate(timeIntervalSinceNow: (-10*12*30*24*60*60))
        datePicker.minimumDate = NSDate(timeIntervalSinceNow: (-130*12*30*24*60*60))
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.addTarget(self, action: Selector("dobPickerValueChanged"), forControlEvents: UIControlEvents.ValueChanged)
        self.dobTF.inputView = datePicker
        
        // Assign current client info to UI.
        self.assignCurrentUserInfoToUI()
        
        // Add save and cancel buttons.
        let saveBtn = UIButton()
        saveBtn.setTitle("Save", forState: UIControlState.Normal)
        saveBtn.addTarget(self, action: Selector("saveBtnClicked"), forControlEvents: UIControlEvents.TouchUpInside)
        saveBtn.sizeToFit()
        saveBtn.setFoogDefaultTitleGradientColor()
        saveBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
        self.saveBarItem = UIBarButtonItem(customView: saveBtn)
        
        self.cancelBarItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBtnClicked"))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
