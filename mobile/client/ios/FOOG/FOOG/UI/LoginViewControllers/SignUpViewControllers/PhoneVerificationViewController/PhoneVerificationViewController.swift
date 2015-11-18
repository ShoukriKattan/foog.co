//
//  PhoneVerificationViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/2/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class PhoneVerificationViewController: UIViewController, UITextFieldDelegate {

    /** IBoutlet to phone number UI input text field. */
    @IBOutlet weak var phoneTF: UITextField!
    
    /** Handler for click event on send button. */
    @IBAction func sendCodeBtnClicked(sender: AnyObject) {
        // Validat user input.
        let phoneNumber = self.phoneTF.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (count(phoneNumber) == 0) {
            FoogAlert.show(FoogMessages.MissingPhoneNumber, context: self)
            return
        }
        
        // Display modal activity indicator.
        self.view.endEditing(true)
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: true, completion: nil)
        
        // Send user's phone number to the backend to get verification code by SMS.
        var verificationParameters : [NSObject : AnyObject] = [:]
        verificationParameters["duser"] = User.currentUser()?.objectId
        verificationParameters["number"] = phoneNumber
        
        PFCloud.callFunctionInBackground(FoogCloudCode.ConfirmPhoneNumberFunctionName, withParameters: verificationParameters) { (result : AnyObject?, error : NSError?) -> Void in
            
            // Hide modal activity view.
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                println("result: \(result), error: \(error)")
                
                if let e = error {
                    
                    FoogAlert.show(FoogMessages.ErrorSMSCodeNotSent, context: self)
                    
                } else {
                    // Proceed to SMS code verification view.
                    let smsCodeVerificationViewController = SMSCodeVerificationViewController(nibName: "SMSCodeVerificationViewController", bundle: nil)
                    self.navigationController?.pushViewController(smsCodeVerificationViewController, animated: true)
                }
                
            })
            
        }
        
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.phoneTF) {
            self.sendCodeBtnClicked(self)
        }
        return true
    }
    
    /** Make sure that input is only digits. */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var digitsOnlyString = ((string as NSString).componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) as NSArray).componentsJoinedByString("")
        
        if digitsOnlyString == string {
            return true
        }
        
        return false
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set FOOG default gradient background.
        self.view.addDefaultGradientBackground()
        
        // Set view's title.
        self.navigationItem.title = "My Mobile Number"
        
        // Hides back button.
        self.navigationItem.setHidesBackButton(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
