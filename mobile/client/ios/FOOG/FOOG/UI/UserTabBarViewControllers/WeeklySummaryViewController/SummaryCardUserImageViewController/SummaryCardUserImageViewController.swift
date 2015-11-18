//
//  SummaryCardUserImageViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/12/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit
import ParseUI

class SummaryCardUserImageViewController: UIViewController {

    /** IBOutlet to User image Summary Card . */
    @IBOutlet weak var userImage: PFImageView!
    
    /** Main activity indicator in view's center UI field. */
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    /** Selected Summary Card.  */
    var selectedSummaryCard : SummaryCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Add Back Button Bar Item. */
        var backBarItem = UIBarButtonItem(image: UIImage(named: "Back_Button.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonPressed")
        self.navigationItem.leftBarButtonItem = backBarItem
        
        //Reset Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarPosition:UIBarPosition.Any , barMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
                
        /** Load User Image photo. */
        self.userImage.image = nil
        self.userImage.file = self.selectedSummaryCard?.imageOriginal
        self.userImage.loadInBackground { (image, error : NSError?) -> Void in
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.hidden = true
        }
        
        /** Hide Tab Bar. */
        AppDelegate.getAppDelegate().userTabBarController?.tabBar.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /** User did Press Back Button. */
    func backButtonPressed() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
