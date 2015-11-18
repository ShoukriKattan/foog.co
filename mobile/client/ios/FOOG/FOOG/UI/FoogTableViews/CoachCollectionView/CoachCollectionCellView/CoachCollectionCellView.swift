
//
//  CoachCollectionCellView.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/13/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import ParseUI

class CoachCollectionCellView: UICollectionViewCell {

    //User Image View
    @IBOutlet weak var userImage: PFImageView?
    
    //First Name Label
    @IBOutlet weak var firstNameLabel: UILabel?
    
    //Last Name Label
    @IBOutlet weak var lastNameLabel: UILabel?

    //Loading Indiactor For user Image
    @IBOutlet weak var loadingUserImageIndicator: UIActivityIndicatorView?
    
    //Notification Count
    @IBOutlet weak var NotificationCount : UILabel?
    
    //Notification View
    @IBOutlet weak var NotificationView : UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

}
