//
//  SummaryCardView.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/9/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class SummaryCardView: UIView , UITableViewDataSource, UITableViewDelegate {
    
    
    /** Summary Card table view. */
    var tableView: UITableView!
    
    /** Main activity indicator in view's center UI field. */
    var tableLoadingIndicator: UIActivityIndicatorView!
    
    /** Loading More view. */
    var loadingMoreView: LoadingMoreFooterView!
    
    /** Summary Cards List. */
    var dataList : [SummaryCard] = []
    
    /** Is Loading More. */
    var isLoadingMore  = false
    
    /** Table Delegate. */
    var delegate : SummaryCardTableViewDelegate?
    
    /** Init Method */
    override init(frame: CGRect){
        super.init(frame: frame)

        /** Init Summary Cards Components. */
        self.initSummaryCardComponents()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     
        /** Init Summary Cards Components. */
        self.initSummaryCardComponents()
    }
    
    /** Init Table View. */
    func initTableView() {

        /** Init Table View. */
        self.tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.addSubview(self.tableView)
        
        /** Add Top Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        /** Add Bottom Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        /** Add Leading Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        
        /** Add Trailing Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }

    /** Init Loading Activity Indictaor. */
    func initLoadingActivityIndictor() {
        self.tableLoadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        self.tableLoadingIndicator.frame = CGRectZero
        self.tableLoadingIndicator.startAnimating()
        self.tableLoadingIndicator.hidesWhenStopped = true
        self.tableLoadingIndicator.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(self.tableLoadingIndicator)
        
        /** Add X Center Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableLoadingIndicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        
        /** Add Y Center Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableLoadingIndicator, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0))
    }
    
    /** Init Summary Cards Components. */
    func initSummaryCardComponents() {
        /** Init Table View. */
        self.initTableView()

        /** Init Loading Activity Indictaor. */
        self.initLoadingActivityIndictor()
        
        /** Register table's section header view. */
        self.tableView.registerNib(UINib(nibName: SummaryCardTableHeaderView.CellIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: SummaryCardTableHeaderView.CellIdentifier)
        
        /** Register summary card Cell. */
        self.tableView.registerNib(UINib(nibName: SummaryCardViewCell.CellNibName, bundle: nil), forCellReuseIdentifier: SummaryCardViewCell.CellIdentifier)
        
        /** Register pending summary card Cell. */
        self.tableView.registerNib(UINib(nibName: SummaryCardPendingViewCell.CellNibName, bundle: nil), forCellReuseIdentifier: SummaryCardPendingViewCell.CellIdentifier)
        
        /** Setup loading indictor view. */
        self.loadingMoreView = LoadingMoreFooterView(frame: CGRectZero)
        
        self.backgroundColor = UIColor.blackColor()
    }

    /** Number Of Sections In TableView. */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //Get Data
        if self.dataList.count>0 {
            /** Get Fisrt summary Card. */
            var summaryCard = self.dataList[0] as SummaryCard
            if(((summaryCard.summaryCreatedAt) == nil) && indexPath.section == 0){
                return 380.0
            }else if((PFUser.currentUser() as! User).isCoach == false) {
               return 362.0
            }else{
                return 428.0
            }
        }
        
        return 0.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /** Get Item . */
        if(self.dataList.count > 0) {
            var summaryCard  = self.dataList[indexPath.section] as SummaryCard
            
            if(summaryCard.summaryCreatedAt != nil){
                /** Get Summary Card Cell. */
               var cell = tableView.dequeueReusableCellWithIdentifier(SummaryCardViewCell.CellIdentifier) as! SummaryCardViewCell!
                
                /** Populate Data. */
                cell.segmentControl.tag = indexPath.section
                cell.segmentControl.addTarget(self, action: "userDidSelectSegment:", forControlEvents: UIControlEvents.ValueChanged)
                cell.populateData(summaryCard)
                
                return cell
            }else if((PFUser.currentUser() as! User).isCoach == true){
                /** Get Pendding Summary Card Cell. */
                var cell = tableView.dequeueReusableCellWithIdentifier(SummaryCardPendingViewCell.CellIdentifier) as! SummaryCardPendingViewCell!
                
                /** Populate Data. */
                cell.populateData(summaryCard, clientInfo: self.delegate?.getClientInfo())
                
                /** Add Target To Expand Button. */
                cell.expandUserImageButton.addTarget(self, action: "expandUserImage:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.expandUserImageButton.tag = indexPath.section
                cell.expandUserImageButton.hidden = false
                
                /** Add Target To Take Photo. */
                cell.takePhotoButton.addTarget(self, action: "takePhoto:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.takePhotoButton.tag = indexPath.section
                
                /** Add Target To Track User Info. */
                cell.trackBodyFatButton.addTarget(self, action: "trackUserInfo:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.trackBodyFatButton.tag = indexPath.section
                
                return cell
            }
        }

        //This Should not Happened
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "empty")
        cell.backgroundColor = UIColor.clearColor()
        return cell
        
    }
    
    /** Create and prepare views to table's headers. */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(SummaryCardTableHeaderView.CellIdentifier) as! SummaryCardTableHeaderView
        
        if (self.dataList.count > 0) {

            /** Get Week Index. */
            var summaryCard = self.dataList[section] as SummaryCard
            if(summaryCard.summaryCreatedAt != nil) {
                headerView.titleLabel.text = String(format: "Week %d", summaryCard.weekNumber)
                headerView.expandUserImageButton.addTarget(self, action: "expandUserImage:", forControlEvents: UIControlEvents.TouchUpInside)
                headerView.expandUserImageButton.tag = section
                headerView.expandUserImageButton.hidden = false
            }else{
                headerView.titleLabel.text = ""
                headerView.expandUserImageButton.hidden = true
            }

        }else{
          headerView.titleLabel.text = ""
        }
        
        headerView.contentView.backgroundColor = UIColor.blackColor()
        headerView.titleLabel.textColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(true, size: headerView.titleLabel.bounds.size))
        return headerView
        
    }
    
    /** Height of Header Section. */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (self.dataList.count > 0) {
            
            /** Get Week Index. */
            var summaryCard = self.dataList[section] as SummaryCard
            if(summaryCard.summaryCreatedAt != nil) {
               return 45.0
            }else{
                return 0.0
            }
        }
        return 0.0
    }
    
    /** Scroll View Did Scroll Delegate. */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height - self.frame.size.width * (9.0/16.0)) && self.isLoadingMore == false) {
            self.isLoadingMore = true
            self.delegate?.summaryCardTableViewLoadMore()
            
        }else if (self.isLoadingMore == false) {
            self.tableView.tableFooterView = nil
        }
    }
    
    func showLoadingMoreFooterView() {
        self.loadingMoreView.frame = CGRectMake(0, 0, self.frame.size.width, 44.0)
        self.tableView.tableFooterView = self.loadingMoreView
        self.loadingMoreView.loadingMoreIndicator.startAnimating()
    }
    
    func hideLoadingMoreFooterView() {
        self.tableView.tableFooterView = nil
    }
    
    /** User Did Select Expand User Image. */
    func expandUserImage(sender : UIButton) {
        if(self.dataList.count>0 && self.dataList.count > sender.tag){
           self.delegate?.summaryCardTableViewExpandUserImage(self.dataList[sender.tag])
        }
    }
    
    /** User did Select Take/Retake Photo. */
    func takePhoto(sender : UIButton) {
        if(self.dataList.count>0 && self.dataList.count > sender.tag){
            self.delegate?.summaryCardTableViewTakePhoto(self.dataList[sender.tag])
        }
    }
    
    /** User did Select Track User info. */
    func trackUserInfo(sender : UIButton) {
        if(self.dataList.count>0 && self.dataList.count > sender.tag){
            self.delegate?.summaryCardTableViewTrackUserInfo(self.dataList[sender.tag])
        }
    }
    
    /** User Did Select Cell Segment Control. */
    func userDidSelectSegment(sender: AnyObject) {
        var segmentedControl = sender as! UISegmentedControl;
        
        /** Get Summary Card. */
        var summaryCardIndex = segmentedControl.tag
        
        /** Get summary Card Cell. */
        if(self.dataList.count > summaryCardIndex){
            var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 0, inSection: summaryCardIndex)) as! SummaryCardViewCell
            
            var summaryCard = self.dataList[summaryCardIndex]
            cell.reloadChartData(summaryCard)
        }

    }
}

/** summary Card Table View Protocol */
protocol SummaryCardTableViewDelegate {
    
    /** User Did Select Expand User Image. */
    func summaryCardTableViewExpandUserImage(selectedCard : SummaryCard)
    
    /** User Did Select Take Photo.. */
    func summaryCardTableViewTakePhoto(selectedCard : SummaryCard)
    
    /** User Did Select Track User Info */
    func summaryCardTableViewTrackUserInfo(selectedCard : SummaryCard)
    
    /** Get Client Info.. */
    func getClientInfo() -> ClientInfo
    
    /** Load More Data */
    func summaryCardTableViewLoadMore()
}


