//
//  MealModel.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/23/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class MealModel: NSObject {
   
    /** Meal Model. */
    var selectedMeal : Meal
    
    /** Marks List. */
    var marksList : [MealMark]
    
    
    /** Meal Model Errors Tags. */
    struct ErrorType {
        static let SaveMarksError = "ErrorToSaveMarks"
        static let GetListOfMarksError = "ErrorToGetListOfMarks"
        static let PostMealError = "ErrorToPostMeal"
        static let PinnedMealError = "ErrorToPinnedMeal"
        static let UnPinnedMealError = "ErrorToUnPinnedMeal"
    }
    
    
    /** Meal Model Notifications. */
    struct ModelNotifications {
        static let GetListOfMarksNotification = "GetListOfMarksNotification"
        static let saveListOfMarksNotification = "SaveListOfMarksNotification"
        static let postMealNotification = "postMealNotification"
        static let mealHasReviewedNotification = "mealHasReviewedNotification"
        static let mealHasPinnedNotification = "mealHasPinnedNotification"
        static let mealHasUnPinnedNotification = "mealHasUnPinnedNotification"
    }
    
    
    /** Default constructor of Meal Model */
    override init() {
        self.selectedMeal = Meal(className: Meal.parseClassName())
        self.marksList = []
        super.init()
        
    }
    
    /** Default constructor of Meal Model */
    convenience init(meal : Meal) {
        self.init()
        self.selectedMeal = meal
    }
    
    /** Add Marks To Meal  */
    func addMarksList(checksList : [CGPoint], corssesList : [CGPoint], imageSize : CGSize) {
        
        var listOfData : [AnyObject] = []
        
        for checkMark in checksList  {
            var postCheckMark = MealMark()
            postCheckMark.markType = MealMark.MealMarkType.Check
            postCheckMark.xLoaction = Float(checkMark.x / imageSize.width)
            postCheckMark.yLoaction = Float(checkMark.y / imageSize.height)
            
            /** Add it To List. */
            listOfData.append(postCheckMark.buildMealMarkArray())
        }
      

        for crossMark in corssesList  {
            var postCrossMark = MealMark()
            postCrossMark.markType = MealMark.MealMarkType.Cross
            postCrossMark.xLoaction = Float(crossMark.x / imageSize.width)
            postCrossMark.yLoaction = Float(crossMark.y / imageSize.height)
            
            /** Add it To List. */
            listOfData.append(postCrossMark.buildMealMarkArray())
        }
    
        
        self.selectedMeal.itemMarkers = listOfData
        self.selectedMeal.coachReviewedAt = NSDate()
        var meal = PFObject(withoutDataWithClassName: Meal.parseClassName(), objectId: self.selectedMeal.objectId)
        meal.setObject(NSDate(), forKey: Meal.ParseKeys.CoachReviewedAt)
        meal.setObject(self.selectedMeal.itemMarkers, forKey: Meal.ParseKeys.ItemMrakers)
        meal.saveInBackgroundWithBlock { (done, error : NSError?) -> Void in
            /** The find succeeded. */
            if error == nil {
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.saveListOfMarksNotification, object: self)
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.mealHasReviewedNotification, object: self)
                AppDelegate.getAppDelegate().userTabBarController?.getNotificationCount()
            }else {
                /** Get List Failed With Error. */
                let userInfoDict  = [ErrorType.SaveMarksError: error!]
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.saveListOfMarksNotification, object: self, userInfo: userInfoDict)
            }

        }
    }
    
    func getMarksList() {
        var query = PFQuery(className:Meal.parseClassName())
        query.whereKey(Meal.ParseKeys.ObjectID, equalTo:self.selectedMeal.objectId!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            /** The find succeeded. */
            if error == nil {
                /** Remove All Data in Marks List. */
                self.marksList.removeAll(keepCapacity: false)
                
                /** Start Adding The Marks. */
                if let results = objects  {
                    for result in results as! [Meal] {
                        for mark in result.itemMarkers {
                            var mealMark = MealMark(arrayList: mark as! [AnyObject])
                            self.marksList.append(mealMark)
                        }
                       
                    }
                }
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetListOfMarksNotification, object: self)
                
            }else {
                /** Get List Failed With Error. */
                let userInfoDict  = [ErrorType.GetListOfMarksError: error!]
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.GetListOfMarksNotification, object: self, userInfo: userInfoDict)
            }
        }
    }
    
    /** Update Coach Comments. */
    func updateCoachNote() {
        self.selectedMeal.coachReviewedAt = NSDate()
        self.selectedMeal.saveInBackground()
        AppDelegate.getAppDelegate().userTabBarController?.getNotificationCount()
    }
    
    /** Coach Did Read User Notes. */
    func coachDidReadUserNote(){
        // Send user's verification code to the backend to validate it.
        var parameters : [NSObject : AnyObject] = [:]
        parameters["targetUserId"] = User.currentUser()?.objectId
        parameters["mealId"] = self.selectedMeal.objectId
        
        PFCloud.callFunctionInBackground(FoogCloudCode.markCommentRead, withParameters: parameters) { (result : AnyObject?, error : NSError?) -> Void in
            
            if (error != nil) {

            } else {
                
                if let returnedResults = result as? [AnyObject] {

                }
            }
        }
    }
    
    /** Update User Comments. */
    func updateUserNote() {
        self.selectedMeal.userCommentedAt = NSDate()
        self.selectedMeal.saveInBackground()
    }
    
    /** User Did Read Coach Notes. */
    func userDidReadCoachNote(){
        // Send user's verification code to the backend to validate it.
        var parameters : [NSObject : AnyObject] = [:]
        parameters["targetUserId"] = User.currentUser()?.objectId
        parameters["mealId"] = self.selectedMeal.objectId
        
        PFCloud.callFunctionInBackground(FoogCloudCode.markCommentRead, withParameters: parameters) { (result : AnyObject?, error : NSError?) -> Void in
            
            if (error != nil) {
                
            } else {
                
                if let returnedResults = result as? [AnyObject] {
                    
                }
            }
        }
    }
    
    /** Update User Reviewed At. */
    func updateUserReviewedAt() {
        self.selectedMeal.userReviewedAt = NSDate()
        self.selectedMeal.saveInBackground()
        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.mealHasReviewedNotification, object: self)
    }
    
    /** Pin/unPin Meal. */
    func pinAMeal() {
        var meal = PFObject(withoutDataWithClassName: Meal.parseClassName(), objectId: self.selectedMeal.objectId)
        meal.setObject(self.selectedMeal.isPinned, forKey: Meal.ParseKeys.Pinned)
        meal.saveInBackgroundWithBlock { (isFinished : Bool, error : NSError?) -> Void in
            /** Succeeded. */
            if error == nil {
                /** Post Notification. */
                if(self.selectedMeal.isPinned == true){
                    NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.mealHasPinnedNotification, object: self)
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.mealHasUnPinnedNotification, object: self)
                }
            }else {
                
                if(self.selectedMeal.isPinned == true){
                    /** Failed With Error. */
                    let userInfoDict  = [ErrorType.PinnedMealError: error!]
                    
                    /** Post Notification. */
                    NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.mealHasPinnedNotification, object: self, userInfo: userInfoDict)
                }else{
                    /** Failed With Error. */
                    let userInfoDict  = [ErrorType.UnPinnedMealError: error!]
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.mealHasUnPinnedNotification, object: self, userInfo: userInfoDict)
                }
            }
        }
    }
    
    /** post Meal. */
    func postMeal(user : User , imageOriginal : UIImage , note : String) {
        // Post user's meal to the backend.
        var meal : Meal = Meal(className: Meal.parseClassName())
        meal.user = user
        meal.coach = user.coach
        meal.userComments = note
        let image = imageOriginal.resizedImageWithContentMode(UIViewContentMode.ScaleAspectFit, bounds: Meal.Configration.imageFullSize, interpolationQuality: kCGInterpolationHigh)
        let thumbnail = imageOriginal.resizedImageWithContentMode(UIViewContentMode.ScaleAspectFit, bounds: Meal.Configration.imageThumbnailSize, interpolationQuality: kCGInterpolationHigh)
        let imageFile = PFFile(data: UIImageJPEGRepresentation(image, 0.95))
        let thumbnailFile = PFFile(data: UIImageJPEGRepresentation(thumbnail, 0.95))
        
        meal.imageOriginal = imageFile
        meal.imageThumbnail = thumbnailFile
        meal.appCreatedAt = NSDate()
        
        meal.saveInBackgroundWithBlock { (isFinished : Bool, error : NSError?) -> Void in
            /** The find succeeded. */
            if error == nil {
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.postMealNotification, object: self)
                
            }else {
                /** Get List Failed With Error. */
                let userInfoDict  = [ErrorType.PostMealError: error!]
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.postMealNotification, object: self, userInfo: userInfoDict)
            }
        }
    }
}
