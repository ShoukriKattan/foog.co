//
//  CoachSettingsViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class CoachSettingsViewController: UIViewController, UITextFieldDelegate {
    
    
    /** IBOutlet to text UI field for displaying Coach ID. */
    @IBOutlet weak var coachIdTF: UITextField!
    
    /** IBOutlet to text input UI field for first name. */
    @IBOutlet weak var firstNameTF: UITextField!
    
    /** IBOutlet to text input UI field for last name. */
    @IBOutlet weak var lastNameTF: UITextField!
    
    /** IBOutlet to text input UI field for GYM name. */
    @IBOutlet weak var nameOfGymTF: UITextField!
    
    /** IBOutlet to male UI button. */
    @IBOutlet weak var maleBtn: UIButton!
    
    /** IBOutlet to female UI button. */
    @IBOutlet weak var femaleBtn: UIButton!
    
    /** IBOutlet to scroll view UI field which contains other input text fields. */
    @IBOutlet weak var scrollView: UIScrollView!
    
    /** IBOutlet to height contraint of scroll view. */
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    /** IBOutlet to log out UI button. */
    @IBOutlet weak var logOutBtn: UIButton!
    
    /** Handler for click event on male button which must be marked as selected. */
    @IBAction func maleButtonPressed(sender: AnyObject) {
        self.maleBtn.selected = true
        self.femaleBtn.selected = false
    }
    
    /** Handler for click event on female button which must be marked as selected. */
    @IBAction func femaleButtonPressed(sender: AnyObject) {
        self.maleBtn.selected = false
        self.femaleBtn.selected = true
    }
    
    /** Handler for click event on log out button UI field. */
    @IBAction func logOutBtnClicked(sender: AnyObject) {
        // Log out user and go back to Path view.
        User.logOut()
        LandingViewController.showPathViewController()
    }
    
    /** Handler for click event on back button at navigation bar. */
    func backButtonClicked() {
        
        // Make sure keyboard will not show up again.
        self.view.endEditing(true)
        
        // Simply go back to previous view.
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    /** 
        Handler for click event on save button at navigation bar to save all
        changes to Parse and go back to previous view. 
    */
    func saveBtnClicked() {
        // Make sure keyboard will not show up again.
        self.view.endEditing(true)
        
        // Display modal activity indicator.
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: true, completion: nil)
        
        // Save changes to Parse.
        var coach = User.currentUser()
        coach?.firstName = self.firstNameTF.text
        coach?.lastName = self.lastNameTF.text
        coach?.gymName = self.nameOfGymTF.text
        coach?.sex = self.maleBtn.selected ? SexType.Male : SexType.Female
        
        coach?.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
            
            // Hide modal activity view.
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                if (error != nil) {
                    
                    FoogAlert.show(FoogMessages.ErrorCouldNotReachInternet, context: self)
                    
                } else {
                    
                    // Simply go back to previous view.
                    self.navigationController?.popViewControllerAnimated(true)
                    
                }
                
            })
            
        })
    }
    
    /** Resize scroll view to keep all fields visible when keyboard show up. */
    func keyboardDidShow() {
        self.scrollViewHeightConstraint.constant = self.view.bounds.height - 200
        // Make sure all input fields are visible.
        var scrollPosition = self.scrollView.contentSize.height - self.scrollViewHeightConstraint.constant
        if (scrollPosition > 0) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollPosition), animated: true)
        }
    }
    
    /** Resize scroll view to fill the whole view when keyboard hides. */
    func keyboardDidHide() {
        self.view.layoutIfNeeded()
        self.scrollViewHeightConstraint.constant = self.view.bounds.height
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - UITextFieldDelegate
    
    /** Handler for return button for different text fields. */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // Move focus over different text fields.
        if (textField == self.firstNameTF) {
            self.lastNameTF.becomeFirstResponder()
        } else if (textField == self.lastNameTF) {
            self.nameOfGymTF.becomeFirstResponder()
        } else if (textField == self.nameOfGymTF) {
            self.view.endEditing(true)
        }
        
        return true
        
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set default gradient background.
        self.view.addDefaultGradientBackground()
        
        // Set app logo at navigation bar.
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Foog_Icon.png"))
        
        // Set back navigation custom button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back_Button.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonClicked")
        
        // Add save and cancel buttons.
        let saveBtn = UIButton()
        saveBtn.setTitle("Save", forState: UIControlState.Normal)
        saveBtn.addTarget(self, action: Selector("saveBtnClicked"), forControlEvents: UIControlEvents.TouchUpInside)
        saveBtn.sizeToFit()
        saveBtn.setFoogDefaultTitleGradientColor()
        saveBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
        let saveBarItem = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.rightBarButtonItem = saveBarItem
        
        // Set proper selected / unselected backgrounds for male and female buttons.
        self.maleBtn.setBackgroundImage(UIImage(named: "SegmentLeftUnselected.png"), forState: UIControlState.Normal)
        self.maleBtn.setBackgroundImage(UIImage(named: "SegmentLeftSelected.png"), forState: UIControlState.Selected)
        self.maleBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
        self.femaleBtn.setBackgroundImage(UIImage(named: "SegmentRightUnselected.png"), forState: UIControlState.Normal)
        self.femaleBtn.setBackgroundImage(UIImage(named: "SegmentRightSelected.png"), forState: UIControlState.Selected)
        self.femaleBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
        
        // Set gradient title for log out button.
        self.logOutBtn.setFoogDefaultTitleGradientColor()
        
        // Register for keyboard notifications to resize scroll view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidHide"), name: UIKeyboardDidHideNotification, object: nil)
        
        // Hide keyboard when user scroll down.
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        
        // Assign current coach user info to UI fields.
        let coach = User.currentUser()
        self.coachIdTF.text = coach?.id
        self.firstNameTF.text = coach?.firstName
        self.lastNameTF.text = coach?.lastName
        self.nameOfGymTF.text = coach?.gymName
        
        if (coach?.sex == SexType.Male) {
            self.maleButtonPressed(self)
        } else {
            self.femaleButtonPressed(self)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
