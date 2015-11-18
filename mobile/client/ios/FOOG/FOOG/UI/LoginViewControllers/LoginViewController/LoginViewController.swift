//
//  LoginViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/1/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    /** IBOutlet to view used to show Foog logo. */
    @IBOutlet weak var foogLogoView: UIView!
    
    /** IBOutlet to view used to show foog logo with coach addition. */
    @IBOutlet weak var foogLogoCoachView: UIView!
    
    /** IBOutlet to email input text field. */
    @IBOutlet weak var emailTF: UITextField!
    
    /** IBOutlet to password input text field. */
    @IBOutlet weak var passwordTF: UITextField!
    
    /** IBOutlet to main scroll view. */
    @IBOutlet weak var scrollView: UIScrollView!
    
    /** IBOutlet to constraint of space between scroll view and main view bottom. */
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    /** Boolean value which indicates if user supposed to be a coach or not. */
    var isCoachMode = false
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set FOOG default background.
        self.view.addDefaultGradientBackground()
        
        // Set back navigation custom button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back_Button.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonClicked")
        
        // Set sign up navigation custom button.
        let signUpBtn = UIButton()
        signUpBtn.setTitle("Sign Up", forState: UIControlState.Normal)
        signUpBtn.addTarget(self, action: Selector("signUpBtnClicked"), forControlEvents: UIControlEvents.TouchUpInside)
        signUpBtn.sizeToFit()
        signUpBtn.setFoogDefaultTitleGradientColor()
        signUpBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
        let signUpBarItem = UIBarButtonItem(customView: signUpBtn)
        self.navigationItem.rightBarButtonItem = signUpBarItem
        
        // Hide keyboard on scroll down.
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        
        // Register to keyboard notifications.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardWillHideNotification, object: nil)
        
        // Hide / Show proper fields to match coach or user mode.
        if (self.isCoachMode) {
            self.foogLogoView.hidden = true
            self.foogLogoCoachView.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure that navigation bar is visible.
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        // Make sure that keyboard is hidden and scroll view is not scrolled.
        self.view.endEditing(true)
        self.keyboardWillHide()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /** Pop this view when back button is pressed to go back to Bath view. */
    func backButtonClicked() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /** Show sign up view controller when sign up button is clicked. */
    func signUpBtnClicked() {
        // Show sign up view controller.
        let signUpViewController = SignUpViewController(nibName: "SignUpViewController", bundle: nil)
        signUpViewController.isCoachMode = self.isCoachMode
        self.navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    /** Handler for click event on Sign In UI button. */
    @IBAction func signInBtnClicked(sender: AnyObject) {
        // Make sure that user enter his credentials.
        let email = self.emailTF.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        let password = self.passwordTF.text
        
        if (count(email) == 0) {
            FoogAlert.show(FoogMessages.MissingEmail, context: self)
            return
        }
        
        if(count(password) == 0) {
            FoogAlert.show(FoogMessages.MissingPassword, context: self)
            return
        }
        
        // Check if email is valid email.
        if (!FoogStringUtilities.isValidEmail(email)) {
            FoogAlert.show(FoogMessages.WrongEmail, context: self)
            return
        }
        
        // Show modal activity indicator.
        self.view.endEditing(true)
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: true) { () -> Void in
            
            // Try login provided user credentials.
            PFUser.logInWithUsernameInBackground(email, password: password) { (user: PFUser?, error: NSError?) -> Void in
                if (error != nil) {
                    // Dismiss modal activity view.
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        
                        FoogAlert.show(FoogMessages.CouldNotSignIn, context: self)
                        
                    })
                } else {
                    // Hide modal activity view.
                    self.dismissViewControllerAnimated(false, completion: { () -> Void in
                        
                        LandingViewController.loginAuthenticatedUser(user as! User, animated: true)
                        // Clear password input field.
                        self.passwordTF.text = nil
                    })
                    
                }
            }
            
        }
        
    }
    
    /** Resize scroll view to keep all fields visible when keyboard show up. */
    func keyboardWillShow(notification: NSNotification) {
        // Hold keyboard height.
        let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardFrame.CGRectValue().height
        
        if (self.scrollViewBottomSpaceConstraint.constant < keyboardHeight) {
            self.scrollViewBottomSpaceConstraint.constant = keyboardHeight
            
            // Scroll to scroll view's bottom.
            let yOffset = self.scrollView.contentSize.height - (self.scrollView.frame.size.height - keyboardHeight)
            if yOffset > 0 {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
            }
        }
    }
    
    /** Resize scroll view to fill the whole view when keyboard hides. */
    func keyboardWillHide() {
        self.scrollViewBottomSpaceConstraint.constant = 0
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    // MARK: - UITextFieldDelegate
    
    /** Move focus between input text fields when keyboard enter button is pressed. */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.emailTF) {
            self.passwordTF.becomeFirstResponder()
        } else if (textField == self.passwordTF) {
            self.signInBtnClicked(self)
        }
        return true
    }
    



}
