//
//  FoogAlert.swift
//  FOOG
//
//  Created by Zafer Shaheen on 7/16/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

/** Special Alert for simple alerts messages with only OK button which decide to use UIAlertController or UIAlertView at runtime. */
class FoogAlert {
    
    /** Creates and show simple alert with only OK button for provided title and message. */
    class func show(alertTitle : String, alertMessage : String, context : UIViewController) {
        
        if objc_getClass("UIAlertController") != nil {
            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            context.presentViewController(alertController, animated: true, completion: nil)
        } else {
            let alertView = UIAlertView(title: alertTitle, message: alertMessage, delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
        
    }
    
    /** Creates and show simple alert with only OK button for provided message. */
    class func show(alertMessage : FoogMessage, context : UIViewController) {
        FoogAlert.show(alertMessage.title, alertMessage: alertMessage.message, context: context)
    }
    
}