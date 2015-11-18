//
//  NotificationViewDataSource.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 7/16/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import Foundation

import UIKit

extension NotificationViewController: UITableViewDataSource {
   
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /** Get Notification. */
        if (self.notificationsList.count > 0){
            var item : AnyObject = self.notificationsList[indexPath.row]
            if(item.isKindOfClass(Notification)){
                
                /** Get Notification. */
                var notification  = item as! Notification
                self.handleSelectionOfNotificationCell(notification)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    /** Number Of Sections In TableView. */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /** Number Of Rows in Section. */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationsList.count
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
        if self.notificationsList.count>0 {
            return 100.0
        }
        return 0.0
    }
    
    /** Configure the Cell. */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(self.notificationsList.count > 0) {
            
            var item : AnyObject = self.notificationsList[indexPath.row]
            if(item.isKindOfClass(Notification)){
                
                /** Get Notification. */
                var notification  = item as! Notification
                
                /** Get Cell. */
                var cell = tableView.dequeueReusableCellWithIdentifier(NotificationViewCell.CellIdentifier) as! NotificationViewCell!
                cell.backgroundColor = UIColor.clearColor()
                
                /** Set Selction Style to None. */
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                /** Reset Image. */
                cell.notificationImageView.image = nil
                
                /** Populate Cell Data. */
                cell.populateData(notification)
                
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
                cell.textLabel?.text = FoogMessages.NoNotificationForCurrentCoach
                
                return cell
            }
        }else{
            var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "empty")
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
    }


}