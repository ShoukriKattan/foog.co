//
//  UIUtilities.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/14/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit
import ParseUI

 public class UIUtilities: NSObject {
   
    /** Make UIImageView Circle. */
    class func makeCircleImage(image : UIImageView) -> UIImageView {
        
        var heightOfImageLayer = image.frame.size.height;
        heightOfImageLayer = floor(heightOfImageLayer);
        image.layer.cornerRadius = image.frame.size.height/2
        image.layer.masksToBounds = true;
        image.layer.borderWidth = 0;
        return image
    }
    
    /** Make PFImageView Circle. */
    class func makeCirclePFImageView(image : PFImageView) -> PFImageView {
        
        var heightOfImageLayer = image.frame.size.height;
        heightOfImageLayer = floor(heightOfImageLayer);
        image.layer.cornerRadius = image.frame.size.height/2
        image.layer.masksToBounds = true;
        image.layer.borderWidth = 0;
        return image
    }
    
    /** Convert PFImageView To Gray Scale. */
    class func convertImageToGrayScale(image : PFImageView) -> PFImageView {
    
        let imageRect = CGRectMake(0, 0, image.frame.size.width, image.frame.size.height);
        let colorSpace = CGColorSpaceCreateDeviceGray();
        
        let width = UInt(image.frame.size.width)
        let height = UInt(image.frame.size.height)
        let context = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, colorSpace, .allZeros);
        CGContextDrawImage(context, imageRect, image.image!.CGImage!);
        
        let imageRef = CGBitmapContextCreateImage(context);
        let newImage = UIImage(CGImage: imageRef)
        image.image = newImage
        return image
    }
    
    
    /** Generate Image from Color and Size. */
    class func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /** Generate Image with Gradient Green Color. */
    class func getGradientGreenImage(Diagonal : Bool, size: CGSize) -> UIImage  {
        //Green Color
        var colors = [UIColor(red: 97.0/255.0, green: 223.0/255.0, blue: 220.0/255.0, alpha: 1.0).CGColor,UIColor(red: 152.0/255.0, green: 236.0/255.0, blue: 150.0/255.0, alpha: 1.0).CGColor]
        
        /** Create White Image. */
        var modifiedsize = size
        if(size.width == 0 || size.height == 0){
            modifiedsize = CGSizeMake(40.0, 40.0)
        }
        var whiteImage = UIUtilities.getImageWithColor(UIColor.whiteColor(), size: modifiedsize)
        
        /** Set Gradient Color. */
        if(Diagonal == true){
            return whiteImage.setDiagonalGradientColors(colors)
        }else{
            return whiteImage.setLinearGradientColors(colors)
        }
    }

    /** Generate Image with Gradient Blue Color. */
    class func getGradientBlueImage(Diagonal : Bool , size: CGSize) -> UIImage  {
        //Green Color
        var colors = [UIColor(red: 50.0/255.0, green: 69.0/255.0, blue: 96.0/255.0, alpha: 1.0).CGColor,UIColor.blackColor().CGColor]
        
        /** Create White Image. */
        var modifiedsize = size
        if(size.width == 0 || size.height == 0){
            modifiedsize = CGSizeMake(40.0, 40.0)
        }
        var whiteImage = UIUtilities.getImageWithColor(UIColor.whiteColor(), size: modifiedsize)
        
        /** Set Gradient Color. */
        if(Diagonal == true){
            return whiteImage.setDiagonalGradientColors(colors)
        }else{
            return whiteImage.setLinearGradientColors(colors)
        }
    }
    
    /** Fonts That we will use. */
    struct FontsName {
        /** Helvetica Name. */
        static let helveticaFont  = "Helvetica Neue"
        static let helveticaBoldFont  = "Helvetica Neue-Bold"
    }
    
    /** Get week days starting by Day. */
    class func getWeekDaysStartAt(startDay : String) -> [String] {
        var shortWeekDays = NSDateFormatter().shortWeekdaySymbols as! [String]
        
        func getWeekDaysStartedAtIndex(index : Int) -> [String] {
            var dayWeekList : [String] = []
            for(var i : Int = index ; i < shortWeekDays.count ; i++ ) {
                dayWeekList.append(shortWeekDays[i])
            }
            
            if(dayWeekList.count == shortWeekDays.count){
                return dayWeekList
            }else{
                for(var i : Int = 0 ; i < index  ; i++ ) {
                    dayWeekList.append(shortWeekDays[i])
                }
            }
            
            return dayWeekList
        }
        
        switch(startDay.capitalizedString){
            case DayOfWeek.Sunday.description:
                return shortWeekDays
            case DayOfWeek.Monday.description:
                return getWeekDaysStartedAtIndex(1)
            case DayOfWeek.Tuesday.description:
                return getWeekDaysStartedAtIndex(2)
            case DayOfWeek.Wednesday.description:
                return getWeekDaysStartedAtIndex(3)
            case DayOfWeek.Thursday.description:
                return getWeekDaysStartedAtIndex(4)
            case DayOfWeek.Friday.description:
                return getWeekDaysStartedAtIndex(5)
            case DayOfWeek.Saturday.description:
                return getWeekDaysStartedAtIndex(6)
            default:
                return shortWeekDays
        }
    }
}



