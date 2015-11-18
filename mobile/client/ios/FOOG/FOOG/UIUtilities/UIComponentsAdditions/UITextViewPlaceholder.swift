//
//  UITextViewPlaceholder.swift
//  FOOG
//
//  Created by Zafer Shaheen on 4/27/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit


/** Key for dynamic added property of placeholder. */
private var placeholderTextKey = "placeholderTextKey"

extension UITextView {
    
    /** Dynamic property for placeholder text. */
    private var placeholderText : String? {
        get {
            return objc_getAssociatedObject(self, &placeholderTextKey) as! String?
        }
        set (v) {
            objc_setAssociatedObject(self, &placeholderTextKey, v, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    /** Fix UITextView bug that reset font and text color when set text of unselectable text view. */
    func setTextAndKeepCurrentFont(text : String) {
        let isSelectable = self.selectable
        self.selectable = true
        self.text = text
        self.selectable = isSelectable
    }
    
    /** Set a placeholder for this text view. */
    func setPlaceholder(placeholder : String) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("textChanged"), name: UITextViewTextDidChangeNotification, object: nil)
        
        self.placeholderText = placeholder
        
    }
    
    /** Make sure to redraw text view when text changed. */
    func textChanged() {
        
        self.setNeedsDisplay()
        
    }
    
    /** Call super drawRect method, and if text view is empty it draw's placeholder. */
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        // If text view is empty, draw place holder.
        if (count(self.text) == 0 && self.placeholderText != nil) {
            
            let placeholderText = NSString(string: self.placeholderText!)
            
            var textAttributes = self.typingAttributes
            textAttributes[NSForegroundColorAttributeName] = UIColor.lightGrayColor()
            placeholderText.drawInRect(CGRectInset(rect, 5, 8), withAttributes: textAttributes)
            
        }
    }
    
}
