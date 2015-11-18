//
//  FHCloudCode.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

/**
    FHCloudCode holds all static info related to application Cloude Code at Parse.
*/
struct FoogCloudCode {
    
    /** Name of cloud function used to confirm phone number by sending SMS verification code. */
    static let ConfirmPhoneNumberFunctionName = "confirmPhoneNumber"
    
    /** Name of cloud function to validate code received by SMS. */
    static let ValidateVerificationCodeFunctionName = "validateVerificationCode"
    
    /** Name of cloud function to get User Notification Counts. */
    static let getUserNotificationCounts = "getUserNotificationCounts"
    
    /** Name of cloud function to update User Notification that Comment was read. */
    static let markCommentRead = "markCommentRead"
    
    
}
