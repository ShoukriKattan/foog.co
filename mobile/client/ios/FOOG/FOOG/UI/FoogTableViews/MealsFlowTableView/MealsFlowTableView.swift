//
//  MealsFlowTableView.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/15/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class MealsFlowTableView: UIView, UITableViewDataSource, UITableViewDelegate {

    /** Container View. */
    @IBOutlet weak var containerView: UIView!
    
    /** IBOutlet to Meals table view. */
    @IBOutlet weak var tableView: UITableView!
    
    /** Main activity indicator in view's center UI field. */
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /** Loading More view. */
    var loadingMoreView: LoadingMoreFooterView!
    
    /** Two dimensional array for table's Data List where StreamItems grouped according creation day. */
    var dataList : [[AnyObject]] = [[]]
    
    /** Table Delegate. */
    var delegate : UserFlowTableViewDelegate?
    
    /** Is Loading More. */
    var isLoadingMore  = false
    
    /** Init Method. */
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
        /** Register table's section header view. */
        self.tableView.registerNib(UINib(nibName: MealsFlowTableSectionHeaderView.CellIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: MealsFlowTableSectionHeaderView.CellIdentifier)
        
        /** Register User Cell. */
        self.tableView.registerNib(UINib(nibName: MealTableViewCell.CellIdentifier, bundle: nil), forCellReuseIdentifier: MealTableViewCell.CellIdentifier)
        
        /** Setup Loading Indictor View. */
        self.loadingMoreView = LoadingMoreFooterView(frame: CGRectMake(0, 0, self.containerView.frame.size.width, 44.0))
        
    }
    
    private func commonInit() {
        NSBundle.mainBundle().loadNibNamed("MealsFlowTableView", owner: self, options: nil)
        self.addSubview(self.containerView)
        
        //Add Constrains
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.tableView.backgroundColor = UIColor.blackColor()
        
        /** Add Top Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        /** Add Bottom Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        /** Add Leading Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        
        /** Add Trailing Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        
        
        /**
        *  Add Constrains To Collection Table View
        **/
        /** Add Top Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        /** Add Bottom Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        /** Add Leading Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        
        /** Add Trailing Constrain. */
        self.addConstraint(NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /** Get Item Stream. */
        if (self.dataList.count > 0){
            var item: AnyObject  = self.dataList[indexPath.section][indexPath.row]
            
            /** If Item is Meal type. */
            if item.isKindOfClass(Meal) {
                self.delegate?.userFlowTableViewDidSelectMeal(item as! Meal)
            }
        }


        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    /** Number Of Sections In TableView. */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let x = self.dataList.count
        return self.dataList.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let x = self.dataList[section].count
        return self.dataList[section].count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //Get Data
        if self.dataList.count>0 {
            var item: AnyObject  = self.dataList[indexPath.section][indexPath.row]
            
            /** If Item is Meal type. */
            if item.isKindOfClass(Meal) {
                return (self.frame.size.width * (9.0/16.0))
            }else{
                return 0.0
            }
        }
        
        return 0.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        /** Get Item . */
        var item: AnyObject  = self.dataList[indexPath.section][indexPath.row]
        
        /** If Item is Meal type. */
        if item.isKindOfClass(Meal) {
            
            var meal  = item as! Meal
            
            var cell = tableView.dequeueReusableCellWithIdentifier(MealTableViewCell.CellIdentifier) as! MealTableViewCell!
            
            /** Set Selction Style to None. */
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            /** Load meal's photo. */
            cell.photoIV.image = nil
            cell.photoIV.file = meal.imageThumbnail
            cell.photoIV.loadInBackground()
            
            /** Show or hide reviewed remark. */
            if (User.isLoginUserCoach() == true) {
                if (meal.coachReviewedAt != nil) {
                    cell.reviewedMarkIV.hidden = true
                } else {
                    cell.reviewedMarkIV.hidden = false
                }
            }else{
                if (meal.userReviewedAt == nil && meal.coachReviewedAt != nil) {
                    cell.reviewedMarkIV.hidden = false
                }else {
                    cell.reviewedMarkIV.hidden = true
                }
            }
            
            // Set creation date UI label.
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy - hh:mm a"
            
            cell.creationDateLbl.text = dateFormatter.stringFromDate(meal.createdAt!)
            
            return cell
            
        }else if item.isKindOfClass(SummaryCard){
            //For Now Only
            var cell = tableView.dequeueReusableCellWithIdentifier("empty") as! UITableViewCell!
            
            if(cell == nil){
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "empty")
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
        
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(MealsFlowTableSectionHeaderView.CellIdentifier) as! MealsFlowTableSectionHeaderView
        
        if (self.dataList[section].count > 0) {
            if let dayDate = (self.dataList[section][0]).createdAt as NSDate? {
                headerView.titleLbl.text = FoogDateUtilities.formattedDateOrNearDayFromDate(dayDate)
            }else{
                
            }
        }
        headerView.contentView.backgroundColor = UIColor.blackColor()
        
        return headerView
        
    }
    
    /** Scroll View Did Scroll Delegate. */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= (scrollView.contentSize.height - self.frame.size.width * (9.0/16.0)) && self.isLoadingMore == false) {
            self.isLoadingMore = true
            self.delegate?.loadMore()
            
        }else if (self.isLoadingMore == false) {
            self.tableView.tableFooterView = nil
        }
    }
    
    func showLoadingMoreFooterView() {
        self.tableView.tableFooterView = self.loadingMoreView
        self.loadingMoreView.loadingMoreIndicator.startAnimating()
    }
    
    func hideLoadingMoreFooterView() {
        self.tableView.tableFooterView = nil
    }
}


/** User Flow Table View Protocol */
protocol UserFlowTableViewDelegate {
    
    /** User did select a Meal */
    func userFlowTableViewDidSelectMeal(meal: Meal)
    
    /** Load More Data */
    func loadMore()
}

