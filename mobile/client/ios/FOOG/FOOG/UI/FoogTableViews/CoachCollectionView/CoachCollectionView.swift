//
//  CoachCollectionView.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/13/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse


class CoachCollectionView: UIView {

    /** Coach Table View type. */
    enum CoachTableViewType {
        case ActiveType
        case InActiveType
    }
    
    /** Collection Table View */
    @IBOutlet weak var collectionTableView: UICollectionView!
    
    /** Container View  */
    @IBOutlet weak var containerView: UIView!
    
    /** Collection Cell Identifier */
    let collectionCellViewIdentifier : String = "CoachCollectionCellView"
    
    /** Data List */
    var dataList : [User] = []
    
    /** Gradient Layer */
    var gradientLayer : CAGradientLayer = CAGradientLayer()
    
    /** Table Type  */
    var tableType : CoachTableViewType = CoachTableViewType.ActiveType
    
    /** Table Delegate */
    var delegate : CoachCollectionViewDelegate?
    
    /** Init Method */
    override init(frame: CGRect){
        super.init(frame: frame)
        commonInit()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
        //Register User Cell
        self.collectionTableView.registerNib(UINib(nibName: collectionCellViewIdentifier, bundle: nil), forCellWithReuseIdentifier: collectionCellViewIdentifier)
    }
    
    private func commonInit() {
        NSBundle.mainBundle().loadNibNamed("CoachCollectionView", owner: self, options: nil)
        self.addSubview(self.containerView)
        
        //Add Constrains
        self.containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.collectionTableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        /**
         *  Add Constrains To Container View
        **/
        //Add Top Constrain
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        //Add Bottom Constrain
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        //Add Leading Constrain
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        
        //Add Trailing Constrain
        self.addConstraint(NSLayoutConstraint(item: self.containerView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        

        /**
        *  Add Constrains To Collection Table View
        **/
        //Add Top Constrain
        self.addConstraint(NSLayoutConstraint(item: self.collectionTableView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        //Add Bottom Constrain
        self.addConstraint(NSLayoutConstraint(item: self.collectionTableView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        //Add Leading Constrain
        self.addConstraint(NSLayoutConstraint(item: self.collectionTableView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        
        //Add Trailing Constrain
        self.addConstraint(NSLayoutConstraint(item: self.collectionTableView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        
        //Set Gradient Color
        self.gradientLayer = self.addDefaultGradientBackground()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
    }
    //1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //2
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    //3
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(collectionCellViewIdentifier, forIndexPath: indexPath) as! CoachCollectionCellView
        cell.backgroundColor = UIColor.clearColor()
        // Configure the cell
        
        var user : User = self.dataList[indexPath.row]
        
        
        //Set First Name
        if  let userFirstName = user.objectForKey(User.ParseKeys.FirstName) as? String {
            cell.firstNameLabel?.text = userFirstName
        }else{
            cell.firstNameLabel?.text = ""
        }
    
        //Set Last Name
        if  let userLastName = user.objectForKey(User.ParseKeys.LastName) as? String {
            cell.lastNameLabel?.text = userLastName
        }else{
            cell.lastNameLabel?.text = ""
        }
        

        //Set Notification Count
        if(user.unreviewedNotificationCount > 0){
            cell.NotificationView?.hidden = false
            cell.NotificationCount?.text = String(user.unreviewedNotificationCount)
        }else{
           cell.NotificationView?.hidden = true
        }
        
        
        //Set User Image
        if let userImageData  =  user.objectForKey(User.ParseKeys.Image) as? PFFile {
            var dataAvailable = true
            if(userImageData.isDataAvailable == false){
                cell.loadingUserImageIndicator?.startAnimating()
                cell.userImage?.image = UIUtilities.getImageWithColor(UIColor.lightGrayColor(), size: CGSizeMake(100, 100))
                cell.userImage = UIUtilities.makeCirclePFImageView(cell.userImage!)
                dataAvailable = false
            }
            
            cell.userImage?.file = userImageData
            cell.userImage?.loadInBackground({ (imageData : UIImage?, error : NSError?) -> Void in
                if (error == nil) {
                    //image object implementation
                    cell.userImage?.image = imageData
                    cell.userImage = UIUtilities.makeCirclePFImageView(cell.userImage!)
                    
                    //Set Gray Color
                    if self.tableType == CoachTableViewType.InActiveType {
                        cell.userImage = UIUtilities.convertImageToGrayScale(cell.userImage!)
                    }
                    cell.loadingUserImageIndicator?.stopAnimating()
                }else{
                    cell.loadingUserImageIndicator?.stopAnimating()
                }

                }, progressBlock: { (progressDone) -> Void in
                    if(progressDone == 1){
                        cell.loadingUserImageIndicator?.stopAnimating()
                    }
            })

        }else{
            cell.userImage?.image = UIUtilities.getImageWithColor(UIColor.lightGrayColor(), size: CGSizeMake(100, 100))
            cell.userImage = UIUtilities.makeCirclePFImageView(cell.userImage!)
            cell.loadingUserImageIndicator?.stopAnimating()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        if let selectedUser  = self.dataList[indexPath.row] as PFUser? {
            var firstName = selectedUser.objectForKey(User.ParseKeys.FirstName) as! String
            var user = selectedUser as! User
            self.delegate?.cooachCollectionViewDidSelectUser!(user)
        }
    }
}


/** Coach Collection View Protocol */
@objc protocol CoachCollectionViewDelegate {
    
    /** Coach did select a user */
    optional func cooachCollectionViewDidSelectUser(user :  User)
}


