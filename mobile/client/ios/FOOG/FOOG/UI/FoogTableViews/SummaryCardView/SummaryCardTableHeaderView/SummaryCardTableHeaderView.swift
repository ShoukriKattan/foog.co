//
//  SummaryCardTableHeaderView.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/10/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class SummaryCardTableHeaderView: UITableViewHeaderFooterView {

    /** IBOutlet to header title label. */
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expandUserImageButton: UIButton!
    
    /** Summary card Table Section Header View Identifier. */
    static let CellIdentifier = "SummaryCardTableHeaderView"

}
