//
//  FHClientInfo.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/13/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

import Parse


/** FHClientInfo class stands for local instances of ClientInfo Parse class. */
class ClientInfo : PFObject, PFSubclassing {
    
    /** This structure holds all keys for ClientInfo Parse object. */
    struct ParseKeys {
        
        static let ParseClassName = "ClientInfo"
        
        static let BodyFatPercentage = "bodyFatPercentage"
        
        static let Coach = "coach"
        
        static let Diet = "diet"
        
        static let Goals = "goals"
        
        static let Height = "height"
        
        static let Weight = "weight"
        
        static let User = "user"
        
        static let WeekStartDay = "weekStartDay"
        
        static let WeeklyStartDay = "weeklyStartDay"
        
        static let Timezone = "timezone"
        
    }
    
    /** Provide Parse class name to conform to PFSubclassing protocol. */
    static func parseClassName() -> String {
        return ClientInfo.ParseKeys.ParseClassName
    }
    
    /** Coach. */
    var coach : User? {
        get {
            if let tempCoach = self.objectForKey(ClientInfo.ParseKeys.Coach) as? User {
                return tempCoach
            }else{
                return nil
            }
        }set(newCoach) {
            self.setObject(PFUser(withoutDataWithObjectId: newCoach!.objectId), forKey: ClientInfo.ParseKeys.Coach)
        }
    }
    
    /** User. */
    var user : User? {
        get {
            if let tempUser = self.objectForKey(ClientInfo.ParseKeys.User) as? User {
                return tempUser
            }else{
                return nil
            }
        }set(newUser) {
            self.setObject(PFUser(withoutDataWithObjectId: newUser!.objectId), forKey: ClientInfo.ParseKeys.User)
        }
    }
    
    
    /** Body Fat Percentage. */
    var bodyFatPercentage : Float {
        get{
            if let tempBodyFatPercentage = self.objectForKey(ClientInfo.ParseKeys.BodyFatPercentage) as? NSNumber {
                var bodyFatValue = tempBodyFatPercentage.floatValue
                if( bodyFatValue > 1){
                    return (bodyFatValue / 100.0)
                }else{
                  return (bodyFatValue * 100.0)
                }
                
            }else{
                return 0.0
            }
        }
        set(newBodyFatPercentage){
            var bodyFatValue : Float = newBodyFatPercentage
            if( bodyFatValue > 1){
                 bodyFatValue = (bodyFatValue / 100.0)
            }else{
                bodyFatValue =  (bodyFatValue * 100.0)
            }
            self.setObject(NSNumber(float: (bodyFatValue)), forKey: ClientInfo.ParseKeys.BodyFatPercentage)
        }
    }
    
    /** Diet. */
    var diet : String {
        get {
            if let tempDiet = self.objectForKey(ClientInfo.ParseKeys.Diet) as? String {
                return tempDiet
            }else{
                return ""
            }
        }
        
        set (newValue) {
            self.setObject(newValue, forKey: ClientInfo.ParseKeys.Diet)
        }
    }

    /** Goals. */
    var goals : String {
        get {
            if let tempGoals = self.objectForKey(ClientInfo.ParseKeys.Goals) as? String {
                return tempGoals
            }else{
                return ""
            }
        }
        set (newValue) {
            self.setObject(newValue, forKey: ClientInfo.ParseKeys.Goals)
        }
    }
    
    /** Height. */
    var height : String {
        get {
            if let tempHeight = self.objectForKey(ClientInfo.ParseKeys.Height) as? String {
                return tempHeight
            }else{
                return ""
            }
        }
        
        set (newValue) {
            self.setObject(newValue, forKey: ClientInfo.ParseKeys.Height)
        }
    }
    
    /** Weight. */
    var weight : String {
        get {
            if let tempWeight = self.objectForKey(ClientInfo.ParseKeys.Weight) as? String {
                return tempWeight
            }else{
                return ""
            }
        }
        
        set (newValue) {
            self.setObject(newValue, forKey: ClientInfo.ParseKeys.Weight)
        }
    }
    
    /** Week Start Day. */
    var weekStartDay : String {
        get{
            if let tempWeekStartDay = self.objectForKey(ClientInfo.ParseKeys.WeekStartDay) as? String {
                return tempWeekStartDay
            }else{
                return ""
            }
        }
        
        set (newValue) {
            self.setObject(newValue, forKey: ClientInfo.ParseKeys.WeekStartDay)
        }
    }
    
    var timezone : String {
        get {
            return self[ParseKeys.Timezone] as! String
        }
        set (v) {
            self[ParseKeys.Timezone] = v
        }
    }
    
}

