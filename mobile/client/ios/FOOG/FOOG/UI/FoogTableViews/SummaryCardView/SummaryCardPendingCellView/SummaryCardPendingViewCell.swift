//
//  SummaryCardPendingViewCell.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/13/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import ParseUI

class SummaryCardPendingViewCell: UITableViewCell {

    /** UI Components */
    @IBOutlet weak var expandUserImageButton: UIButton!
    @IBOutlet weak var userImageView: PFImageView!
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var trackBodyFatButton: UIButton!
    @IBOutlet weak var separatorImageView: UIImageView!

    /** Pending Summary Card ViewCell Identifier */
    static let CellIdentifier : String = "SummaryCardPendingViewCellIdentifier"
    static let CellNibName : String = "SummaryCardPendingViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        /** Cell Background Color. */
        self.backgroundColor = UIColor.clearColor()
        
        /** Set Separator Inset. */
        self.separatorImageView.backgroundColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: self.contentView.bounds.size))
        
        /** Set Selection Style. */
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        /** Setup Track Button. */
        self.setupButton(self.trackBodyFatButton)
        
        /** Setup Take Photo Button. */
        self.setupButton(self.takePhotoButton)

        /** Set Fisrt Line Label Text Color. */
        self.firstLineLabel.textColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: self.contentView.bounds.size))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /** Setup Button. */
    func setupButton(button : UIButton){
        /** Set Border to Button. */
        button.layer.borderWidth = 2.0
        button.layer.borderColor =  UIColor(patternImage: UIUtilities.getGradientGreenImage(true, size: CGSizeMake(UIScreen.mainScreen().bounds.width - 60 , 50))).CGColor
        button.layer.cornerRadius = 15.0
        
        /** Set Text Color. */
        button.setTitleColor(UIColor(patternImage: UIUtilities.getGradientGreenImage(true, size: self.contentView.bounds.size)) , forState: UIControlState.Normal)
    }
    
    /** Populate Cell Data. */
    func populateData(summaryCard : SummaryCard ,  clientInfo: ClientInfo? ) {
    
        
        /** Set Fisrt Line Text. */
        self.firstLineLabel.text = String(format: FoogMessages.WeekSummaryPending, summaryCard.weekNumber)
        
        /** Set Second Line Text. */
        if var userInformation = clientInfo  {
              self.secondLineLabel.text = String(format: FoogMessages.WeekResultWillBePosted, userInformation.weekStartDay)
        }
        
        /** Set Take/ Retake Button Text according to Summary Card. */
        if var image = summaryCard.imageThumbnail {
            self.takePhotoButton.setTitle("Retake Photo", forState: UIControlState.Normal)
            
            /** Set User Image. */
            self.userImageView.image = nil
            self.userImageView.file = summaryCard.imageThumbnail
            self.userImageView.loadInBackground()
            
            /** Show Expand Button. */
            self.expandUserImageButton.hidden = false
            
        }else{
            self.takePhotoButton.setTitle("Take Photo", forState: UIControlState.Normal)
            
            /** hide Expand Button. */
            self.expandUserImageButton.hidden = true
        }
      
    }
}
