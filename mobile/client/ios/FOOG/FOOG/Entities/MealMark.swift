//
//  MealMark.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/24/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse



class MealMark  {
    
    /** Mark Type. */
    var markType : MealMarkType
    
    /** X Loaction. */
    var xLoaction : Float
    
    /** Y Loaction. */
    var yLoaction : Float

    
    /** Parse Meal Marker Keys. */
    struct ParseKeys  {
        static let StreamItem = "StreamItem"
        static let IsCheckOrCross = "type"
        static let LocationX = "locX"
        static let LocationY = "locY"
    }
    
    /** Meal Mark type. */
    enum MealMarkType : String {
        case Check = "Check"
        case Cross = "Cross"
    }
    
    init() {
        
        /** Init Mark Type. */
        self.markType = MealMarkType.Check
        
        /** Init X Loaction. */
        self.xLoaction = 0
        
        /** Init Y Loaction. */
        self.yLoaction = 0
    }
    
    convenience init(arrayList : [AnyObject] ){
        self.init()
        
        /** Init Mark Type. */
        if var tempType = arrayList[0] as? String {
            if tempType.capitalizedString == MealMarkType.Check.rawValue {
                self.markType =  MealMarkType.Check
            }else{
                self.markType =  MealMarkType.Cross
            }
        }else{
            self.markType =  MealMarkType.Check
        }

        /** Init X Loaction. */
        if var tempXLocation = arrayList[1] as? Float {
            self.xLoaction = tempXLocation
        }else{
            self.xLoaction = 0
        }
        
        /** Init Y Loaction. */
        if var tempYLocation = arrayList[2] as? Float {
            self.yLoaction = tempYLocation
        }else{
            self.yLoaction = 0
        }
    }
    
    /** Build Meal Mark Array. */
    func buildMealMarkArray() -> [AnyObject] {
        return [self.markType.rawValue,self.xLoaction,self.yLoaction]
    }
    
}


