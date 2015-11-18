//
//  ClientInfoViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/6/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class ClientInfoTableViewController: UITableViewController , FHPickerViewControllerDelegate {
    
    /** CoachModel. */
    var coachModel : CoachModel!
    
    /** Selected Link Request. */
    var selectedLinkRequest : CoachUserLink!
    
    /** Selected Client Info. */
    var selectedClientInfo : ClientInfo = ClientInfo(className: ClientInfo.parseClassName())
    
    /** Gradient Layer */
    var gradientLayer : CAGradientLayer = CAGradientLayer()
    
    /** Weekly start Day Picker View. */
    var weeklyStartDayPickerViewController : FHPickerViewController?

    /** Skip Bar Item . */
    var skipBarItem :  UIBarButtonItem?
    
    /** Save Bar Item . */
    var saveBarItem :  UIBarButtonItem?
    
    /** Loading Activity Indiator Bar Item. */
    var loadingInicatorBarItem : UIBarButtonItem?
    
    /** User Model. */
    var userModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Register Client Info Text Field Cell .*/
        self.tableView.registerNib(UINib(nibName:ClientInfoTextFieldViewCell.CellIdentifier, bundle: nil), forCellReuseIdentifier: ClientInfoTextFieldViewCell.CellIdentifier)
        
        /** Register Client Info Text View Cell .*/
        self.tableView.registerNib(UINib(nibName:ClientInfoTextViewCell.CellIdentifier, bundle: nil), forCellReuseIdentifier: ClientInfoTextViewCell.CellIdentifier)
        
        
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
        
        /** Init Coach Model. */
        self.coachModel = CoachModel(coach: PFUser.currentUser() as! User )
        
        //Set Table Footer View
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 1.0))
        self.tableView.separatorInset = UIEdgeInsetsZero
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        /** Set Navigation Title. */
        self.setNavigationTitle()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /** Set Navigation Title. */
    func setNavigationTitle() {
        if let selectedUser = selectedLinkRequest.user  {
            self.navigationItem.title = selectedUser.firstName + " " + selectedUser.lastName
        }else{
            self.navigationItem.title = ""
        }
    }
    
    /** Set Navigation Bar Items. */
    func setupNavgiationBarItems() {
        /** Skip Button. */
        var skipButon =  UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        skipButon!.frame = CGRectMake(0, 0, 40, 40)
        skipButon?.setTitle("Skip", forState: UIControlState.Normal)
        skipButon?.titleLabel?.font = UIFont(name: UIUtilities.FontsName.helveticaFont, size: 18.0)
        skipButon?.titleLabel?.textColor = UIColor.whiteColor()
        skipButon?.backgroundColor = UIColor.clearColor()
        skipButon?.titleLabel?.textAlignment = NSTextAlignment.Center
        skipButon?.addTarget(self, action: "skipView", forControlEvents: UIControlEvents.TouchUpInside)
        self.skipBarItem = UIBarButtonItem(customView: skipButon!)
        self.navigationItem.leftBarButtonItem = self.skipBarItem
        
        /** Save Button. */
        var saveButon =  UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        saveButon!.frame = CGRectMake(0, 0, 40, 40)
        saveButon?.setTitle("Next", forState: UIControlState.Normal)
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
    
    /** Handle Notifications.*/
    func handleNotifications(notification: NSNotification) {
        
        /** Save Client Info */
        if notification.name == UserModel.ModelNotifications.SaveClientInfoNotification {
            var notificationObject: ClientInfo  = notification.object as! ClientInfo

            //Check if No error Returned
            if let error = notification.userInfo {
                self.navigationItem.rightBarButtonItem?.enabled = true
                self.navigationItem.leftBarButtonItem?.enabled = true
                self.navigationItem.leftBarButtonItem = self.skipBarItem
                self.navigationItem.rightBarButtonItem = self.saveBarItem
                self.tableView.reloadData()
            }else{
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    /** FHPicker did select an Item */
    func FHPickerViewControllerDidSelectDone(selectedItem :  String){
        
        self.selectedClientInfo.weekStartDay = selectedItem
        
        self.tableView.reloadData()
        
        self.weeklyStartDayPickerViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    /** FHPicker did select Cancel */
    func FHPickerViewControllerDidCancel(){
       
        self.tableView.reloadData()
        
        self.weeklyStartDayPickerViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
    }
    
    /** Skip Action. */
    func skipView() {
        
        self.selectedClientInfo = ClientInfo(className: ClientInfo.parseClassName())
        self.selectedClientInfo.user = self.selectedLinkRequest.user!
        self.selectedClientInfo.coach = (PFUser.currentUser() as? User)!
        self.selectedClientInfo.weekStartDay = DayOfWeek.Monday.string()
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem = self.loadingInicatorBarItem
        
        /** Add it To Server. */
        self.userModel.selectedClientInfo = self.selectedClientInfo
        self.userModel.saveClientInfo()
        
    }
    
    /** Save client info Action. */
    func saveClientInfo() {
        
        /** Set selected user and Coach. */
        self.selectedClientInfo.user = self.selectedLinkRequest.user!
        self.selectedClientInfo.coach = (PFUser.currentUser() as? User)!
        if(self.selectedClientInfo.weekStartDay.isEmpty == true){
            self.selectedClientInfo.weekStartDay = DayOfWeek.Monday.string()
        }
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.navigationItem.rightBarButtonItem = self.loadingInicatorBarItem
        
        /** Add it To Server. */
        self.userModel.selectedClientInfo = self.selectedClientInfo
        self.userModel.saveClientInfo()
        
    }
}
