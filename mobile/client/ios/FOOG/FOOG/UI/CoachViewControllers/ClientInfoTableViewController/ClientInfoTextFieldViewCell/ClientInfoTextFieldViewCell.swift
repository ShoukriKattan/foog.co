//
//  ClientInfoTextFieldViewCell.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/7/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class ClientInfoTextFieldViewCell: UITableViewCell , UITextFieldDelegate {

    /** UI Components */
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var separatorImageView: UIImageView!
    
    /** Cell Delegate */
    var delegate : ClientInfoTextFieldCellDelegate?
    
    /** Client Info Text Filed ViewCell Identifier */
    static let CellIdentifier : String = "ClientInfoTextFieldViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        /** Cell Background Color. */
        self.backgroundColor = UIColor.clearColor()
        
        /** Set Selection Style. */
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        /** Add Observer for each char changed. */
        self.textField.addTarget(self, action: "textFieldValueChanged:", forControlEvents: UIControlEvents.EditingChanged)
        
        /** Set Separator Color. */
        self.separatorImageView.backgroundColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: CGSize(width: self.contentView.frame.size.width, height: 1)))
            
        self.textField.delegate =  self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /** Set Place Holder. */
    func setTextFieldPlaceHolder(placeHolder : String){
        let attributesDictionary = [NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.5)]
        self.textField.attributedPlaceholder = NSAttributedString(string: placeHolder, attributes: attributesDictionary)
    }

    /** Text Field Value Changed. */
    func textFieldValueChanged(textField : UITextField) {
        self.delegate?.clientInfoTextFieldCellTextDidChanged!(textField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        var nextCellIndex : Int = 0
        if(textField.tag == ClientInfoTableViewController.CellType.HeightType.rawValue){
            nextCellIndex = ClientInfoTableViewController.CellType.WeightType.rawValue
        }else if(textField.tag == ClientInfoTableViewController.CellType.WeightType.rawValue){
            nextCellIndex = ClientInfoTableViewController.CellType.BodyFatType.rawValue
        }else if(textField.tag == ClientInfoTableViewController.CellType.BodyFatType.rawValue){
            nextCellIndex = ClientInfoTableViewController.CellType.DietType.rawValue
        }else if(textField.tag == ClientInfoTableViewController.CellType.DietType.rawValue){
            nextCellIndex = ClientInfoTableViewController.CellType.GoalsType.rawValue
            textField.resignFirstResponder()
        }
        
        self.delegate?.clientInfoTextFieldCellTextDidFinishedEditing!(nextCellIndex)
        
        /** Get Next Cell. */
        if(nextCellIndex < ClientInfoTableViewController.CellType.GoalsType.rawValue){
            return true
        }else{
            return false
        }
    }
    
}

/** ClientInfo TextField View Cell Protocol */
@objc protocol ClientInfoTextFieldCellDelegate {
    
    /**ClientInfo TextView Text Did Changed */
    optional func clientInfoTextFieldCellTextDidChanged(textField: UITextField)
    
    /**ClientInfo TextView Text Finished Editing */
    optional func clientInfoTextFieldCellTextDidFinishedEditing(nextFieldIndex : Int)
    
}
