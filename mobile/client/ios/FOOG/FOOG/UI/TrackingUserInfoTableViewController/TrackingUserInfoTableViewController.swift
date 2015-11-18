//
//  TrackingUserInfoTableViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/18/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class TrackingUserInfoTableViewController: UITableViewController , ClientInfoTextFieldCellDelegate {
    
    /** Selected Client Info. */
    var selectedClientInfo : ClientInfo = ClientInfo(className: ClientInfo.parseClassName())
    
    /** Gradient Layer */
    var gradientLayer : CAGradientLayer = CAGradientLayer()
    
    /** Cancel Bar Item . */
    var cancelBarItem :  UIBarButtonItem?
    
    /** Save Bar Item . */
    var saveBarItem :  UIBarButtonItem?
    
    /** Loading Activity Indiator Bar Item. */
    var loadingInicatorBarItem : UIBarButtonItem?
    
    /** User Model. */
    var userModel : UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set Color of Navigation Controller
        self.edgesForExtendedLayout = UIRectEdge.None
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.translucent = false
        
        /** Set Navigation Title. */
        self.setNavigationTitle()
        
        /** Set Navigation Bar Items. */
        self.setupNavgiationBarItems()
        
        //Set Gradient Color
        self.gradientLayer = self.view.addDefaultGradientBackground()
        
        /** Register Notifications */
        self.registerNotifications()
        
        /** Register Client Info Text Field Cell .*/
        self.tableView.registerNib(UINib(nibName:ClientInfoTextFieldViewCell.CellIdentifier, bundle: nil), forCellReuseIdentifier: ClientInfoTextFieldViewCell.CellIdentifier)
        
        //Set Table Footer View
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 1.0))
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        /** Init User Model. */
        self.userModel  = UserModel()
        self.userModel.selectedClientInfo = self.selectedClientInfo
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    /** Set Navigation Title. */
    func setNavigationTitle() {
        self.navigationItem.title = "Track"
    }
    
    /** Set Navigation Bar Items. */
    func setupNavgiationBarItems() {
        /** Cancel Button. */
        var cancelButton =  UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        cancelButton!.frame = CGRectMake(0, 0, 60, 40)
        cancelButton?.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton?.titleLabel?.font = UIFont(name: UIUtilities.FontsName.helveticaFont, size: 18.0)
        cancelButton?.titleLabel?.textColor = UIColor.whiteColor()
        cancelButton?.backgroundColor = UIColor.clearColor()
        cancelButton?.titleLabel?.textAlignment = NSTextAlignment.Center
        cancelButton?.addTarget(self, action: "cancelView", forControlEvents: UIControlEvents.TouchUpInside)
        self.cancelBarItem = UIBarButtonItem(customView: cancelButton!)
        self.navigationItem.leftBarButtonItem = self.cancelBarItem
        
        /** Save Button. */
        var saveButon =  UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        saveButon!.frame = CGRectMake(0, 0, 40, 40)
        saveButon?.setTitle("Save", forState: UIControlState.Normal)
        saveButon?.titleLabel?.font = UIFont(name: UIUtilities.FontsName.helveticaFont, size: 18.0)
        saveButon?.setTitleColor(UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: saveButon!.frame.size)), forState: UIControlState.Normal)
        saveButon?.backgroundColor = UIColor.clearColor()
        saveButon?.titleLabel?.textAlignment = NSTextAlignment.Center
        saveButon?.addTarget(self, action: "saveClientInfo", forControlEvents: UIControlEvents.TouchUpInside)
        self.saveBarItem = UIBarButtonItem(customView: saveButon!)
        self.navigationItem.rightBarButtonItem = self.saveBarItem
        
        /** Setup Accept Loading Indicator. */
        var loadingInicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadingInicator?.frame = CGRectMake(0, 0, 40, 40)
        loadingInicator.startAnimating()
        loadingInicator!.hidesWhenStopped = true
        self.loadingInicatorBarItem = UIBarButtonItem(customView: loadingInicator!)
    }

    /** Register Notifications */
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: UserModel.ModelNotifications.SaveClientInfoNotification, object: nil)
    }
    
    /** Handel Notifications.*/
    func handleNotifications(notification: NSNotification) {
        
        /** Save Client Info */
        if notification.name == UserModel.ModelNotifications.SaveClientInfoNotification {
            var notificationObject: ClientInfo  = notification.object as! ClientInfo
            
            //Check if No error Returned
            if let error = notification.userInfo {
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.navigationItem.leftBarButtonItem?.enabled = true
                self.navigationItem.leftBarButtonItem = self.cancelBarItem
                self.navigationItem.rightBarButtonItem = self.saveBarItem
                self.tableView.reloadData()
            }else{
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    /** Number of Sections in the Table. */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    /** Number of rows in the section. */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    /** Height Of Row. */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    /** Height of Header Section. */
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    /** View of Header Section. */
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 1.0))
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    /** Height of Footer Section. */
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }
    
    /** View of Footer Section. */
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 3))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if(indexPath.row == 0){
            
            /** Get Cell. */
            var cell = tableView.dequeueReusableCellWithIdentifier(ClientInfoTextFieldViewCell.CellIdentifier) as! ClientInfoTextFieldViewCell
            
            /** Setup Cell Text Field. */
            cell.textField.tag = ClientInfoTableViewController.CellType.WeightType.rawValue
            cell.setTextFieldPlaceHolder( ClientInfoTableViewController.CellType.WeightType.placeHolder)
            cell.textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
            cell.textField.returnKeyType = UIReturnKeyType.Next
            cell.delegate  = self
            
            if(selectedClientInfo.weight.isEmpty == true){
                cell.textField.text = ""
            }else{
                cell.textField.text = selectedClientInfo.weight
            }
            
            return cell
            
        }
        else if(indexPath.row == 1){
            /** Get Cell. */
            var cell = tableView.dequeueReusableCellWithIdentifier(ClientInfoTextFieldViewCell.CellIdentifier) as! ClientInfoTextFieldViewCell
            
            /** Setup Cell Text Field. */
            cell.textField.tag = ClientInfoTableViewController.CellType.BodyFatType.rawValue
            cell.setTextFieldPlaceHolder( ClientInfoTableViewController.CellType.BodyFatType.placeHolder)
            cell.textField.returnKeyType = UIReturnKeyType.Done
            cell.textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
            cell.delegate  = self
            
            if(selectedClientInfo.bodyFatPercentage == 0.0){
                cell.textField.text = ""
            }else{
                cell.textField.text = String(format: "%.1f %", selectedClientInfo.bodyFatPercentage)
            }
            
            return cell
        }else{
            //This Should not Happened
            var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "empty")
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
    }



    /** Cancel Action. */
    func cancelView() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    /** Save client info Action. */
    func saveClientInfo() {
        
        /** Set selected user and Coach. */
        self.selectedClientInfo.user = AppDelegate.getAppDelegate().userTabBarController?.selectedUser
        self.selectedClientInfo.coach = (PFUser.currentUser() as? User)!
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.navigationItem.rightBarButtonItem = self.loadingInicatorBarItem
        
        /** Add it To Server. */
        self.userModel.selectedClientInfo = self.selectedClientInfo
        self.userModel.saveClientInfo()
        
    }



    /**ClientInfo TextView Text Finished Editing */
    func clientInfoTextFieldCellTextDidFinishedEditing(nextFieldIndex : Int)
    {
        /** Get Next Cell. */
        if(nextFieldIndex == ClientInfoTableViewController.CellType.BodyFatType.rawValue){
            var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! ClientInfoTextFieldViewCell
            cell.textField.becomeFirstResponder()
        }else{
            var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: 1, inSection: 0)) as! ClientInfoTextFieldViewCell
            cell.textField.resignFirstResponder()
        }
    }
    
    /**ClientInfo TextView Text Did Changed */
    func clientInfoTextFieldCellTextDidChanged(textField: UITextField){
        if(textField.tag == ClientInfoTableViewController.CellType.WeightType.rawValue){
            self.selectedClientInfo.weight = textField.text
        }else if(textField.tag == ClientInfoTableViewController.CellType.BodyFatType.rawValue){
            self.selectedClientInfo.bodyFatPercentage = (textField.text as NSString).floatValue
        }
    }




    
}
