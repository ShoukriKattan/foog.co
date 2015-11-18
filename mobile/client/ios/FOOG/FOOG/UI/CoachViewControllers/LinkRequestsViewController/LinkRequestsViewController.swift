//
//  LinkRequestsViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/5/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class LinkRequestsViewController: UIViewController, UITableViewDelegate {

    /** UI Components */
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    /** CoachModel. */
    var coachModel : CoachModel!
    
    /** Requests List. */
    var requestsList : [AnyObject] = []
    
    /** Gradient Layer */
    var gradientLayer : CAGradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set Color of Navigation Controller
        self.edgesForExtendedLayout = UIRectEdge.None
        self.extendedLayoutIncludesOpaqueBars = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.navigationBar.translucent = false
        
        /** Set Navigation Title. */
        self.navigationItem.title = "Link Requests"
        
        /** Set Left Bar Item. */
        self.setupLeftNavgiationBarItem()
        
        //Set Gradient Color
        self.gradientLayer = self.view.addDefaultGradientBackground()
        
        /** Register Notifications */
        self.registerNotifications()
        
        /** Init Coach Model. */
        self.coachModel = CoachModel(coach: PFUser.currentUser() as! User )
        
        /** Register Linked Cell .*/
        self.tableView.registerNib(UINib(nibName: LinkRequestViewCell.LinkRequestViewCellIdentifier, bundle: nil), forCellReuseIdentifier: LinkRequestViewCell.LinkRequestViewCellIdentifier)
        
        /** Get Pending Users. */
        self.tableView.hidden = true
        self.loadingActivityIndicator.startAnimating()
        self.coachModel.getPendingCoachUsers()
        
         /** Set Separator Color. */
        self.tableView.separatorColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: CGSizeMake(self.tableView.bounds.size.width, 1.0)))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }

    /** Set Left Bar Item. */
    func setupLeftNavgiationBarItem() {
        var cancelButon =  UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        cancelButon!.frame = CGRectMake(0, 0, 40, 40)
        cancelButon?.setImage(UIImage(named: "Cancel.png"), forState: UIControlState.Normal)
        cancelButon?.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        cancelButon?.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 5, -10)
        cancelButon?.contentMode = UIViewContentMode.Right
        cancelButon?.addTarget(self, action: "hideView", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButon!)
    }

    
    /** Register Notifications */
    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: CoachModel.ModelNotifications.GetListOfPendingUsersByCoachNotification, object: nil)
        
        /** Reject Notification. */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: CoachModel.ModelNotifications.RejectUserLinkNotification, object: nil)
        
        /** Accept Notification. */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: CoachModel.ModelNotifications.AcceptUserLinkNotification, object: nil)
    }
    
    /** Handle Notifications.*/
    func handleNotifications(notification: NSNotification) {
        
        /** Get Pending Users */
        if notification.name == CoachModel.ModelNotifications.GetListOfPendingUsersByCoachNotification {
            var notificationModel: CoachModel  = notification.object as! CoachModel
            /** Check the same Coach Model */
            if notificationModel.selectedCoach.id == self.coachModel?.selectedCoach.id {
                self.coachModel?.linkRequests = notificationModel.linkRequests
                
                if(self.coachModel!.linkRequests.count > 0){
                   self.requestsList = self.coachModel!.linkRequests
                }else{
                    self.requestsList = ["has empty data"]
                }
                
                self.tableView.reloadData()
                self.loadingActivityIndicator.stopAnimating()
                self.loadingActivityIndicator.hidden = true
                self.tableView.hidden = false
            }
        }
        /** Reject Notification */
        else if notification.name == CoachModel.ModelNotifications.RejectUserLinkNotification {
            var notificationCoachUserLink: CoachUserLink  = notification.object as! CoachUserLink
            
            for(var i: Int  = 0 ; i < self.requestsList.count ; i++) {
                var slecetedLingRequest = self.requestsList[i] as! CoachUserLink
                if(slecetedLingRequest.objectId == notificationCoachUserLink.objectId){
                    //Check if No error Returned
                    if let error = notification.userInfo {
                        self.tableView.reloadData()
                    }else{
                        self.tableView.beginUpdates()
                        self.requestsList.removeAtIndex(i)
                        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
                        self.tableView.endUpdates()
                        
                        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                        dispatch_after(delay, dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
                        
                    }
                }
            }
        }
        /** Accept Notification */
        else if notification.name == CoachModel.ModelNotifications.AcceptUserLinkNotification {
            var notificationCoachUserLink: CoachUserLink  = notification.object as! CoachUserLink
            
            for(var i: Int  = 0 ; i < self.requestsList.count ; i++) {
                var selecetedRequest = self.requestsList[i] as! CoachUserLink
                if(selecetedRequest.objectId == notificationCoachUserLink.objectId){
                    //Check if No error Returned
                    if let error = notification.userInfo {
                        self.tableView.reloadData()
                    }else{
                        var clientInfoViewController = ClientInfoTableViewController(nibName: "ClientInfoTableViewController", bundle: nil)
                        clientInfoViewController.selectedLinkRequest = selecetedRequest
                        self.navigationController?.pushViewController(clientInfoViewController, animated: true)
                        
                    }
                }
            }
        }
    }

    /** Hide Link Requests View. */
    func hideView(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /** Reject Request. */
    func rejectRequest(sender: UIButton!){
        if(sender.tag >= 0){
            var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! LinkRequestViewCell
            cell.rejectButton.setTitle("", forState: UIControlState.Normal)
            cell.acceptButton.enabled = false
            cell.rejectButton.enabled = false
            cell.rejectLoadingActivityIndicator.startAnimating()
            self.coachModel.rejectLinkRequest(self.requestsList[sender.tag] as! CoachUserLink)
        }
    }

    /** Accept Request. */
    func acceptRequest(sender: UIButton!){
        if(sender.tag >= 0){
            var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: sender.tag, inSection: 0)) as! LinkRequestViewCell
            cell.acceptButton.setTitle("", forState: UIControlState.Normal)
            cell.acceptLoadingActivityIndicator.startAnimating()
            cell.acceptButton.enabled = false
            cell.rejectButton.enabled = false
            self.coachModel.acceptLinkRequest(self.requestsList[sender.tag] as! CoachUserLink)
        }
    }
}
