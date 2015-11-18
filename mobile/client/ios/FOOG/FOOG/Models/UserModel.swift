//
//  UserModel.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/7/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

import Parse

/** UserModel */
class UserModel : NSObject {
    
    /** Model Selected User. */
    var selectedUser : User
    
    /** Model Selected Client Info. */
    var selectedClientInfo : ClientInfo?
    
    /** Model Data List. */
    var dataList : [AnyObject] = []
    
    /** Page Number. */
    var pageNumber : Int
    
    /** Has more Meals. */
    var hasMoreData :  Bool?
    
    /** User Model Notifications. */
    struct ModelNotifications {
        static let GetListOfUserFlowNotification = "GetListOfUserFlowNotification"
        static let GetListOfUserPinnedMealsNotification = "GetListOfUserPinnedMealsNotification"
        static let GetListOfUserSummaryCardsNotification = "GetListOfUsersummaryCardsNotification"
        static let GetClientInformationsNotification = "GetClientInformationsNotification"
        static let SaveClientInfoNotification = "SaveClientInfoNotification"
        static let SaveUserNotification = "SaveUserNotification"
        static let UpdateSummaryCardNotification = "UpdateSummaryCardNotification"
        static let UnlinkUserFromHisCoachNotification = "UnlinkUserFromHisCoachNotification"
    }
    
    /** User Model Errors Tags. */
     struct ModelErrorType {
        static let UserFlowError = "ErrorToGetUserFlow"
        static let UserPinnedMealsFlowError = "ErrorToGetUserPinnedMealsFlow"
        static let SummaryCardsError = "ErrorToGetUserSummaryCards"
        static let ClientInfoError = "ErrorToGetClientInfo"
        static let AddClientInfoError = "ErrorToAddClientInfo"
        static let SaveUserInfoError = "ErrorToSaveUser"
        static let UpdateSummaryCardError = "ErrorToUpdateSummaryCard"
        static let UnlinkUserFromHisCoachError = "ErrorToUnlinkUserFromHisCoach"
    }
    
    /** Default constructor of User Model. */
    override init() {
        self.selectedUser = User()
        self.selectedClientInfo = ClientInfo()
        self.hasMoreData = true
        self.pageNumber = 0
        super.init()
        
    }
    
    /**  Init User Model By User. */
    convenience init(user : User) {
        self.init()
        self.selectedUser = user
    }
    
