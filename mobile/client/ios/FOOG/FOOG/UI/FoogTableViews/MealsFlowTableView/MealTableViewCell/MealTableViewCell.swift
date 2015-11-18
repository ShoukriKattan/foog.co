//
//  MealTableViewCell.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/11/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import ParseUI

class MealTableViewCell: UITableViewCell {
    
    // MARK: MealTableViewCell
    
    /** Creation date UI label. */
    @IBOutlet weak var creationDateLbl: UILabel!
    
    /** Item's photo UI image view. */
    @IBOutlet weak var photoIV: PFImageView!
    
    /** IBOutlet to not reviewed mark UI image view. */
    @IBOutlet weak var reviewedMarkIV: UIImageView!
    
    /** Meal Table View Cell Identifier */
    static let CellIdentifier : String = "MealTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
