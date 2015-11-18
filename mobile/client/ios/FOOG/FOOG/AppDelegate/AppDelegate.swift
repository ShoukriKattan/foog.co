//
//  AppDelegate.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 7/24/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse
import Bolts
import ParseCrashReporting

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    var  coachViewController = CoachViewController(nibName: "CoachViewController", bundle: nil)
    
    var userTabBarController : UserTabBarController?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame:UIScreen.mainScreen().bounds)
        
        /** Register Classes For Parse becuase of Subclass. */
        User.registerSubclass()
        Meal.registerSubclass()
        ClientInfo.registerSubclass()
        CoachUserLink.registerSubclass()
        SummaryCard.registerSubclass()
        Notification.registerSubclass()
        
        /** Initialize Parse. */
        ParseCrashReporting.enable()
        Parse.enableLocalDatastore()
        Parse.setApplicationId("cfoOhbWtDiIWQ8bJL2DNmiji8MBOj0fpDa7mgYlD", clientKey: "xd8ZjG1P2laIJIg3QH8byPMoSdXMTyIUg4zrwkIt")
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        /** Set custom style of navigation controller. */
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "NavigationBarBg.png"), forBarPosition:UIBarPosition.Any , barMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        //Show Landing Page
        self.showLandingPage()
        
        return true
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    static func getAppDelegate() -> AppDelegate {
        let d = UIApplication.sharedApplication().delegate as! AppDelegate
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        // Store the deviceToken in the current installation and save it to Parse.
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.setObject(PFUser.currentUser()!, forKey: "user")
        currentInstallation.channels = ["global"];
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        /** Show Push Notification Alert. */
        PushNotificationHandler.sharedInstance().showPushNotoficationMessage(userInfo)
    }
    
    //Show Landing Page
    func showLandingPage(){
        // Show Landing View Controller.
        let landingViewController = LandingViewController(nibName: "LandingViewController", bundle: nil)
        self.window?.rootViewController = landingViewController
        self.window?.makeKeyAndVisible()
    }
    
    
    
    /** Register For Push Notifications. */
    func registerPushNotification(application: UIApplication){
        var userNotificationTypes = (UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound)
        if(UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:")){
            var settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }else{
            var settings = UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound
            application.registerForRemoteNotificationTypes(settings)
        }
    }
    
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

