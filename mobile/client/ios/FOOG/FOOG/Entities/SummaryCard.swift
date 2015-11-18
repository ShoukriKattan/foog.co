//
//  SummaryCard.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/7/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

import Parse

/** SymmartCard entity. */
class SummaryCard : PFObject , PFSubclassing {
    
    
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
        return "SummaryCard"
    }
    
    
    /** Parse Meal Keys. */
    struct ParseKeys {
        static let ChecksCount = "checks"
        static let CrossesCount = "crosses"
        static let MealsCount = "meals"
        static let Efficiency = "efficiency"
        static let BodyFatPercent = "bodyFatPercent"
        static let ImageOriginal = "imageOriginal"
        static let ImageThumbnail = "imageThumb"
        static let PeakDay = "peakDay"
        static let WeekNumber = "weekNumber"
        static let Weight = "weight"
        static let EfficiencyDataMonth = "efficiencyDataMonth"
        static let EfficiencyDataWeek = "efficiencyDataWeek"
        static let User = "user"
        static let Coach = "coach"
        static let CreatedAt = "createdAt"
        static let SummaryCreatedAt = "summaryCreatedAt"
    }
    
    /** Number of checks in this SummaryCard. */
    var checksCount : Int {
        get{
            if let tempChecksCount = self.objectForKey(ParseKeys.ChecksCount) as? NSNumber {
                return (tempChecksCount.integerValue)
            }else{
                return 0
            }
        }
        set(newChecksCount){
            self.setObject(NSNumber(integer: newChecksCount), forKey: ParseKeys.ChecksCount)
        }
    }
    
    /** Number of crosses in this SummaryCard. */
    var crossesCount :  Int {
        get{
            if let tempCrossesCount = self.objectForKey(ParseKeys.CrossesCount) as? NSNumber {
                return (tempCrossesCount.integerValue)
            }else{
                return 0
            }
        }
        set(newCrossesCount){
            self.setObject(NSNumber(integer: newCrossesCount), forKey: ParseKeys.CrossesCount)
        }
    }
    
    
    /** Number of meals in this SummaryCard. */
    var mealsCount : Int {
        get{
            if let tempMealsCount = self.objectForKey(ParseKeys.MealsCount) as? NSNumber {
                return (tempMealsCount.integerValue)
            }else{
                return 0
            }
        }
        set(newMealsCount){
            self.setObject(NSNumber(integer: newMealsCount), forKey: ParseKeys.MealsCount)
        }
    }
    
    /** Value of efficiency within in this SummaryCard. Takes values < 0 and > 1. */
    var efficiency : Float {
        get{
            if let tempEfficiency = self.objectForKey(ParseKeys.Efficiency) as? NSNumber {
                var value = tempEfficiency.floatValue
                if(value > 1){
                    return (value)/100.0
                }else{
                   return value
                }
            }else{
                return 0.0
            }
        }
        set(newEfficiency){
            if(newEfficiency>1.0){
                 self.setObject(NSNumber(float: newEfficiency/100.0), forKey: ParseKeys.Efficiency)
            }else{
               self.setObject(NSNumber(float: 1.0), forKey: ParseKeys.Efficiency)
            }
           
        }
    }
    
    /** Value of Body Fat Percent within in this SummaryCard. Takes values < 0 and > 1. */
    var bodyFatPercent : Float {
        get{
            if let tempBodyFatPercent = self.objectForKey(ParseKeys.BodyFatPercent) as? NSNumber {
                var bodyFatValue = tempBodyFatPercent.floatValue
                if( bodyFatValue > 1){
                    return (bodyFatValue / 100.0)
                }else{
                    return (bodyFatValue * 100.0)
                }
            }else{
                return 0.0
            }
        }
        set(newBodyFatPercent){
            var bodyFatValue : Float = newBodyFatPercent
            if( bodyFatValue > 1){
                bodyFatValue = (bodyFatValue / 100.0)
            }else{
                bodyFatValue =  (bodyFatValue * 100.0)
            }
            self.setObject(NSNumber(float: bodyFatValue), forKey: ParseKeys.BodyFatPercent)
        }
    }
    
    
    /** Image Orginal in this SummaryCard. */
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
    
    /** Image Thumbnail in this SummaryCard. */
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
    
    /** Summary Created At Date */
    var summaryCreatedAt : NSDate? {
        get{
            if let temSummaryCreatedAt = objectForKey(ParseKeys.SummaryCreatedAt) as? NSDate {
                return temSummaryCreatedAt
            }else{
                return nil
            }
        }
        set (newSummaryCreatedAt){
            self.setObject(newSummaryCreatedAt!, forKey: ParseKeys.SummaryCreatedAt)
        }
    }

    
    /** Peak Day in this SummaryCard. */
    var peakDay : String{
        get{
            
            if let tempPeakDay = self.objectForKey(ParseKeys.PeakDay) as? String {
                return tempPeakDay
            }else{
                return ""
            }
        }
        set(newPeakDay){
            self.setObject(newPeakDay, forKey: ParseKeys.PeakDay)
        }
    }
    
    /** Week Number in this SummaryCard. */
    var weekNumber : Int {
        get{
            if let tempWeekNumber = self.objectForKey(ParseKeys.WeekNumber) as? NSNumber {
                return (tempWeekNumber.integerValue)
            }else{
                return 0
            }
        }
        set(newWeekNumber){
            self.setObject(NSNumber(integer: newWeekNumber), forKey: ParseKeys.WeekNumber)
        }
    }
    
    
    /** Weight */
    var weight : Float{
        get{
            if let tempWeight = self.objectForKey(ParseKeys.Weight) as? NSNumber {
                return tempWeight.floatValue
            }else{
                return 0.0
            }
        }
        set(newWeight){
            self.setObject(NSNumber(float: newWeight), forKey: ParseKeys.Weight)
        }
    }
    
    /** Array of efficiency values for one Month Where one value per day used to draw efficiency chart. */
    var efficiencyDataMonthPoints : [[String: AnyObject]] {
        get{
            if let tempEfficiencyDataMonthPoints = self.objectForKey(ParseKeys.EfficiencyDataMonth) as? [[String: AnyObject]] {
                return tempEfficiencyDataMonthPoints
            }else{
                return [[String: AnyObject]]()
            }
        }
        set(newEfficiencyDataMonthPoints){
            self.setObject(newEfficiencyDataMonthPoints, forKey: ParseKeys.EfficiencyDataMonth)
        }
    }
    

    /** Array of efficiency values for One Week where one value per day used to draw efficiency chart. */
    var efficiencyDataWeekPoints : [Float] {
        get{
            if let tempEfficiencyDataWeekPoints = self.objectForKey(ParseKeys.EfficiencyDataWeek) as? [Float] {
                return tempEfficiencyDataWeekPoints
            }else{
                return []
            }
        }
        set(newEfficiencyDataWeekPoints){
            self.setObject(newEfficiencyDataWeekPoints, forKey: ParseKeys.EfficiencyDataWeek)
        }
    }

    /** User. */
    var user : User? {
        get {
            if let tempUser = self.objectForKey(ParseKeys.User) as? User {
                return tempUser
            }else{
                return nil
            }
        }set(newUser) {
            self.setObject(PFUser(withoutDataWithObjectId: newUser!.objectId), forKey: ParseKeys.User)
        }
    }
    
    /** Coach. */
    var coach : User? {
        get {
            if let tempCoach = self.objectForKey(ParseKeys.Coach) as? User {
                return tempCoach
            }else{
                return nil
            }
        }set(newCoach) {
            self.setObject(PFUser(withoutDataWithObjectId: newCoach!.objectId), forKey: ParseKeys.Coach)
        }
    }
    
}
