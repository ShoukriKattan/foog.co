//
//  CoachModel.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/10/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class CoachModel: NSObject {
   
    /** Selected Coach for Model. */
    var selectedCoach : User
    
    /** Users List. */
    var userList : [User] = []
    
    /** Link Requests List. */
    var linkRequests : [CoachUserLink] = []
    
    /** Coach Model Notifications. */
    struct ModelNotifications {
        static let GetListOfActiveUsersByCoachNotification = "GetListOfActiveUsersNotification"
        static let GetListOfInActiveUsersByCoachNotification = "GetListInActiveOfUsersNotification"
        static let GetListOfPendingUsersByCoachNotification = "GetListOfPendingUsersNotification"
        static let RejectUserLinkNotification = "RejectUserLinkNotification"
        static let AcceptUserLinkNotification = "AcceptUserLinkNotification"
        static let InactiveUserNotification = "InactiveUserNotification"
    }
    
    /** Coach Model Errors Tags. */
    struct ModelErrorType {
        static let RejectUserRequestError = "ErrorToRejectUserRequest"
        static let AcceptUserRequestError = "ErrorToAccepttUserRequest"
        static let InactiveUserError = "ErrorToInactiveUser"
    }

    /** Default constructor of Coach Model */
    override init() {
        self.selectedCoach = User()
        super.init()
    }
    
     /** Default constructor of Coach Model */
    convenience init(coach : User) {
        self.init()
        self.selectedCoach = coach
    }
    
    /** Set Coach - User link for provided Coach and User as terminated by Coach. */
    func moveUserToInactive(user : User, coach : User) {
        // Find Coach / User link.
        var linkQuery = PFQuery(className: CoachUserLink.ParseKeys.ParseClassName)
        linkQuery.whereKey(CoachUserLink.ParseKeys.Coach, equalTo: coach)
        linkQuery.whereKey(CoachUserLink.ParseKeys.User, equalTo: user)
        linkQuery.orderByDescending("createdAt")
        linkQuery.getFirstObjectInBackgroundWithBlock { (linkObject : PFObject?, error : NSError?) -> Void in
            
            if let e = error {
                let errorInfo = [ModelErrorType.InactiveUserError : e]
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.InactiveUserNotification, object: linkObject, userInfo: errorInfo)
            } else {
                
                // Set Coach / User link as terminated by coach.
                let link = linkObject as! CoachUserLink!
                link.terminatedBy = coach
                link.userTerminatedAt = NSDate()
                link.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
                    
                    if let e = error {
                        let errorInfo = [ModelErrorType.InactiveUserError : e]
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.InactiveUserNotification, object: linkObject, userInfo: errorInfo)
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.InactiveUserNotification, object: link)
                    }
                    
                })
            }
        }
    }
    
    /** Get Active Users For Coach */
    func getActiveCoachUsers() {
            var query = PFQuery(className: CoachUserLink.parseClassName())
            query.whereKey(CoachUserLink.ParseKeys.Coach, equalTo:self.selectedCoach)
            query.whereKeyExists(CoachUserLink.ParseKeys.LinkedAt)
            query.whereKeyDoesNotExist(CoachUserLink.ParseKeys.TerminatedAt)
            query.includeKey(CoachUserLink.ParseKeys.User)
            query.orderByDescending(CoachUserLink.ParseKeys.CreatedAt)
            query.includeKey(CoachUserLink.ParseKeys.Coach)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    /** The find succeeded. */
                    if let results = objects  {
                        self.userList.removeAll(keepCapacity: false)
                        for result in results as! [PFObject] {
                            var user = result.objectForKey(CoachUserLink.ParseKeys.User) as! User
                            user.isActive = true
                            self.userList.append(user)
                        }
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetListOfActiveUsersByCoachNotification, object: self)

                    }
                } else {
                    /** Log details of the failure */
                    println("Error: \(error!) \(error!.userInfo!)")
                }
        }
    }
    
    /** Get In Active Users For Coach */
    func getInActiveCoachUsers() {
        var query = PFQuery(className: CoachUserLink.ParseKeys.ParseClassName)
        query.whereKey(CoachUserLink.ParseKeys.Coach, equalTo:self.selectedCoach)
        query.whereKeyExists(CoachUserLink.ParseKeys.LinkedAt)
        query.whereKeyDoesNotExist(CoachUserLink.ParseKeys.RejectedAt)
        query.includeKey(CoachUserLink.ParseKeys.User)
        query.orderByDescending(CoachUserLink.ParseKeys.CreatedAt)
        query.includeKey(CoachUserLink.ParseKeys.Coach)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                /** The find succeeded. */
                if let results = objects  {
                    self.userList.removeAll(keepCapacity: false)
                    
                    /** init data list map. */
                    var dataList : [User] = []
                    var dataListMap = [String : NSNumber]()
                    var activeDataListMap =  [String : String]()
                    
                    for result in results as! [PFObject] {
                        var user = result.objectForKey(CoachUserLink.ParseKeys.User) as! User
                        user.isActive = false
                        if let userMap = dataListMap[user.objectId!] {
                            
                        }else{
                            if let terminatedAt = result.objectForKey(CoachUserLink.ParseKeys.TerminatedAt) as? NSDate {
                                
                            }else{
                                activeDataListMap[user.objectId!] = user.objectId!
                            }

                            dataListMap[user.objectId!] = NSNumber(integer: self.userList.count)
                            dataList.append(user)
                        }
                    }

                    for user in dataList as [User] {
                        if let activeUser = activeDataListMap[user.objectId!] {
                            
                        }else{
                            user.coach = PFUser.currentUser() as? User
                            self.userList.append(user)
                           
                        }
                    }
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetListOfInActiveUsersByCoachNotification, object: self)
                    
                }
            }else {
                /** Log details of the failure */
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
    /** Get Pending Users For Coach  */
    func getPendingCoachUsers() {
        var query = PFQuery(className:CoachUserLink.ParseKeys.ParseClassName)
        query.whereKey(CoachUserLink.ParseKeys.Coach, equalTo:self.selectedCoach)
        query.whereKeyDoesNotExist(CoachUserLink.ParseKeys.LinkedAt)
        query.whereKeyDoesNotExist(CoachUserLink.ParseKeys.TerminatedAt)
        query.whereKeyDoesNotExist(CoachUserLink.ParseKeys.RejectedAt)
        query.whereKeyDoesNotExist(CoachUserLink.ParseKeys.CancelledAt)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                /** The find succeeded. */
                if let results = objects  {
                    self.userList.removeAll(keepCapacity: false)
                    
                    if(results.count == 0){
                        /** send Notification. */
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetListOfPendingUsersByCoachNotification, object: self)
                    }else{
                        for result : CoachUserLink in results as! [CoachUserLink] {
                            var user = result.objectForKey(CoachUserLink.ParseKeys.User) as! User
                            user.fetchIfNeededInBackgroundWithBlock({ (userObject : PFObject?, error : NSError?) -> Void in
                                result.user = user
                                self.linkRequests.append(result)
                                if (self.linkRequests.count == results.count) {
                                    /** Sort List.*/
                                    sort(&self.linkRequests, { (coachUserLink1 : CoachUserLink , coachUserLink2 : CoachUserLink) -> Bool in
                                        coachUserLink1.createdAt?.compare(coachUserLink2.createdAt!) == NSComparisonResult.OrderedDescending
                                    })
 
                                    
                                    /** send Notification. */
                                    NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetListOfPendingUsersByCoachNotification, object: self)
                                }
                            })
                        }
                    }
       
                }
            }else {
                /** Log details of the failure */
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
    /** Reject Link Request. */
    func rejectLinkRequest(rejectedRequest : CoachUserLink){
        var coachUserLink = PFObject(withoutDataWithClassName: CoachUserLink.parseClassName(), objectId: rejectedRequest.objectId) as! CoachUserLink
        coachUserLink.userRejectedAt = NSDate.new()
        
        coachUserLink.saveInBackgroundWithBlock { (updateDone, error : NSError?) -> Void in
            
            if error == nil {
                /** send Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.RejectUserLinkNotification, object: rejectedRequest)
            }else{
                let userInfoDict  = [ModelErrorType.RejectUserRequestError: error!]
                /** send Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.RejectUserLinkNotification, object: rejectedRequest , userInfo:userInfoDict)
            }

        }
    }
    
    /** Accept Link Request. */
    func acceptLinkRequest(acceptedRequest : CoachUserLink){
        var coachUserLink = PFObject(withoutDataWithClassName: CoachUserLink.parseClassName(), objectId: acceptedRequest.objectId) as! CoachUserLink
        coachUserLink.userLinkedAt = NSDate.new()
        coachUserLink.userTerminatedAt = nil
        coachUserLink.userRejectedAt = nil
        
        coachUserLink.saveInBackgroundWithBlock { (updateDone, error : NSError?) -> Void in
            
            if error == nil {
                /** send Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.AcceptUserLinkNotification, object: acceptedRequest)
            }else{
                let userInfoDict  = [ModelErrorType.AcceptUserRequestError: error!]
                /** send Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.AcceptUserLinkNotification, object: acceptedRequest , userInfo:userInfoDict)
            }
            
        }
    }
    

}
