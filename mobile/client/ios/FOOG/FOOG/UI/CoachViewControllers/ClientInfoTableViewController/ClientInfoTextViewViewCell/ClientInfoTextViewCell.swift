//
//  ClientInfoTextViewCell.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/7/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class ClientInfoTextViewCell: UITableViewCell , UITextViewDelegate {

    /** UI Components */
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var separatorImageView: UIImageView!
    
    /** Cell Delegate */
    var delegate : ClientInfoTextViewCellDelegate?
    
    /** Client Info Text Filed ViewCell Identifier */
    static let CellIdentifier : String = "ClientInfoTextViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
   
        /** Cell Background Color. */
        self.backgroundColor = UIColor.clearColor()
        
        /** Set Separator Color. */
        self.separatorImageView.backgroundColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: CGSize(width: self.contentView.frame.size.width, height: 1)))
        
        /** Set Selection Style. */
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        self.textView.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
        self.textView.backgroundColor = UIColor.clearColor()
        
        self.textView.textContainerInset = UIEdgeInsetsMake(3,3,-3,-3)
        self.textView.delegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    /** Get Height of Text. */
    class func getGoalsTextHeight(text : String, width : Float) -> CGFloat {
        let newText : NSString = text
        
        var constraint : CGSize = CGSizeMake(CGFloat(width)-30, CGFloat.infinity);
        var font : UIFont! = UIFont(name: UIUtilities.FontsName.helveticaFont, size: 20.0)
        var style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.Center
        var expectedSize = newText.boundingRectWithSize(constraint, options:  (NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading) , attributes: [NSFontAttributeName : font, NSParagraphStyleAttributeName : style], context: NSStringDrawingContext())
        if (expectedSize.height < 40.0){
            return 40.0
        }else{
            return ceil(expectedSize.height+6.0)
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if(textView.text.isEmpty == true){
            textView.text = ClientInfoTableViewController.CellType.GoalsType.placeHolder
            textView.textColor =  UIColor(white: 1.0, alpha: 0.5)
        }
        
    }
    
    /** Text View Did End Editing. */
    func textViewDidEndEditing(textView: UITextView) {
        
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView) {

        if(textView.text.isEmpty == true){
            textView.text = ClientInfoTableViewController.CellType.GoalsType.placeHolder
            textView.textColor =  UIColor(white: 1.0, alpha: 0.5)
            textView.selectedRange = NSRange(location: 0, length: 0)
        }
        
        self.delegate?.clientInfoTextViewTextDidChanged!(textView)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if(text == "\n"){
            self.textView.resignFirstResponder()
            return false
        }
        
        if(textView.text == ClientInfoTableViewController.CellType.GoalsType.placeHolder ){
            if(text.isEmpty == false){
                textView.text = ""
                textView.textColor =  UIColor.whiteColor()
                textView.selectedRange = NSRange(location: 0, length: 0)
            }else{
                textView.selectedRange = NSRange(location: 0, length: 0)
                return false
            }
        }
        

        
        return true
    }
    
}

/** ClientInfo Text View Cell Protocol */
@objc protocol ClientInfoTextViewCellDelegate {
    
    /**ClientInfo TextView Text Did Changed */
    optional func clientInfoTextViewTextDidChanged(textView: UITextView)
    
}
