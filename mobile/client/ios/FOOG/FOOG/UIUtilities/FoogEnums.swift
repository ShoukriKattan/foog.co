//
//  FoogEnums.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/5/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit


/** Sex type. */
enum SexType : String {
    case Male = "Male"
    case Female = "Female"
}



/** Week Day Name. */
enum DayOfWeek : Int , Printable {
    case Sunday
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
    
    static let strings = NSDateFormatter().standaloneWeekdaySymbols as! [String]
    static let shortStrings = NSDateFormatter().shortWeekdaySymbols as! [String]
    
    init(value : String) {
        switch(value.capitalizedString){
        case DayOfWeek.Sunday.description:
            self = .Sunday
        case DayOfWeek.Monday.description:
            self = .Monday
        case DayOfWeek.Tuesday.description:
            self = .Tuesday
        case DayOfWeek.Wednesday.description:
            self = .Wednesday
        case DayOfWeek.Thursday.description:
            self = .Thursday
        case DayOfWeek.Friday.description:
            self = .Friday
        case DayOfWeek.Saturday.description:
            self = .Saturday
        default:
            self = .Sunday
        }
    }
    
    func string() -> String {
        return DayOfWeek.strings[self.rawValue]
    }
    
    var description:String {
        get {
            return string()
        }
    }
}
