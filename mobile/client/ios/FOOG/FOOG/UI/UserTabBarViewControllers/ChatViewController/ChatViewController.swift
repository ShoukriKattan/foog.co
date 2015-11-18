//
//  ChatViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    // MARK: ChatViewController
    
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set view's title.
        self.navigationItem.title = "Chat"
        
        /** Add Back to Coach View in case the login user is coach. */
        if (User.isLoginUserCoach() == true) {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Back_To _Coach_View.png"), style: UIBarButtonItemStyle.Plain, target:AppDelegate.getAppDelegate(), action: Selector("showCoachView:"))
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    
    // Set Status Bar  Style
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //Show Status bar 
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
