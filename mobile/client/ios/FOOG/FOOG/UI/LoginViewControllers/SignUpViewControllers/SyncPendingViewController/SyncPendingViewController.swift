//
//  SyncPendingViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 7/3/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class SyncPendingViewController: UIViewController {
    
    /** Reference to Coach User Link Parse instance. */
    var linkRequest : CoachUserLink!
    
    /** IBOutlet to CoachID label UI field. */
    @IBOutlet weak var coachIdLbl: UILabel!
    
    /** Handle click event on Cancel Sync Request button. */
    @IBAction func cancelSyncBtnClicked(sender: AnyObject) {
        
        // Show moadl activity view.
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: true) { () -> Void in
            // Set link request as cancelled.
            self.linkRequest.userCancelledAt = NSDate()
            self.linkRequest.saveInBackgroundWithBlock { (success : Bool, error : NSError?) -> Void in
                
                // Hide modal activity view.
                self.dismissViewControllerAnimated(true, completion: nil)
                
                if (success) {
                    // Show sync view controller.
                    let syncViewController = SyncViewController(nibName: "SyncViewController", bundle: nil)
                    let syncNavigationViewController = UINavigationController(rootViewController: syncViewController)
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.window?.rootViewController = syncNavigationViewController
                    
                    
//                    UIView.transitionFromView(self.view, toView: syncNavigationViewController.view, duration: 0.7, options: UIViewAnimationOptions.TransitionCrossDissolve, completion: { (success : Bool) -> Void in
//                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                        appDelegate.window?.rootViewController = syncNavigationViewController
//                    })
                } else {
                    // TODO: Handle errors.
                    
                }
                
            }
        }
        
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure to hide navigation bar.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        // Set FOOG default gradient background.
        self.view.addDefaultGradientBackground()
        
        // Set gradient color for CoachID label.
        self.coachIdLbl.setFoogDefaultTitleGradientColor()
        
        // Set CoachID to the UI.
        self.linkRequest.coach!.fetch()
        let coachId = self.linkRequest.coach!.id
        self.coachIdLbl.text = coachId
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
