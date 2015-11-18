//
//  SummaryCardPenddingViewCell.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/9/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

import ParseUI

class SummaryCardViewCell: UITableViewCell {

    /** UI Components */
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var userImageView: PFImageView!
    @IBOutlet weak var mealsCountLabel: UILabel!
    @IBOutlet weak var checksCountLabel: UILabel!
    @IBOutlet weak var crossesCountLabel: UILabel!
    @IBOutlet weak var peakDayLabel: UILabel!
    @IBOutlet weak var efficiencyProgressView: UIView!
    @IBOutlet weak var efficiencyLabel: UILabel!
    @IBOutlet weak var separatorImageView: UIImageView!
    @IBOutlet weak var lineChartView : FHChartView!
    @IBOutlet weak var weigthCountLabel: UILabel!
    @IBOutlet weak var weigthLabel: UILabel!
    @IBOutlet weak var bodyFatCountLabel: UILabel!
    @IBOutlet weak var bodyFatLabel: UILabel!
    @IBOutlet weak var detailsViewHeightConstrain: NSLayoutConstraint!
    
    var efficiencySubProgressView: UIView!

    
    /** Label Type. */
    enum LabelType : Int  {
        case MealCount = 0
        case CheckCount
        case CrossCount
        case PeakDay
    }
    
    /** Summary Card ViewCell Identifier */
    static let CellIdentifier : String = "SummaryCardViewCellIdentifier"
    static let CellNibName : String = "SummaryCardViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        /** Cell Background Color. */
        self.backgroundColor = UIColor.clearColor()
        
