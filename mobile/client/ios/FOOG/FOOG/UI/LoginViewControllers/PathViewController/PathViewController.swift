//
//  PathViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/1/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class PathViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar.
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** IBAction for click event on "I am a Client" button. */
    @IBAction func clientBtnClicked(sender: AnyObject) {
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    /** IBAction for click event on "I am a Coach" button. */
    @IBAction func coachBtnClicked(sender: AnyObject) {
        let loginViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        loginViewController.isCoachMode = true
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    

    

}