    /** Get User FLow. */
    func getUserFlow() {
        /**  Load user's meals. */
        let streamItemQuery = PFQuery(className: Meal.parseClassName())
        
        streamItemQuery.whereKey(Meal.ParseKeys.User, equalTo: self.selectedUser)
        streamItemQuery.whereKey(Meal.ParseKeys.Coach, equalTo: self.selectedUser.coach!)
        
        /**  Sort items according to creation date. */
        streamItemQuery.orderByDescending(Meal.ParseKeys.CreatedAt)
        
        /** Set Limit in Query. */
        streamItemQuery.limit = 4
        streamItemQuery.skip = 4 * self.pageNumber
        
        //streamItemQuery.whereKey("user", equalTo:self.selectedUser)
        streamItemQuery.findObjectsInBackgroundWithBlock { (items : [AnyObject]?, error : NSError?) -> Void in
            
            /**  TODO: Handle error if it occurred. */
            if (error != nil) {
                let userInfoDict  = [ModelErrorType.UserFlowError: error!]
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetListOfUserFlowNotification, object: self, userInfo: userInfoDict)
                
            }
            
            if let results = items  {
    
                /** check if empty data returned. */
                if(results.isEmpty == true ){
                    
                    self.hasMoreData = false
                    if(self.dataList.count == 0){
                        self.dataList = []
                    }
                    
                    /** Post Notification. */
                    NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetListOfUserFlowNotification, object: self)
                    
                    return
                }
            
                /** Clear the Data List in case its in first page. */
                if(self.pageNumber == 0){
                    self.dataList.removeAll(keepCapacity: false)
                }
                
                /** Set Page Number. */
                self.pageNumber++

                /**  Group items according to their creation day. */
                var currentDayItems = [Meal]()
                var lastDate : NSDate = NSDate()
                let calendar = NSCalendar.currentCalendar()

                if(results.count == 4){
                    self.hasMoreData = true
                }else{
                  self.hasMoreData = false
                }
                
                var mealList : [Meal] = results as! [Meal]
                
                for (var i : Int = 0 ; i < mealList.count ; i++ ) {
                    
                    var meal  = mealList[i]
                    if(i == 0 ){
                       lastDate = meal.mealCreatedAt
                    }
                    
                    var lastDateComponentCalender = calendar.components(NSCalendarUnit.DayCalendarUnit, fromDate: lastDate)
                    var mealDateComponentCalender = calendar.components(NSCalendarUnit.DayCalendarUnit, fromDate: meal.mealCreatedAt)
                
                    /**  Start new day items holder when sorted items creation day change. */
                    if ( calendar.dateFromComponents(lastDateComponentCalender)!.compare(calendar.dateFromComponents(mealDateComponentCalender)!) != NSComparisonResult.OrderedSame ) {
                        
                        self.addMealsByDateToDataList(currentDayItems, withDate: lastDate)
                        currentDayItems = [Meal]()
                        lastDate = meal.mealCreatedAt
                    }

                    /**  Add current item to current day items. */
                    currentDayItems.append(meal)
                    
                    if(i == (mealList.count - 1)){
                        self.addMealsByDateToDataList(currentDayItems, withDate: meal.mealCreatedAt)
                    }
                }
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetListOfUserFlowNotification, object: self)
            }else{
                 self.hasMoreData = false
            }
        }
    }
    
    /** Get User Pinned Meals FLow. */
    func getUserPinnedMealsFlow() {
        /**  Load user's meals. */
        let pinnedMealsQuery = PFQuery(className: Meal.parseClassName())
        
        /** Where the Owner of meal is the selected User. */
        pinnedMealsQuery.whereKey(Meal.ParseKeys.User, equalTo: self.selectedUser)
        pinnedMealsQuery.whereKey(Meal.ParseKeys.Coach, equalTo: self.selectedUser.coach!)
        
        /** Where the meal Pinned. */
        pinnedMealsQuery.whereKey(Meal.ParseKeys.Pinned, equalTo:NSNumber(bool: true))
        
        /**  Sort items according to creation date. */
        pinnedMealsQuery.orderByDescending(Meal.ParseKeys.CreatedAt)
        
        /** Set Limit in Query. */
        pinnedMealsQuery.limit = 4
        pinnedMealsQuery.skip = 4 * self.pageNumber
        
        //streamItemQuery.whereKey("user", equalTo:self.selectedUser)
        pinnedMealsQuery.findObjectsInBackgroundWithBlock { (items : [AnyObject]?, error : NSError?) -> Void in
            
            /**  TODO: Handle error if it occurred. */
            if (error != nil) {
                let userInfoDict  = [ModelErrorType.UserPinnedMealsFlowError: error!]
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetListOfUserPinnedMealsNotification, object: self, userInfo: userInfoDict)
                
            }
            
            if let results = items  {
                
                /** check if empty data returned. */
                if(results.isEmpty == true){
                    
                    self.hasMoreData = false
                    if(self.dataList.count == 0){
                        self.dataList = []
                    }
                    
                    /** Post Notification. */
                    NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetListOfUserPinnedMealsNotification, object: self)
                    
                    return
                }
                
                /** Clear the Data List in case its in first page. */
                if(self.pageNumber == 0){
                    self.dataList.removeAll(keepCapacity: false)
                }
                
                /** Set Page Number. */
                self.pageNumber++
                
                /**  Group items according to their creation day. */
                var currentDayItems = [Meal]()
                var lastDate : NSDate = NSDate()
                let calendar = NSCalendar.currentCalendar()
                
                if(results.count == 4){
                    self.hasMoreData = true
                }else{
                    self.hasMoreData = false
                }
                
                
                var mealList : [Meal] = results as! [Meal]
                
                for (var i : Int = 0 ; i < mealList.count ; i++ ) {
                    
                    var meal  = mealList[i]
                    if(i == 0 ){
                        lastDate = meal.mealCreatedAt
                    }
                    
                    var lastDateComponentCalender = calendar.components(NSCalendarUnit.DayCalendarUnit, fromDate: lastDate)
                    var mealDateComponentCalender = calendar.components(NSCalendarUnit.DayCalendarUnit, fromDate: meal.mealCreatedAt)
                    
                    /**  Start new day items holder when sorted items creation day change. */
                    if ( calendar.dateFromComponents(lastDateComponentCalender)!.compare(calendar.dateFromComponents(mealDateComponentCalender)!) != NSComparisonResult.OrderedSame ) {
                        
                        self.addMealsByDateToDataList(currentDayItems, withDate: lastDate)
                        currentDayItems = [Meal]()
                        lastDate = meal.mealCreatedAt
                    }
                    
                    /**  Add current item to current day items. */
                    currentDayItems.append(meal)
                    
                    if(i == (mealList.count - 1)){
                        self.addMealsByDateToDataList(currentDayItems, withDate: meal.mealCreatedAt)
                    }
                }
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetListOfUserPinnedMealsNotification, object: self)
            }else{
                self.hasMoreData = false
            }
        }
    }
    
    /** Get summary Cards List. */
    func getSummaryCardsForCoach() {
     
        /** Get Client Info First. */
        self.getClientInfoBy(self.selectedUser, coach: self.selectedUser.coach!)
        
        /**  Load Summary Cards. */
        let summaryCardsQuery = PFQuery(className: SummaryCard.parseClassName())
        
        summaryCardsQuery.whereKey(SummaryCard.ParseKeys.User, equalTo: self.selectedUser)
        
        summaryCardsQuery.whereKey(SummaryCard.ParseKeys.Coach, equalTo: self.selectedUser.coach!)
        
        if(User.isLoginUserCoach() == false){
           summaryCardsQuery.whereKeyExists(SummaryCard.ParseKeys.SummaryCreatedAt)
        }
        
        /**  Sort Cards according to creation date. */
        summaryCardsQuery.orderByDescending(SummaryCard.ParseKeys.CreatedAt)
        
        /** Set Limit in Query. */
        summaryCardsQuery.limit = 4
        summaryCardsQuery.skip = 4 * self.pageNumber
        
        summaryCardsQuery.findObjectsInBackgroundWithBlock { (items : [AnyObject]?, error : NSError?) -> Void in
            
            /**  TODO: Handle error if it occurred. */
            if (error != nil) {
                let userInfoDict  = [ModelErrorType.SummaryCardsError: error!]
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetListOfUserSummaryCardsNotification, object: self, userInfo: userInfoDict)
                
            }
            
            if let results = items  {
                
                /** check if empty data returned. */
                if(results.isEmpty == true ){
                    
                    self.hasMoreData = false
                    self.dataList = []
                    
                    /** Post Notification. */
                    NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetListOfUserSummaryCardsNotification, object: self)
                    
                    return
                }
                
                /** Clear the Data List in case its in first page. */
                if(self.pageNumber == 0){
                    self.dataList.removeAll(keepCapacity: false)
                }
                
                /** Set Page Number. */
                self.pageNumber++
                
                /** Set if the Model has More Data. */
                if(results.count == 4){
                    self.hasMoreData = true
                }else{
                    self.hasMoreData = false
                }
                
                /** Add the Results to Model Data. */
                for result in results as! [SummaryCard] {
                    self.dataList.append(result)
                }
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetListOfUserSummaryCardsNotification, object: self)

            }else{
                self.hasMoreData = false
            }
        }
    }
    
    /** Get Client Informations . */
    func getClientInfoBy(user : User, coach: User) {
        
        /**  Load Client Info. */
        let clientQuery = PFQuery(className: ClientInfo.parseClassName())
        
        clientQuery.whereKey(ClientInfo.ParseKeys.User, equalTo: user)
        
        clientQuery.whereKey(ClientInfo.ParseKeys.Coach, equalTo: coach)
        
        
        clientQuery.findObjectsInBackgroundWithBlock { (items : [AnyObject]?, error : NSError?) -> Void in
            
            /**  TODO: Handle error if it occurred. */
            if (error != nil) {
                let userInfoDict  = [ModelErrorType.ClientInfoError: error!]
                
                self.selectedClientInfo = ClientInfo()
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetClientInformationsNotification, object: self, userInfo: userInfoDict)
            }
            
            if let results = items  {
    
                /** check if empty data returned. */
                if(results.isEmpty == false ){
                    /** Add the Results to Model Data. */
                    for result in results as! [ClientInfo] {
                        self.selectedClientInfo = result
                    }
                }else{
                     self.selectedClientInfo = ClientInfo()
                }
                
                /** Post Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(UserModel.ModelNotifications.GetClientInformationsNotification, object: self)
            }
        }
    }
    
    /** Save Client Info. */
    func saveClientInfo(){
        if var clientInfo = self.selectedClientInfo {
            /**  Load Client Info. */
            let clientQuery = PFQuery(className: ClientInfo.parseClassName())
            
            clientQuery.whereKey(ClientInfo.ParseKeys.User, equalTo: clientInfo.user!)
            
            clientQuery.whereKey(ClientInfo.ParseKeys.Coach, equalTo: clientInfo.coach!)
            
            clientQuery.getFirstObjectInBackgroundWithBlock { (item : AnyObject?, error : NSError?) -> Void in
                /**  TODO: Handle error if it occurred. */
                if (error != nil) {
                    let userInfoDict  = [ModelErrorType.AddClientInfoError: error!]
                    /** send Notification. */
                    NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.SaveClientInfoNotification, object: self.selectedClientInfo , userInfo:userInfoDict)
                }
                
                
                
                var modifiedClientInfo = ClientInfo(className: ClientInfo.parseClassName())
                if let result = item  as? ClientInfo {
                    modifiedClientInfo = result
                }
                
                
                modifiedClientInfo.user = clientInfo.user!
                modifiedClientInfo.coach = clientInfo.coach
                modifiedClientInfo.weekStartDay = clientInfo.weekStartDay
                modifiedClientInfo.height = clientInfo.height
                modifiedClientInfo.weight = clientInfo.weight
                modifiedClientInfo.bodyFatPercentage = clientInfo.bodyFatPercentage
                modifiedClientInfo.diet = clientInfo.diet
                modifiedClientInfo.goals = clientInfo.goals
                modifiedClientInfo.timezone = NSTimeZone.systemTimeZone().name
                
                modifiedClientInfo.saveInBackgroundWithBlock { (updatrDone, error : NSError?) -> Void in
                    
                    if error == nil {
                        /** send Notification. */
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.SaveClientInfoNotification, object: clientInfo)
                    }else{
                        let userInfoDict  = [ModelErrorType.AddClientInfoError: error!]
                        /** send Notification. */
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.SaveClientInfoNotification, object: clientInfo , userInfo:userInfoDict)
                    }
                    
                }
                
            }
        }else{
            let userInfoDict  = [ModelErrorType.AddClientInfoError: "Error"]
            /** send Notification. */
            NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.SaveClientInfoNotification, object: self.selectedClientInfo , userInfo:userInfoDict)
        }
    }
    
    /** Save User. */
    func saveUser(user : User) {
        
        user.saveInBackgroundWithBlock { (success : Bool, error : NSError?) -> Void in
            
            if error == nil {
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.SaveUserNotification, object: user)
            } else {
                let errorInfo = [ModelErrorType.SaveUserInfoError : error!]
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.SaveUserNotification, object: user, userInfo: errorInfo)
            }
            
        }
        
    }
    
    /** Unlink provided User from his current Coach. */
    func unlinkUserFromHisCoach(user : User) {
        
        // Find user's coach link.
        var linkQuery = PFQuery(className: CoachUserLink.ParseKeys.ParseClassName)
        linkQuery.whereKey(CoachUserLink.ParseKeys.User, equalTo:user)
        linkQuery.orderByDescending("createdAt")
        linkQuery.getFirstObjectInBackgroundWithBlock { (linkObject : PFObject?, error : NSError?) -> Void in
            
            if let e = error {
                let errorInfo = [ModelErrorType.UnlinkUserFromHisCoachError : e]
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.UnlinkUserFromHisCoachNotification, object: linkObject, userInfo: errorInfo)
            } else {
                
                // Set user's link as terminated by him.
                let link = linkObject as! CoachUserLink!
                link.terminatedBy = user
                link.userTerminatedAt = NSDate()
                link.saveInBackgroundWithBlock({ (success : Bool, error : NSError?) -> Void in
                    
                    if let e = error {
                        let errorInfo = [ModelErrorType.UnlinkUserFromHisCoachError : e]
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.UnlinkUserFromHisCoachNotification, object: linkObject, userInfo: errorInfo)
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.UnlinkUserFromHisCoachNotification, object: link)
                    }
                    
                })
                
            }
            
        }
        
    }

    /** Update Summary Card. */
    func updateSummaryCard(summaryCard : SummaryCard){
        summaryCard.saveInBackgroundWithBlock { (updatrDone, error : NSError?) -> Void in
            
            if error == nil {
                /** send Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.UpdateSummaryCardNotification, object: self)
            }else{
                let userInfoDict  = [ModelErrorType.UpdateSummaryCardError: error!]
                /** send Notification. */
                NSNotificationCenter.defaultCenter().postNotificationName(ModelNotifications.UpdateSummaryCardNotification, object: self , userInfo:userInfoDict)
            }
            
        }
    }
    
    /** Compare Date for Meals List. */
    func addMealsByDateToDataList(mealsList : [Meal], withDate : NSDate) {
        if(self.dataList.count == 0 ){
            self.dataList.append(mealsList)
        }else{
            
            /** Get Last Date in List. */
            var lastList = self.dataList.last as? [Meal]
            if let lastDayMeals = lastList {
                /** Get Date for Last Day Meal. */
                var lastMeal = lastDayMeals.last as Meal!
                let calendar = NSCalendar.currentCalendar()
                var calnderUntis = (NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth)
                var lastMealComponentCalender = calendar.components(calnderUntis, fromDate: lastMeal.mealCreatedAt)
                var withDateComponentCalender = calendar.components(calnderUntis, fromDate: withDate)
                
                /**  Start new day items holder when sorted items creation day change. */
                if (calendar.dateFromComponents(lastMealComponentCalender)!.compare(calendar.dateFromComponents(withDateComponentCalender)!) == NSComparisonResult.OrderedSame ) {
                    lastList?.extend(mealsList)
                    self.dataList[self.dataList.count - 1] = lastList!
                }else{
                    self.dataList.append(mealsList)
                }
            }else{
                self.dataList.append(mealsList)
            }
        }
    }
}