//
//  FHCoachUserLink.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

import Parse

class CoachUserLink: PFObject , PFSubclassing {
    
    /** Keys for Coach User Link Parse class. */
    struct ParseKeys {
        
        static let ParseClassName = "CoachUserLink"
        
        static let User = "user"
        
        static let LinkedAt = "linkedAt"
        
        static let Coach = "coach"
        
        static let CoachId = "coachId"
        
        static let RejectedAt = "rejectedAt"
        
        static let TerminatedAt = "terminatedAt"
        
        static let TerminatedBy = "terminatedBy"
        
        static let CancelledAt = "cancelledAt"
        
        static let CreatedAt = "createdAt"
        
    }
    
    /** Display Name for Parse. */
    var displayName: String? {
        get {
            return self["displayName"] as? String
        }
        set {
            self["displayName"] = newValue
        }
    }
    
    
    /** Parse Class Name. */
    class func parseClassName() -> String {
        return "CoachUserLink"
    }
    
    
    /** Coach. */
    var coach : User? {
        get {
            if let tempCoach = self.objectForKey(CoachUserLink.ParseKeys.Coach) as? User {
                return tempCoach
            }else{
                return nil
            }
        }set(newCoach) {
            self.setObject(PFUser(withoutDataWithClassName: "User", objectId: newCoach!.objectId), forKey: CoachUserLink.ParseKeys.Coach)
        }
    }
    
    /** User. */
    var user : User? {
        get {
            if let tempUser = self.objectForKey(CoachUserLink.ParseKeys.User) as? User {
                return tempUser
            }else{
                return nil
            }
        }set(newUser) {
            self.setObject(newUser!, forKey: CoachUserLink.ParseKeys.User)
        }
    }
    
    /** User Terminated At. */
    var userTerminatedAt :  NSDate? {
        get {
            if let tempUserTerminatedAtDate = self.objectForKey(CoachUserLink.ParseKeys.TerminatedAt) as? NSDate {
                return tempUserTerminatedAtDate
            }else{
                return nil
            }
        }set(newUserTerminatedAtDate) {
            if let updatedDate = newUserTerminatedAtDate {
                self.setObject(updatedDate, forKey: CoachUserLink.ParseKeys.TerminatedAt)
            }else{
                self.removeObjectForKey(CoachUserLink.ParseKeys.TerminatedAt)
            }
        }
    }
    
    /** Reference to User instance who terminated this Coach User link wither a Coach or a Client. */
    var terminatedBy : User? {
        get {
            return self[CoachUserLink.ParseKeys.TerminatedBy] as! User?
        }
        set (v) {
            self[CoachUserLink.ParseKeys.TerminatedBy] = v
        }
    }
    
    /** User Linked At. */
    var userLinkedAt :  NSDate? {
        get {
            if let tempUserLinkedAtDate = self.objectForKey(CoachUserLink.ParseKeys.LinkedAt) as? NSDate {
                return tempUserLinkedAtDate
            }else{
                return nil
            }
        }set(newUserLinkedAtDate) {
            if let updatedDate = newUserLinkedAtDate {
                self.setObject(updatedDate, forKey: CoachUserLink.ParseKeys.LinkedAt)
            }else{
                self.removeObjectForKey(CoachUserLink.ParseKeys.LinkedAt)
            }
        }
    }
    
    /** User Rejected At. */
    var userRejectedAt :  NSDate? {
        get {
            if let tempUserRejectedAtDate = self.objectForKey(CoachUserLink.ParseKeys.RejectedAt) as? NSDate {
                return tempUserRejectedAtDate
            }else{
                return nil
            }
        }set(newUserRejectedAtDate) {
            if let updatedDate = newUserRejectedAtDate {
                self.setObject(updatedDate, forKey: CoachUserLink.ParseKeys.RejectedAt)
            }else{
                self.removeObjectForKey(CoachUserLink.ParseKeys.RejectedAt)
            }
        }
    }
    
    /** link Created At. */
    var userLinkCreatedAt :  NSDate? {
        get {
            if let tempUserLinkCreatedAtDate = self.createdAt {
                return tempUserLinkCreatedAtDate
            }else{
                return nil
            }
        }
    }
    
    /** User Cancelled At. */
    var userCancelledAt :  NSDate? {
        get {
            if let tempUserCancelledAtDate = self.objectForKey(CoachUserLink.ParseKeys.CancelledAt) as? NSDate {
                return tempUserCancelledAtDate
            }else{
                return nil
            }
        }set(newUserCancelledAtDate) {
            if let updatedDate = newUserCancelledAtDate {
                self.setObject(updatedDate, forKey: CoachUserLink.ParseKeys.CancelledAt)
            }else{
                self.removeObjectForKey(CoachUserLink.ParseKeys.CancelledAt)
            }
        }
    }
    
}
