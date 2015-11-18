//
//  Meal.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/7/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

import Parse


/** Meal entity. */
class Meal : PFObject , PFSubclassing {
    

    
    /** This structure contains all constants related to Meal. */
    struct Configration {
        
        /** Size of StreamItem full size image. */
        static let imageFullSize = CGSizeMake(1242, 2208)
        
        /** Size of StreamItem thumbnail. */
        static let imageThumbnailSize = CGSizeMake(750, 400)
        
    }
    
    /** Parse Meal Keys. */
    struct ParseKeys {
        static let Coach = "coach"
        static let CoachComments = "coachComments"
        static let CoachCommentedAt = "coachCommentedAt"
        static let CoachReviewedAt = "coachReviewedAt"
        static let ImageOriginal = "imageOriginal"
        static let ImageThumbnail = "imageThumb"
        static let ItemType = "itemType"
        static let Locked = "locked"
        static let User = "user"
        static let UserComments = "userComments"
        static let UserCommentedAt = "userCommentedAt"
        static let UserReviewedAt = "userReviewedAt"
        static let CreatedAt = "createdAt"
        static let ItemMrakers = "itemMarkers"
        static let ObjectID = "objectId"
        static let Pinned = "pinned"
        static let AppCreatedAt = "appCreatedAt"
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
        return "Meal"
    }
    
    
    /** Coach. */
    var coach : User? {
        get {
            if let tempCoach = self.objectForKey(Meal.ParseKeys.Coach) as? User {
                return tempCoach
            }else{
                return nil
            }
        }set(newCoach) {
            self.setObject(PFUser(withoutDataWithObjectId: newCoach!.objectId), forKey: Meal.ParseKeys.Coach)
        }
    }
    
    /** Coach Comments. */
    var coachComments : String {
        get{
            if let tempCoachComments = self.objectForKey(ParseKeys.CoachComments) as? String {
                return tempCoachComments
            }else{
                return ""
            }
        }set(newComment){
            if var tempNewCoachComments = newComment as String? {
                self.setObject(tempNewCoachComments, forKey: ParseKeys.CoachComments)
            }else{
                self.setObject("", forKey: ParseKeys.CoachComments)
            }
        }
    }
    
    /** Coach Commented At. */
    var coachCommentedAt :  NSDate {
        get {
            if let tempCoachCommentedAt = self.objectForKey(ParseKeys.CoachCommentedAt) as? NSDate {
                return tempCoachCommentedAt
            }else{
                return NSDate.new()
            }
        }set(newCommentDate) {
            self.setObject(newCommentDate, forKey: ParseKeys.CoachCommentedAt)
        }
    }
    
    /** Coach Reviewed At. */
    var coachReviewedAt : NSDate? {
        get {
            if let tempCoachReviewedAt = self.objectForKey(ParseKeys.CoachReviewedAt) as? NSDate {
                return tempCoachReviewedAt
            }else{
                return nil
            }
        }set(newCoachReviewedAt) {
            self.setObject(newCoachReviewedAt!, forKey: ParseKeys.CoachReviewedAt)
        }
    }
    
    /** Meal Image Orginal. */
    var imageOriginal : PFFile? {
        get{
            if let tempImageOrginal = self.objectForKey(ParseKeys.ImageOriginal) as? PFFile {
                return tempImageOrginal
            }else{
                return nil
            }
        }
        set (newImageOrginal){
            self.setObject(newImageOrginal!, forKey: ParseKeys.ImageOriginal)
        }
    }
    
    /** Meal Image Thumbnail. */
    var imageThumbnail : PFFile? {
        get{
            if let tempImageThumbnail = self.objectForKey(ParseKeys.ImageThumbnail) as? PFFile {
                return tempImageThumbnail
            }else{
                return nil
            }
        }
        set (newImageThumbnail){
            self.setObject(newImageThumbnail!, forKey: ParseKeys.ImageThumbnail)
        }
    }
    
    /** Item Locked. */
    var isLocked : Bool{
        get{
            if let currentIsLocked = self.objectForKey(ParseKeys.Locked) as? Bool {
                return currentIsLocked
            }else{
                return false
            }
        }
        set(newIsLocked){
            self.setObject(newIsLocked, forKey: ParseKeys.Locked)
        }
    }
    
    //User
    var user  : User? {
        get {
            if let tempUser = self.objectForKey(Meal.ParseKeys.User) as? User {
                return tempUser
            }else{
                return nil
            }
        }set(newUser) {
            self.setObject(PFUser(withoutDataWithObjectId: newUser!.objectId), forKey: Meal.ParseKeys.User)
        }
    }
    
    
    /** User Comments. */
    var userComments :  String {
        get{
            if let tempUserComments = self.objectForKey(ParseKeys.UserComments) as? String {
                return tempUserComments
            }else{
                return ""
            }
        }set(newComment){
            if var tempNewUserComments = newComment as String? {
                self.setObject(tempNewUserComments, forKey: ParseKeys.UserComments)
            }else{
                self.setObject("", forKey: ParseKeys.UserComments)
            }
        }
    }
    
    /** User Commented At. */
    var userCommentedAt : NSDate? {
        get {
            if let tempUserCommentedAt = self.objectForKey(ParseKeys.UserCommentedAt) as? NSDate {
                return tempUserCommentedAt
            }else{
                return nil
            }
        }set(newCommentedAt) {
            self.setObject(newCommentedAt!, forKey: ParseKeys.UserCommentedAt)
        }
    }
    
    /** User Reviewed At. */
    var userReviewedAt : NSDate? {
        get {
            if let tempUserReviewedAt = self.objectForKey(ParseKeys.UserReviewedAt) as? NSDate {
                return tempUserReviewedAt
            }else{
                return nil
            }
        }set(newUserReviewedAt) {
            self.setObject(newUserReviewedAt!, forKey: ParseKeys.UserReviewedAt)
        }
    }
    
    /** User Reviewed At. */
    var itemMarkers : [AnyObject] {
        get {
            if let tempItemMarkers = self.objectForKey(ParseKeys.ItemMrakers) as? [[AnyObject]] {
                return tempItemMarkers
            }else{
                return []
            }
        }set(newItemMarkers) {
            self.setObject(newItemMarkers, forKey: ParseKeys.ItemMrakers)
        }
    }
    
    /** Meal is Pinned. */
    var isPinned : Bool {
        get{
            if let tempIsPinned = self.objectForKey(ParseKeys.Pinned) as? Bool {
                return tempIsPinned
            }else{
                return false
            }
        }
        set(newIsPinned){
            self.setObject(newIsPinned, forKey: ParseKeys.Pinned)
        }
    }
    
    /** App Created At. */
    var appCreatedAt :  NSDate {
        get {
            if let tempAppCreatedAt = self.objectForKey(ParseKeys.AppCreatedAt) as? NSDate {
                return tempAppCreatedAt
            }else{
                return NSDate.new()
            }
        }set(newAppCreatedAt) {
            self.setObject(newAppCreatedAt, forKey: ParseKeys.AppCreatedAt)
        }
    }
    
    /** Meal Created At. */
    var mealCreatedAt :  NSDate {
        get {
            return self.createdAt!
        }
    }

}