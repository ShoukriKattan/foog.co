//
//  FHChartView.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/12/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class FHChartView: UIView , JBLineChartViewDelegate, JBLineChartViewDataSource {

    /** JB Line Chart View. */
    var lineChartView : JBLineChartView!
    
    /** JB Grid Chart View. */
    var chartGridView : JBGridView!

    /** Chart Y Axis Data. */
    private var chartYAxisDataList : [Float] = []
    
    /** Chart X Axis Data. */
    private var chartXAxisDataList : [String] = []
    
    /** Init Method. */
    override init(frame: CGRect){
        super.init(frame: frame)

        /** Init View Components. */
        self.initViewComponents()
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        /** Init View Components. */
        self.initViewComponents()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /** Init View Components. */
        self.initViewComponents()
    }
    
    /** Init View Components. */
    func initViewComponents() {
        
        /** Init Chart Grid View. */
        self.chartGridView = JBGridView(frame: CGRectZero)
        self.chartGridView.backgroundColor = UIColor.clearColor()
        self.chartGridView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.chartGridView.sectionGridLineColor = UIColor(red: 171.0/255.0, green: 181.0/255.0, blue: 190.0/255.0, alpha: 1.0)
        self.chartGridView.gridLineColor = UIColor(red: 79.0/255.0, green: 109.0/255.0, blue: 150.0/255.0, alpha: 0.75)
        self.chartGridView.footerSeparatorColor = UIColor.clearColor()
        self.chartGridView.sectionData = NSMutableDictionary(capacity: 0)
        self.chartGridView.data = []
        self.addSubview(self.chartGridView)
        
        /** Init Chart View. */
        self.lineChartView = JBLineChartView(frame: CGRectZero)
        self.lineChartView.delegate = self
        self.lineChartView.dataSource = self
        self.lineChartView.headerPadding = 0.0
        self.lineChartView.minimumValue = 0.0
        self.lineChartView.maximumValue = 100.0
        self.lineChartView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.lineChartView.backgroundColor = UIColor.clearColor()
        self.lineChartView.state = JBChartViewState.Collapsed
        self.lineChartView.headerView = nil;
        self.lineChartView.footerView = nil;
        self.lineChartView.showsVerticalSelection = true
        self.lineChartView.showsVerticalSelection = true
        self.addSubview(self.lineChartView)
        
        /** Add Constrains. */
        self.addViewConstrains()
        
    }
    
    /** Add Constrains to View Components. */
    func addViewConstrains(){
        
        /** Add Top constrain to line chart view . */
        self.addConstraint(NSLayoutConstraint(item: self.lineChartView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        /** Add Bottom constrain to line chart view. */
        self.addConstraint(NSLayoutConstraint(item: self.lineChartView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -20.0))
        
        /** Add Leading constrain to line chart view. */
        self.addConstraint(NSLayoutConstraint(item: self.lineChartView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10))
        
        /** Add Trailing constrain to line chart view. */
        self.addConstraint(NSLayoutConstraint(item: self.lineChartView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: -10.0))
        
        /** Add Top constrain to grid chart view. */
        self.addConstraint(NSLayoutConstraint(item: self.chartGridView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        /** Add Bottom constrain to grid chart view.. */
        self.addConstraint(NSLayoutConstraint(item: self.chartGridView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        /** Add Leading constrain to grid chart view.. */
        self.addConstraint(NSLayoutConstraint(item: self.chartGridView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10))
        
        /** Add Trailing constrain to grid chart view.. */
        self.addConstraint(NSLayoutConstraint(item: self.chartGridView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: -10.0))
        
    }
    
    /** Return Number of Lines in Chart View. */
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }
    
    /** Return Number of Y values in Chart View. */
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(self.chartYAxisDataList.count)
    }
    
    /** Make Line smooth it's connections and end caps. */
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }
    
    /** Return Y value in Chart View. */
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        
        if(self.chartYAxisDataList.count > Int(horizontalIndex) && (self.chartYAxisDataList.isEmpty == false)){
            return CGFloat(self.chartYAxisDataList[Int(horizontalIndex)])
        }else{
            return 0.0
        }
    }
    
    /** Return Line Color in Cahrt View. */
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        if(lineIndex == 0){
            return UIColor(patternImage: UIUtilities.getGradientGreenImage(true, size: self.bounds.size))
        }else {
            return UIColor.whiteColor()
        }
        
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        if(lineIndex == 0){
            return UIColor(patternImage: UIUtilities.getGradientGreenImage(true, size: self.bounds.size))
        }else {
            return UIColor.clearColor()
        }
    }
    
    /** Return Line Width in Cahrt View. */
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        if(lineIndex == 0){
            return 6.0
        }else {
            return 0.0
        }
    }
    
    /** Return Line Style in Cahrt View. */
    func lineChartView(lineChartView: JBLineChartView!, lineStyleForLineAtLineIndex lineIndex: UInt) -> JBLineChartViewLineStyle {
        return JBLineChartViewLineStyle.Solid
    }
    
    func lineChartView(lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return false
    }
    
    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
        
    }
    
    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt, touchPoint: CGPoint) {
        
        var text = String(format: "%@ \n %.f", self.chartXAxisDataList[Int(horizontalIndex)],CGFloat(self.chartYAxisDataList[Int(horizontalIndex)]))
    
        self.lineChartView.setTooltipVisible(true, animated: true, atTouchPoint: touchPoint)
        self.lineChartView.setTooltipText(text)
    }
    
    func didDeselectLineInLineChartView(lineChartView: JBLineChartView!) {
        self.lineChartView.setTooltipVisible(false, animated: true)
    }
    
    func verticalSelectionWidthForLineChartView(lineChartView: JBLineChartView!) -> CGFloat {
        var width = ((self.bounds.width - (CGFloat(self.chartYAxisDataList.count))) / CGFloat(self.chartYAxisDataList.count))
        if(width > 14.0){
            return 14.0
        }else{
           return width
        }
        
    }
    
    /** Reload Data. */
    func reloadData(yAxisData : [Float], xAxisData : [String : AnyObject]){
        /** Set Y Axis Data. */
        self.chartYAxisDataList = yAxisData
        
        /** Set X Axis Data. */
        if(xAxisData.isEmpty ==  false){
            /** Set Data to Grid View. */
            if (xAxisData[GRIDVIEW_Data] != nil) {
                var xAxisValues : [String] = xAxisData[GRIDVIEW_Data] as! [String]
                if(xAxisValues.count == self.chartYAxisDataList.count){
                    self.chartGridView.data =  NSMutableArray(array: xAxisValues)
                }else{
                    self.chartGridView.data = NSMutableArray(array: self.chartYAxisDataList as [Float])
                }
            }else{
                self.chartGridView.data = NSMutableArray(array: self.chartYAxisDataList as [Float])
            }
            
            /** Set Section Data to Grid View. */
            if ((xAxisData[GRIDVIEW_SECTIONDATA]) != nil) {
                var sectionValues = xAxisData[GRIDVIEW_SECTIONDATA] as! [String : String]
                self.chartGridView.sectionData = NSMutableDictionary(dictionary: sectionValues, copyItems: true)
            }else{
                self.chartGridView.sectionData = NSMutableDictionary(capacity: 0)
            }
        }else{
           self.chartGridView.data = NSMutableArray(array: self.chartYAxisDataList)
           self.chartGridView.sectionData = NSMutableDictionary(capacity: 0)
        }
        
        /** Set X Axis Data. */
        self.chartXAxisDataList = NSArray(array:self.chartGridView.data) as! [String]
            
        /** Reload Chart. */
        self.lineChartView.state = JBChartViewState.Expanded
        
        self.lineChartView.reloadData()
        self.chartGridView.reloadData()
    }
}
