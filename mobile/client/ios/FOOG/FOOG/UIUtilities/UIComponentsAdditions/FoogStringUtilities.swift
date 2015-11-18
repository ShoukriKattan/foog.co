//
//  FoogStringUtilities.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/25/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

/** 
    FHStringUtilities provide useful procedure for manipulating strings.
*/
class FoogStringUtilities {
    
    /** Check provided email if it matches email address regular expression or not. */
    static func isValidEmail(email : String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
        
    }
    
}