        /** Set Separator Inset. */
        self.separatorImageView.backgroundColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: self.contentView.bounds.size))
        
        /** Set Selection Style. */
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        /** Setup Progress View. */
        self.setupProgressView()
        
        /** Setup Segment Control. */
        self.setupSegmentControlView()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    /** Setup Progress View. */
    func setupProgressView() {
     
        /** Set Tint Color. */
        self.efficiencySubProgressView = UIView(frame: CGRectZero)
        self.efficiencyProgressView.addSubview(self.efficiencySubProgressView)
        
    }
    
    /** Setup Segment Control. */
    func setupSegmentControlView() {
        
        /** Set Tint Color. */
        self.segmentControl.tintColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: self.segmentControl.bounds.size))
    
        /** Paragraph Style. */
        var attributtedStyle = NSMutableParagraphStyle()
        attributtedStyle.alignment = NSTextAlignment.Center
        
        /** Attributed Values. */
        var normaleAttributtedValues = [NSFontAttributeName : UIFont(name: UIUtilities.FontsName.helveticaFont, size: 14.0)!, NSForegroundColorAttributeName :  UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: self.segmentControl.bounds.size)),NSParagraphStyleAttributeName : attributtedStyle]
        
        var selectedAttributtedValues = [NSFontAttributeName : UIFont(name: UIUtilities.FontsName.helveticaFont, size: 14.0)!, NSForegroundColorAttributeName : UIColor.blackColor(),NSParagraphStyleAttributeName : attributtedStyle]
        
        self.segmentControl.setTitleTextAttributes(normaleAttributtedValues, forState: UIControlState.Normal)
        self.segmentControl.setTitleTextAttributes(selectedAttributtedValues, forState: UIControlState.Selected)
        self.segmentControl.setTitleTextAttributes(selectedAttributtedValues, forState: UIControlState.Highlighted)
    }
    
    
    /** Populate Cell Data. */
    func populateData(summaryCard : SummaryCard) {
        
        if((PFUser.currentUser() as! User).isCoach == true){
            self.detailsViewHeightConstrain.constant = 160.0
            
            //Set Weight
            self.weigthCountLabel.text =  String(format: "%d",summaryCard.weight)
            
            //Set Body Fat
            self.bodyFatCountLabel.text =  String(format: "%.1f%%",summaryCard.bodyFatPercent)
        }else{
            self.bodyFatCountLabel.hidden = true
            self.weigthCountLabel.hidden = true
            self.bodyFatLabel.hidden = true
            self.weigthLabel.hidden = true
            self.detailsViewHeightConstrain.constant = 105.0
        }
        
        /** Set User Image. */
        self.userImageView.image = nil
        self.userImageView.file = summaryCard.imageOriginal
        self.userImageView.loadInBackground()
        
        /** Set Meals Count. */
        self.mealsCountLabel.attributedText = self.buildAttributtedString(String(summaryCard.mealsCount), imageName: "Meal_Count.png", type: LabelType.MealCount)
        
        /** Set Checks Count. */
        self.checksCountLabel.attributedText = self.buildAttributtedString(String(summaryCard.checksCount), imageName: "Check_Count.png", type: LabelType.CheckCount)
        
        /** Set Crosses Count. */
        self.crossesCountLabel.attributedText = self.buildAttributtedString(String(summaryCard.crossesCount), imageName: "Cross_Count.png", type: LabelType.CrossCount)
        
        /**Set Peak Day. */
        self.peakDayLabel.attributedText = self.buildAttributtedString(summaryCard.peakDay, imageName: "Peak_Day_Image.png", type: LabelType.PeakDay)
        
        /**Set Efficiency Value . */
        var progressViewWidth = UIScreen.mainScreen().bounds.size.width - 80.0
        self.efficiencySubProgressView.frame = CGRectMake(0, 0, (progressViewWidth*CGFloat(summaryCard.efficiency)), self.efficiencyProgressView.frame.size.height)
        self.efficiencySubProgressView.backgroundColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(true, size: self.efficiencySubProgressView.bounds.size))
        self.efficiencyLabel.text = String(format: "%.1f",summaryCard.efficiency*100.0)
        
        /** Reload Chart Data from summary Card. */
        self.reloadChartData(summaryCard)

        
    }
    
    /** Build Attributted String with Image. */
    func buildAttributtedString(text : String , imageName: String, type : LabelType) -> NSAttributedString {
        
        var attributtedString = NSMutableAttributedString()
        
        /** Paragraph Style. */
        var attributtedStyle = NSMutableParagraphStyle()
        attributtedStyle.alignment = NSTextAlignment.Center
        attributtedStyle.paragraphSpacing = 2.0
        

        /** Image Attachment. */
        var textWithattachment = NSTextAttachment()
        var fontSize : CGFloat = 18.0
        var labelText = ""
        if(type == LabelType.PeakDay ){
            textWithattachment.image = UIImage(named: imageName)?.resizeImage(CGSize(width: 8, height: 16))
            textWithattachment.bounds = CGRectMake(0, -1, 8, 16)
            if(count(text) > 3){
                labelText = String(format: " %@", text.substringToIndex(advance(text.startIndex, 3)))
            }else{
                labelText = String(format: " %@", text)
            }
        }else if(type == LabelType.MealCount ){
            textWithattachment.image = UIImage(named: imageName)?.resizeImage(CGSize(width: 22 , height: 22))
            textWithattachment.bounds = CGRectMake(0, -5, 22, 22)
            labelText = String(format: " %@", text)
        }else if(type == LabelType.CheckCount ){
            textWithattachment.image = UIImage(named: imageName)?.resizeImage(CGSize(width: 15 , height: 15))
            labelText = String(format: " %@", text)
        }
        else if(type == LabelType.CrossCount ){
            textWithattachment.image = UIImage(named: imageName)?.resizeImage(CGSize(width: 13 , height: 13))
            labelText = String(format: " %@", text)
        }
        
        /** Attributed Values. */
        var attributtedValues = [NSFontAttributeName : UIFont(name: UIUtilities.FontsName.helveticaFont, size: fontSize)!, NSForegroundColorAttributeName : UIColor.whiteColor(),NSParagraphStyleAttributeName : attributtedStyle]
        
        var attributedImage = NSAttributedString(attachment: textWithattachment)
        attributtedString.appendAttributedString(attributedImage)
        
        /** Attributted String with Text. */
        var attributtedStringWithText = NSMutableAttributedString(string: labelText, attributes: attributtedValues)
        
        attributtedString.appendAttributedString(attributtedStringWithText)
        
        return attributtedString
    }
    
    
    /** Reload Chart Data From Summary Card. */
    func reloadChartData(summaryCard : SummaryCard){
        
        if(self.segmentControl.selectedSegmentIndex == 0){
            /** Set Chart Vlaues For Wekly Data */
            var xAxisData =  [String : AnyObject]()
            var weekDaysList = UIUtilities.getWeekDaysStartAt("Monday")
            var sectionData : [String: String] = [ "0": weekDaysList[0], "3": weekDaysList[3], "6" :weekDaysList[6]]
            xAxisData[GRIDVIEW_Data] = weekDaysList
            xAxisData[GRIDVIEW_SECTIONDATA] = sectionData
        
            self.lineChartView.reloadData(summaryCard.efficiencyDataWeekPoints, xAxisData: xAxisData )
        }else{
            var yAxisData : [Float] = []
            var xAxisData =  [String : AnyObject]()
            var sectionData = [String: String]()
            var xAxisWeekData : [String] = []
            var weekDaysList = UIUtilities.getWeekDaysStartAt("Monday")
            
            for(var i : Int = 0 ; i < summaryCard.efficiencyDataMonthPoints.count ; i++){
                var weekData = summaryCard.efficiencyDataMonthPoints[i] as [String : AnyObject]
                
                /** Add Y Values. */
                if(weekData["Data"] != nil ){
                    var newValues : [Float] = weekData["Data"] as! [Float]
                    yAxisData += newValues
                    xAxisWeekData += weekDaysList
                }
                
                /** Add Section Data. */
                if(weekData["weekName"] != nil ){
                    var newValue  = weekData["weekName"] as! String
                    sectionData[String(Int((xAxisWeekData.count - 1)))] = newValue
                }
            }
            
            xAxisData[GRIDVIEW_Data] = xAxisWeekData
            xAxisData[GRIDVIEW_SECTIONDATA] = sectionData
            
            self.lineChartView.reloadData(yAxisData, xAxisData: xAxisData )
        }

    }
    
}
