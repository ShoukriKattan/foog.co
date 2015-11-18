//
//  UIView+Additions.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/18/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import ObjectiveC

/** Key for association of this view and gradient layer when being added. */
private var backgroundGradientLayerKey = "backgroundGradientLayer"

extension UIView {
    
    /** Reference to gradient background layer once it is added. */
    private var backgroundGradientLayer : CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &backgroundGradientLayerKey) as! CAGradientLayer?
        }
        set (newValue) {
            objc_setAssociatedObject(self, &backgroundGradientLayerKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    /** 
       Add FOOG application's default gradient background layer to this view. 
       A new gradient background will be added each time this method is invoked and previouse one will not be removed.
     */
    func addDefaultGradientBackground() -> CAGradientLayer {
        
        if (self.backgroundGradientLayer != nil) {
            self.backgroundGradientLayer?.removeFromSuperlayer()
        }
        
        self.backgroundGradientLayer = CAGradientLayer()
        self.backgroundGradientLayer!.colors = [UIColor(red: 50.0/255.0, green: 69.0/255.0, blue: 96.0/255.0, alpha: 1.0).CGColor,UIColor.blackColor().CGColor]
        self.backgroundGradientLayer!.locations = [0.0 , 1.0]
        self.backgroundGradientLayer!.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.backgroundGradientLayer!.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.backgroundGradientLayer!.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        self.layer.insertSublayer(self.backgroundGradientLayer, atIndex: 0)
        return self.backgroundGradientLayer!
    }
    
    /** Extends UIView class to add auto layout gradient background. */
    override public class func initialize () {
        
        struct OnlyOnce {
            static var once = dispatch_once_t()
        }
        dispatch_once(&OnlyOnce.once, { () -> Void in
            UIView.fh_extendsLayoutSubviews()
        })
        
    }
    
    /** Make sure that gradient background gets layout when view is get layout. */
    func fh_layoutSubviews() {
        
        self.fh_layoutSubviews()
        if (self.backgroundGradientLayer != nil) {
            self.backgroundGradientLayer?.frame = self.bounds
        }
    }
    
    /** Extend implementation of layoutSubviews. */
    class func fh_extendsLayoutSubviews() {
        
        let thisClass = self;
        
        // layoutSubviews selector, method, implementation
        let layoutSubviewsSEL = Selector("layoutSubviews");
        let layoutSubviewsMethod = class_getInstanceMethod(thisClass, layoutSubviewsSEL);
        let layoutSubviewsIMP = method_getImplementation(layoutSubviewsMethod);
        
        // fh_layoutSubviews selector, method, implementation
        let fh_layoutSubviewsSEL = Selector("fh_layoutSubviews");
        let fh_layoutSubviewsMethod = class_getInstanceMethod(thisClass, fh_layoutSubviewsSEL);
        let fh_layoutSubviewsIMP = method_getImplementation(fh_layoutSubviewsMethod);
        
        // Swizzle methods.
        let isAdded = class_addMethod(thisClass, layoutSubviewsSEL, fh_layoutSubviewsIMP, method_getTypeEncoding(fh_layoutSubviewsMethod));
        
        if (isAdded) {
            class_replaceMethod(thisClass, fh_layoutSubviewsSEL, layoutSubviewsIMP, method_getTypeEncoding(layoutSubviewsMethod));
        } else {
            method_exchangeImplementations(layoutSubviewsMethod, fh_layoutSubviewsMethod);
        }
        
        
    }
    
    
}