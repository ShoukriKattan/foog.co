//
//  ULabel+Additions.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

extension UILabel {
    
    
    /** Set gradient highlight to label text used by default for FOOG. */
    func setFoogDefaultTitleGradientColor() {
        // Create gradient layer.
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 97.0/255.0, green: 223.0/255.0, blue: 220.0/255.0, alpha: 1.0).CGColor,UIColor(red: 152.0/255.0, green: 236.0/255.0, blue: 150.0/255.0, alpha: 1.0).CGColor]
        gradientLayer.locations = [0.0 , 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        
        // Convert gradient layer to UIImage.
        UIGraphicsBeginImageContext(self.frame.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext())
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.textColor = UIColor(patternImage: gradientImage)
    }
    
    
}