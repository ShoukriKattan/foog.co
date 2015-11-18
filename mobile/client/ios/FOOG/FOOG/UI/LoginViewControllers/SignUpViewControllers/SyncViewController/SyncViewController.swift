//
//  SyncViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/3/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class SyncViewController: UIViewController, UITextFieldDelegate {
    
    /** IBOutlet to Coach ID input text UI field. */
    @IBOutlet weak var coachIdTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set FOOG default gradient background.
        self.view.addDefaultGradientBackground()
        
        /** Add Foog  Icon to Navigation Bar. */
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Foog_Icon.png"))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** Handler for click event on Send Request UI field. */
    @IBAction func sendBtnClicked(sender: AnyObject) {
        
        // Make sure that user entered coach id.
        let coachId = self.coachIdTF.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        if (count(coachId) == 0) {
            FoogAlert.show(FoogMessages.MissingCoachID, context: self)
            return
        }
        
        // Make sure that keyboard will not show up.
        self.view.endEditing(true)
        
        // Display modal activity indicator.
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: true, completion: nil)
        
        // Send sync request to specified coach.
        var coachLink = CoachUserLink(className: CoachUserLink.ParseKeys.ParseClassName)
        coachLink.user = User.currentUser()
        coachLink.setObject(coachId, forKey: CoachUserLink.ParseKeys.CoachId)
        coachLink.saveInBackgroundWithBlock { (success : Bool, error : NSError?) -> Void in
            // Hide modal activity view.
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                if (error != nil) {
                    // TODO: Handle different error link CoachID not found.
                    let errorInfo = error?.userInfo!["error"] as! String
                    var errorMessage = errorInfo == "CoachNotFound" ? FoogMessages.ErrorCoachNotFound : FoogMessages.ErrorSyncRequestNotSent
                    FoogAlert.show(errorMessage, context: self)
                } else {
                    
                    /** Register User Device token. */
                    AppDelegate.getAppDelegate().registerPushNotification(UIApplication.sharedApplication())
                    
                    // Proceed to waint sync accept view.
                    let syncPendingViewController = SyncPendingViewController(nibName: "SyncPendingViewController", bundle: nil)
                    syncPendingViewController.linkRequest = coachLink
                    self.navigationController?.pushViewController(syncPendingViewController, animated: true)
                }
            })
        }
        
    }
    
    /** Handle return button for input text fields. */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Send sync request when return button is click for coach id input field. */
        if (textField == self.coachIdTF) {
            self.sendBtnClicked(self)
        }
        
        return true
    }

}
