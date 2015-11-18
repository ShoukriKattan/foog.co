//
//  LoadingMoreFooterView.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/25/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class LoadingMoreFooterView: UIView {

    /** IBOutlet to Loading More Indiactor View. */
    @IBOutlet weak var loadingMoreIndicator: UIActivityIndicatorView!

    //Container View
    @IBOutlet weak var containerView: UIView!
    
    /** Init Method. */
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        NSBundle.mainBundle().loadNibNamed("LoadingMoreFooterView", owner: self, options: nil)
        self.addSubview(self.containerView)
        
        /** Add Constrains. */
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        /** Add Top Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        /** Add Bottom Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        /** Add Leading Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        
        /** Add Trailing Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }
    
}
