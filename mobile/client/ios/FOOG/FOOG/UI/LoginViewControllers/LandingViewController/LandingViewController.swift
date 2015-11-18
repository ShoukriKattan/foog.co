//
//  LandingViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 7/25/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse


class LandingViewController: UIViewController {

    /** IBOutlet Components */
    @IBOutlet weak var backgroundImageView : UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //= PathViewController(NibName: "PathViewController", bundle: nil)
        
        /** Set Image. */
        var result = UIScreen.mainScreen().bounds.size;
        if (result.height > 500) {
            if (result.width <= 320) {
                self.backgroundImageView.image = UIImage(named:"landingPage_Retina4.png")
            }else if (result.width == 375) {
                self.backgroundImageView.image = UIImage(named: "landingPage_RetinaHD4.png")
            }else{
                self.backgroundImageView.image = UIImage(named: "landingPage_RetinaHD5")
            }
        }else{
            self.backgroundImageView.image = UIImage(named: "landingPage.png")
        }
    }
    
        
    /** View Will Appear. */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    /** View Did Appear. */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /** Get Login User. */
        let user = User.currentUser()
        if (user != nil) {
            /** Update login user Info. */
            User.currentUser()?.fetchInBackgroundWithBlock ({ (result, error : NSError?) -> Void in
                if(error == nil) {
                    var user = result as! User
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        LandingViewController.loginAuthenticatedUser(user, animated: false)
                    })
                }else{
                    User.logOut()
                    LandingViewController.showPathViewController()
                }
                
            })
        }else{
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                LandingViewController.showPathViewController()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /** Decide and present proper view for provided user according to his sign up process completeness. */
    class func loginAuthenticatedUser(user: User, animated: Bool) {
        
        let nextViewController = LandingViewController.properViewControllerForUser(user)
        
        if let viewController = nextViewController {
            let navigationController = UINavigationController(rootViewController: viewController)
            AppDelegate.getAppDelegate().window?.rootViewController = navigationController
        }
    }
    
    /** Get instance of proper view controller for provided user according to his sign up proces completeness. */
    class func properViewControllerForUser(user: User) -> UIViewController? {
        
        // Make sure that user sign up registration is complete.
        let firstName = user.firstName
        
        // If first name is not set, show Bio view controller.
        if (count(firstName) == 0) {
            let bioViewController = BioViewController(nibName: "BioViewController", bundle: nil)
            bioViewController.user = user
            return bioViewController
        } else if (user.isCoach && (user.phone == nil || count(user.phone!) == 0)) {
            // If coach has not enter his phone number, show phone verification view.
            let phoneVerificationViewController = PhoneVerificationViewController(nibName: "PhoneVerificationViewController", bundle: nil)
            return phoneVerificationViewController
        } else if (user.isCoach && !user.isPhoneVerified) {
            // If coach has not verified his phone number, show phone verification code view.
            let smsCodeVerificationViewController = SMSCodeVerificationViewController(nibName: "SMSCodeVerificationViewController", bundle: nil)
            return smsCodeVerificationViewController
        } else if (!user.isCoach) {
            
            // Find the latest CoachUserLink.
            var linkQuery = PFQuery(className: CoachUserLink.ParseKeys.ParseClassName)
            linkQuery.whereKey(CoachUserLink.ParseKeys.User, equalTo: user)
            linkQuery.orderByDescending("createdAt")
            linkQuery.getFirstObjectInBackgroundWithBlock({ (result : PFObject?, error :NSError?) -> Void in
                if error == nil {
                    /** The find succeeded. */
                    if let linkRequest = result as? CoachUserLink{
                        // If client is not sync with a coach, return sync view.
                        if (linkRequest.userCancelledAt != nil || linkRequest.userTerminatedAt != nil || linkRequest.userRejectedAt != nil) {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                LandingViewController.showSyncViewController()
                            })
                            
                        } else if (linkRequest.userLinkedAt == nil) {
                            // If client is waiting for coach to accept synch link.
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let syncPendingViewController = SyncPendingViewController(nibName: "SyncPendingViewController", bundle: nil)
                                syncPendingViewController.linkRequest = linkRequest
                                let syncPendingNavigationController = UINavigationController(rootViewController: syncPendingViewController)
                                AppDelegate.getAppDelegate().window?.rootViewController = syncPendingNavigationController
                            })
                        } else {
                            // TODO: If client is linked with a coach show User main flow view.
                            User.currentUser()?.fetchInBackgroundWithBlock ({ (result, error : NSError?) -> Void in
                                var user = result as! User
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    LandingViewController.showUserTabBarView(user)
                                })
                            })
                        }
                    }
                } else if (error?.code == 101) {
                    // If no results matched the query, then logged user did not send a link request yet.
                    // Show sync view.
                    let syncViewController = SyncViewController(nibName: "SyncViewController", bundle: nil)
                    let syncNavigationController = UINavigationController(rootViewController: syncViewController)
                    AppDelegate.getAppDelegate().window?.rootViewController = syncNavigationController
                } else {
                    /** Log details of the failure */
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            })
            
            return nil
        } else {
            User.currentUser()?.fetchInBackgroundWithBlock ({ (result, error : NSError?) -> Void in
                var user = result as! User
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    //Show Coach View
                    LandingViewController.showCoachView(false)
                })
            })
            
            return nil
        }
        
    }

    //Show Path View Controller
    class func showPathViewController() {
        let pathViewController = PathViewController(nibName: "PathViewController", bundle: nil)
        let pathNavigationViewController = UINavigationController(rootViewController: pathViewController)
        AppDelegate.getAppDelegate().window?.rootViewController = pathNavigationViewController
        AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
    }
    
    /** Show User Tab Bar View. */
    class func showUserTabBarView(loginUser : User) {
        
        if(User.isLoginUserCoach() == false){
            /** Pase to main view for authenticated user according to his type. */
            AppDelegate.getAppDelegate().registerPushNotification(UIApplication.sharedApplication())
            loginUser.isActive = true
        }
        
        AppDelegate.getAppDelegate().userTabBarController = UserTabBarController(user:loginUser)
        AppDelegate.getAppDelegate().userTabBarController!.view.frame = UIScreen.mainScreen().bounds
        AppDelegate.getAppDelegate().window?.rootViewController = AppDelegate.getAppDelegate().userTabBarController
        AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
    }
    
    /** Show Coach View. */
    class func showCoachView (withAnimation : Bool) {
        
        if withAnimation {
             AppDelegate.getAppDelegate().userTabBarController!.dismissViewControllerAnimated(true, completion: nil)
            
        }else{
            /** Pase to main view for authenticated user according to his type. */
            AppDelegate.getAppDelegate().registerPushNotification(UIApplication.sharedApplication())
             AppDelegate.getAppDelegate().coachViewController.resetValues()
            
             AppDelegate.getAppDelegate().userTabBarController = nil
             var coachNavigationViewController  =  UINavigationController(rootViewController:  AppDelegate.getAppDelegate().coachViewController)
             AppDelegate.getAppDelegate().window?.rootViewController = coachNavigationViewController
             AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
        }
    }
    
    /** show Sync View Controller. */
    class func showSyncViewController() {
        let syncViewController = SyncViewController(nibName: "SyncViewController", bundle: nil)
        let syncNavigationController = UINavigationController(rootViewController: syncViewController)
        AppDelegate.getAppDelegate().window?.rootViewController = syncNavigationController
        AppDelegate.getAppDelegate().window?.makeKeyAndVisible()
    }
}
