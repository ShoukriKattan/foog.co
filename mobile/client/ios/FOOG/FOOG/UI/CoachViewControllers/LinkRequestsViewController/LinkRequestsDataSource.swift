//
//  LinkRequestsDataSource.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

extension LinkRequestsViewController: UITableViewDataSource {
 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /** Get Item Stream. */
        if (self.requestsList.count > 0){
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    /** Number Of Sections In TableView. */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /** Number Of Rows in Section. */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.requestsList.count
    }
    
    /** Height of Header Section. */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    /** View of Header Section. */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 0.01))
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    /** Height of Footer Section. */
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    /** View of Footer Section. */
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 0.01))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
    
    /** Height Of Row. */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //Get Data
        if self.requestsList.count>0 {
            var item : AnyObject = self.requestsList[indexPath.row]
            if(item.isKindOfClass(CoachUserLink)){
                return 150.0
            }else{
                return 100.0
            }
        }
        return 0.0
    }
    
    /** Configure the Cell. */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(self.requestsList.count > 0) {
            
            var item : AnyObject = self.requestsList[indexPath.row]
            if(item.isKindOfClass(CoachUserLink)){
                
                /** Get User. */
                var coachUserLink  = item as! CoachUserLink
                
                /** Get Cell. */
                var cell = tableView.dequeueReusableCellWithIdentifier(LinkRequestViewCell.LinkRequestViewCellIdentifier) as! LinkRequestViewCell!
                cell.backgroundColor = UIColor.clearColor()
                
                /** Set Selction Style to None. */
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                /** Set User First and Last Name. */
                cell.userFullNameLabel.text = coachUserLink.user!.firstName + " " + coachUserLink.user!.lastName
                
                /** Add action To Reject Button. */
                cell.rejectButton.tag = indexPath.row
                cell.rejectButton.setTitle("Reject", forState: UIControlState.Normal)
                cell.rejectLoadingActivityIndicator.stopAnimating()
                cell.rejectButton.addTarget(self, action: "rejectRequest:", forControlEvents: UIControlEvents.TouchUpInside)
                
                /** Add action To Accept Button. */
                cell.acceptButton.tag = indexPath.row
                cell.acceptButton.setTitle("Accept", forState: UIControlState.Normal)
                cell.acceptLoadingActivityIndicator.stopAnimating()
                cell.acceptButton.addTarget(self, action: "acceptRequest:", forControlEvents: UIControlEvents.TouchUpInside)
                
                /** enable the Buttons. */
                cell.acceptButton.enabled = true
                cell.rejectButton.enabled = true
                
                return cell
            }else{
                /** No Data Returned From Server. */
                var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "empty")
                cell.backgroundColor = UIColor.clearColor()
                
                /** Configure Label. */
                cell.textLabel?.textAlignment = NSTextAlignment.Center
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 20.0)
                cell.textLabel?.text = FoogMessages.NoLinkRequestsPlaceholder
                
                return cell
            }
        }else{
            var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "empty")
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
    }

    
}
