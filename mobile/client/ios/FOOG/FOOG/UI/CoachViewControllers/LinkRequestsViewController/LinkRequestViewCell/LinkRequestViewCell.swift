//
//  LinkRequestViewCell.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/5/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class LinkRequestViewCell: UITableViewCell {

    /** UI Components */
    @IBOutlet weak var userFullNameLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    var acceptLoadingActivityIndicator: UIActivityIndicatorView!
    var rejectLoadingActivityIndicator: UIActivityIndicatorView!
    
    /** Link Request ViewCell Identifier */
    static let LinkRequestViewCellIdentifier : String = "LinkRequestViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /** setup Accept Button border and colors. */
        self.acceptButton.layer.borderWidth = 2.0
        self.acceptButton.layer.cornerRadius = 3.0
        self.acceptButton.titleLabel?.textAlignment = NSTextAlignment.Center
        self.acceptButton.backgroundColor = UIColor.clearColor()
        
        //Set Accept Button Title color
        self.acceptButton?.setTitleColor(UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: self.acceptButton.bounds.size)), forState: UIControlState.Normal)
        self.acceptButton.layer.borderColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: self.acceptButton.bounds.size)).CGColor

        /** setup Reject Button border and colors. */
        let grayColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0).CGColor
        self.rejectButton.layer.borderColor = grayColor ;
        self.rejectButton.layer.borderWidth = 2.0
        self.rejectButton.layer.cornerRadius = 3.0
        self.rejectButton.backgroundColor = UIColor.clearColor()
        self.rejectButton?.setTitleColor(UIColor(CGColor: grayColor), forState: UIControlState.Normal)
        self.rejectButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        /** Setup Reject Loading Indicator. */
        self.rejectLoadingActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        var indicatorHeight = self.rejectButton.frame.size.height / 2;
        var indicatorWidth = self.rejectButton.frame.size.width/2;
        self.rejectLoadingActivityIndicator.center = CGPointMake(indicatorWidth, indicatorHeight)
        self.rejectLoadingActivityIndicator.hidden = true
        self.rejectLoadingActivityIndicator.hidesWhenStopped = true
        self.rejectButton.addSubview(self.rejectLoadingActivityIndicator)
        
        /** Setup Accept Loading Indicator. */
        self.acceptLoadingActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self.acceptLoadingActivityIndicator.center = CGPointMake(indicatorWidth, indicatorHeight)
        self.acceptLoadingActivityIndicator.hidden = true
        self.acceptLoadingActivityIndicator.hidesWhenStopped = true
        self.acceptButton.addSubview(self.acceptLoadingActivityIndicator)
        
        /** Set Separator Inset. */
        self.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
