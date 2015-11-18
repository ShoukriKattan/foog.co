//
//  SignUpViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/25/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    /** IBOutlet to email input text UI field. */
    @IBOutlet weak var emailTF: UITextField!
    
    /** IBOutlet to password input UI field. */
    @IBOutlet weak var passwordTF: UITextField!
    
    /** IBOutlet to password confirmation input UI field. */
    @IBOutlet weak var passwordConfirmTF: UITextField!
    
    /** IBOutlet to a view which contains all coach special UI fields. */
    @IBOutlet weak var coachSpecialView: UIView!
    
    /** IBOutlet to coach username input text UI field. */
    @IBOutlet weak var coachUsernameTF: UITextField!
    
    /** Boolean value indicates whether it is Coach mode or user mode. */
    var isCoachMode = true
    
    /** 
        Handler for navigation bar back button.
        Simple pop this view from navigation stack.
    */
    func backButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /** 
        Handler for navigation bar next button.
        Validate user input and proceed to Bio view.
    */
    func nextButtonPressed() {
        // Hold user input.
        let email = self.emailTF.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        let password = self.passwordTF.text
        let passwordConfirm = self.passwordConfirmTF.text
        let coachId = self.coachUsernameTF.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        
        // Validate user input.
        if (count(email) == 0) {
            FoogAlert.show(FoogMessages.MissingEmail, context: self)
            return
        }
        
        if (!FoogStringUtilities.isValidEmail(email)) {
            FoogAlert.show(FoogMessages.WrongEmail, context: self)
            return
        }
        
        if (count(password) == 0) {
            FoogAlert.show(FoogMessages.MissingPassword, context: self)
            return
        }
        
        if (!self.isCoachMode && count(passwordConfirm) == 0) {
            FoogAlert.show(FoogMessages.MissingPasswordConfirmation, context: self)
            return
        }
        
        if (!self.isCoachMode && password != passwordConfirm) {
            FoogAlert.show(FoogMessages.PasswordsDoNotMatch, context: self)
            return
        }
        
        if (self.isCoachMode && count(coachId) == 0) {
            FoogAlert.show(FoogMessages.MissingUsername, context: self)
            return
        }
        
        // Make sure to hide heyboard.
        self.view.endEditing(true)
        
        
        // Display modal activity indicator.
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: true) { () -> Void in
            
            // Register new user at Parse.
            var user = User()
            user.email = email
            user.username = email
            user.password = password
            user.isCoach = self.isCoachMode
            user.timezone = NSTimeZone.systemTimeZone().name
            
            if (self.isCoachMode) {
                user.id = coachId
            }
            user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                
                // TODO: Handle errors such as coachID already taken.
                if (error != nil) {
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        if (error?.code == 202) {
                            FoogAlert.show(FoogMessages.EmailIsTaken, context: self)
                        } else {
                            let errorInfo = error!.userInfo!["error"] as! String
                            var errorMessage = errorInfo == "CoachIdIsTaken" ? FoogMessages.CoachIdIsTaken : FoogMessages.CouldNotSignUp
                            FoogAlert.show(errorMessage, context: self)
                        }
                    })
                    
                } else {
                    // Hide modal activity indicator.
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        // Proceed to Bio view.
                        let bioViewController = BioViewController(nibName: "BioViewController", bundle: nil)
                        bioViewController.user = user
                        let bioNavigationController = UINavigationController(rootViewController: bioViewController)
                        self.presentViewController(bioNavigationController, animated: true, completion: nil)
                    })
                }
                
            }
        }
    }
    
    /** Move focus between input fields when user hit enter keyboard button. */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.emailTF) {
            self.passwordTF.becomeFirstResponder()
        } else if (!self.isCoachMode && textField == self.passwordTF) {
            self.passwordConfirmTF.becomeFirstResponder()
        } else if (textField == self.passwordTF) {
            self.coachUsernameTF.becomeFirstResponder()
        } else if (textField == self.passwordConfirmTF || textField == self.coachUsernameTF) {
            self.nextButtonPressed()
        } 
        
        return true
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set FOOG default gradient background.
        self.view.addDefaultGradientBackground()
        
        // Set view's title and navigation bar button items.
        self.title = "Sign Up"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back_Button.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonPressed")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "NextButton.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: "nextButtonPressed")

        // Hide / Show proper UI fields to match Coach / User mode.
        // Default is user mode.
        if (self.isCoachMode) {
            // For hide mode, hide password confirm text field and show coach special view.
            self.passwordConfirmTF.hidden = true
            self.coachSpecialView.hidden = false
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
