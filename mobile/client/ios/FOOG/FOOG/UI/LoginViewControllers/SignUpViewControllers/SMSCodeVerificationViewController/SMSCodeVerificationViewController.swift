//
//  SMSCodeVerificationViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class SMSCodeVerificationViewController: UIViewController, UITextFieldDelegate {
    
    /** IBoutlet to first digit of SMS verification code UI input text field. */
    @IBOutlet weak var firstDigitTF: UITextField!
    
    /** IBoutlet to second digit of SMS verification code UI input text field. */
    @IBOutlet weak var secondDigitTF: UITextField!
    
    /** IBoutlet to third digit of SMS verification code UI input text field. */
    @IBOutlet weak var thirdDigitTF: UITextField!
    
    /** IBoutlet to fourth digit of SMS verification code UI input text field. */
    @IBOutlet weak var fourthDigitTF: UITextField!
    
    /** IBOutlet to code UI input text field which acutally receive user's input. */
    @IBOutlet weak var codeTF: UITextField!
    
    /** 
        Handler for click event on Verify UI button.
        This should check if entered SMS verification code is valid or not.
    */
    @IBAction func verifyBtnClicked(sender: AnyObject) {
        
        // Make sure not to show keyboard again.
        self.view.endEditing(true)
        
        // Display modal activity indicator.
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: true, completion: nil)
        
        // Verify user's enetered verification code with (validateVerificationCode) Cloud function.
        let userCode = self.codeTF.text
        
        // Send user's verification code to the backend to validate it.
        var verificationParameters : [NSObject : AnyObject] = [:]
        verificationParameters["duser"] = User.currentUser()?.objectId
        verificationParameters["digits"] = userCode
        
        PFCloud.callFunctionInBackground(FoogCloudCode.ValidateVerificationCodeFunctionName, withParameters: verificationParameters) { (result : AnyObject?, error : NSError?) -> Void in
            
            if (error != nil) {
                
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    FoogAlert.show(FoogMessages.WrongVerficationCode, context: self)
                })
                
            } else {
                
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    // Pass to Coach Intro Screen.
                    let introViewController = CoachIntroViewController(nibName: "CoachIntroViewController", bundle: nil)
                    let introNavigationController = UINavigationController(rootViewController: introViewController)
                    introNavigationController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window?.rootViewController = introNavigationController
                })
            }
            
        }
        
    }
    
    /** Handler for click event on Resend Code UI button. */
    @IBAction func resendBtnClicked(sender: AnyObject) {
        // Show user verification phone number view controller.
        let phoneVerificationViewController = PhoneVerificationViewController(nibName: "PhoneVerificationViewController", bundle: nil)
        self.navigationController?.pushViewController(phoneVerificationViewController, animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    /** Pass input cursor over four digits text fields when user type or delete digits. */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        // Hold current code.
        var currentCode = self.codeTF.text
        
        // Do nothing if current code consist of 4 digits and user input is not backspace.
        if (count(currentCode) == 4 && count(string) > 0) {
            return false
        }
        
        // Remove last digit if user input is backspace.
        if (count(string) == 0) {
            currentCode = currentCode.substringToIndex(advance(currentCode.endIndex, -1))
        }
        
        // Add user input to current code.
        currentCode = currentCode + string
        
        // Display current code.
        let digits = Array(currentCode)
        self.firstDigitTF.text = digits.count > 0 ? String(digits[0]) : "-"
        self.secondDigitTF.text = digits.count > 1 ? String(digits[1]) : "-"
        self.thirdDigitTF.text = digits.count > 2 ? String(digits[2]) : "-"
        self.fourthDigitTF.text = digits.count > 3 ? String(digits[3]) : "-"
        
        return true
        
    }
    
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set default gradient background.
        self.view.addDefaultGradientBackground()
        
        // Set view's title.
        self.title = "Verification"
        
        // Hide back button at navigation bar.
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Move focus to code input text field.
        self.codeTF.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
