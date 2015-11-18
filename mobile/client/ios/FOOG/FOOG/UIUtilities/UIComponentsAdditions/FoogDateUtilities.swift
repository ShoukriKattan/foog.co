//
//  FoogDateUtilities.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/24/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

/** Privode custom utilities for date manipolations. */
class FoogDateUtilities {
    
    // MARK: - FHDateUtilities
    
    /** Return formatted day to 'MMM dd, yyyy' format or 'Today' or 'Yesterday' according to provided date and current now date. */
    static func formattedDateOrNearDayFromDate(date : NSDate) -> String {
        
        var calendar = NSCalendar.currentCalendar()
        var calnderUntis = (NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitMonth)
        var todayDate = NSDate(timeIntervalSinceNow: 0)
        
        var todayDateComponentCalender = calendar.components(calnderUntis, fromDate: todayDate)
        var yesterdayDate = NSDate(timeIntervalSinceNow: -86400)
        var yesterdayDateComponentCalender = calendar.components(calnderUntis, fromDate: yesterdayDate)
        var twoDaysDate = NSDate(timeIntervalSinceNow: -172800)
        var twoDaysDateComponentCalender = calendar.components(calnderUntis, fromDate: twoDaysDate)
        var currentDateComponents = calendar.components(calnderUntis, fromDate: date)
        if (calendar.dateFromComponents(currentDateComponents)!.compare(calendar.dateFromComponents(todayDateComponentCalender)!) == NSComparisonResult.OrderedSame) {
            return "Today"
        } else if (calendar.dateFromComponents(currentDateComponents)!.compare(calendar.dateFromComponents(yesterdayDateComponentCalender)!)  == NSComparisonResult.OrderedSame) {
            return "Yesterday"
        } else if (calendar.dateFromComponents(currentDateComponents)!.compare(calendar.dateFromComponents(twoDaysDateComponentCalender)!) == NSComparisonResult.OrderedSame) {
            return "Two Days Ago"
        }
        
        return FoogDateUtilities.formattedDateFromDate(date)
    }
    
    /** Return formatted date string from provided date. */
    class func formattedDateFromDate(date : NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        return dateFormatter.stringFromDate(date)
    }
    
}

/** Array of week days. */
let WeekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
