//
//  MealDetailsViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 5/20/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class MealDetailsViewController: UIViewController , UIGestureRecognizerDelegate, NoteEditorViewDelegate {
    
    /** Meal Image View. */
    @IBOutlet weak var mealImageView : UIImageView!
    
    /** Loading Meal Image indicator. */
    @IBOutlet weak var loadingImageIndicator: UIActivityIndicatorView!
    
    /** Actions Tool Bar . */
    @IBOutlet weak var actionsToolBar : UIToolbar?
    
    /** Back Bar Item. */
    var backBarItem : UIBarButtonItem?
    
    /** Save Changes Button. */
    var saveButton : UIButton?
    
    /** Save Activity Indicator Button. */
    var saveActivityIndicatorView : UIActivityIndicatorView?
    
    /** Cancel Changes Bar Item. */
    var cancelBarItem : UIBarButtonItem?
    
    /** User can Read Coach Note Bar Item or Coach can read user note Bar Item*/
    var leftBarItem : UIBarButtonItem?
    
    //Left Bar Item View
    var leftBarItemsView : UIView?
    
    /** Pin Meal Button. */
    var pinMealButton : UIButton?
    
    /** User Note Button. */
    var userNoteButton : UIButton?
    
    /** Add Coach Note Button. */
    var coachAddNoteButton : UIButton?
    
    /** Add Tick Mark Button. */
    var AddTickMarkButton : UIButton?
    
    /** Add Cross Mark Button. */
    var addCrossMarkButton : UIButton?
    
    /** Remove Mark Button. */
    var removeMarkButton : UIButton?
    
    /** Meal Date Bar Item. */
    var mealDateBarItem : UIBarButtonItem?
    
    /** Coach Note Bar Item. */
    var coachNoteBarItem : UIBarButtonItem?
    
    /** Selected Meal. */
    var selectedMeal : Meal?
    
    /** Meal Model . */
    var mealModel : MealModel?
    
    /** Marks Dic. */
    var marksDictionary : [String: [CGPoint]]!
    
    /** Marks Images Dic. */
    var marksImagesDictionary  : [String: UIImageView]!
    
    /** Coach NoteViewController to add Coach Notes. */
    var coachNoteViewController : NoteViewController!
    
    /** Meal instruction Label. */
    @IBOutlet weak var mealInstructionLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /** Add Bar Items To Navigation Bar according to Login Type. */
        self.setupNavigationBarItems()
        
        /** Add Back Button Bar Item. */
        self.backBarItem = UIBarButtonItem(image: UIImage(named: "Back_Button.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "backButtonPressed")
        self.navigationItem.leftBarButtonItem = backBarItem
        
        /** Load Meal Image. */
        self.loadMealImage()
        
        /** Setup Action Tab Bar. */
        self.setupAtionTabBar()
        
        /** Init Marks Dictionary. */
        self.marksDictionary = [String: [CGPoint]]()
        
        /** Init Marks Images Dictionary. */
        self.marksImagesDictionary =  [String: UIImageView]()
        
        /** init Meal Model. */
        self.mealModel = MealModel()
        self.mealModel?.selectedMeal = self.selectedMeal!
        
        /** Add Notifications */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: MealModel.ModelNotifications.GetListOfMarksNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleNotifications:", name: MealModel.ModelNotifications.saveListOfMarksNotification, object: nil)
        
        /** Get List Of Marks in Case of User Login or Coach is Already Reviewd the Meal. 
            We should remove else Later
        **/
        self.mealModel?.getMarksList()
        
        
        /** Set Meal Instruction Label Text. */
        self.mealInstructionLabel.text = "Mark unhealthy food / ingredients \n You may also drag marker across the picture"
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.coachNoteViewController == nil) {
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0);
            self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
            var snapshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            var fakeBackground = UIImageView(image: snapshot)
            self.view.subviews.map { $0.removeFromSuperview() }
            self.view.addSubview(fakeBackground)
            
            //Reset Navigation Bar
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "NavigationBarBg.png"), forBarPosition:UIBarPosition.Any , barMetrics: UIBarMetrics.Default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.translucent = false
        }
        
        /** Remove observers. */
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /** Handle Notifications.*/
    func handleNotifications(notification: NSNotification) {
        
        /** Get List Of Marks List Notification. */
        if notification.name == MealModel.ModelNotifications.GetListOfMarksNotification {
            var notificationModel: MealModel  = notification.object as! MealModel
            /** Check the same Meal Model */
            if (notificationModel.selectedMeal.objectId == self.mealModel?.selectedMeal.objectId) {
                self.mealModel?.marksList = notificationModel.marksList
                
                /** Populate Meal Marks */
                if var marksList = self.mealModel?.marksList {
                    self.populateMarksList(marksList)
                    if(User.isLoginUserCoach() == false && marksList.count > 0){
                        self.selectedMeal?.userReviewedAt = NSDate()
                        self.mealModel!.updateUserReviewedAt()
                    }
                }
            }
        }
            
        /** Save List Of Marks Notification. */
        else if notification.name == MealModel.ModelNotifications.saveListOfMarksNotification {
             var notificationModel: MealModel  = notification.object as! MealModel
            /** Check the same Coach Model */
            if (notificationModel.selectedMeal.objectId == self.mealModel?.selectedMeal.objectId) {
      
                self.saveActivityIndicatorView?.stopAnimating()
                self.showHideNavigationBarItemsForMarkers(false)
                self.setSelectedImage(self.coachAddNoteButton!)
                self.cancelBarItem?.enabled = true
                self.AddTickMarkButton?.enabled = true
                self.addCrossMarkButton?.enabled = true
                self.coachNoteBarItem?.enabled = true
                self.removeMarkButton?.enabled = true
            }
        }
        
    }

    /** Populate Marks List. */
    func populateMarksList(marksList : [MealMark]) {
        
        var imageWidth = Float(self.mealImageView!.bounds.width)
        var imageHeight = Float(self.mealImageView!.bounds.height)
        
        for mark in marksList {
            
            var markXPostion = mark.xLoaction * imageWidth
            var markYPostion = mark.yLoaction * imageHeight
            var markPostion = CGPoint(x: CGFloat(markXPostion), y: CGFloat(markYPostion))
            
            /** Calculate Image from Loaction. */
            var imageStartLocation = calculateImagefrom(markPostion)
            var markImage = UIImageView(frame: CGRectMake(imageStartLocation.x, imageStartLocation.y, 40.0, 40.0))
            var touchPoint = CGPoint(x: markPostion.x + 20, y: markPostion.y + 20)
            if mark.markType == MealMark.MealMarkType.Check {
                markImage.image = UIImage(named: "Tick_Mark.png")
                if var ticksList = self.marksDictionary[MealMark.MealMarkType.Check.rawValue] {
                    self.marksDictionary[MealMark.MealMarkType.Check.rawValue]?.append(markPostion)
                }else{
                    var newArray = [CGPoint]()
                    newArray.append(markPostion)
                    self.marksDictionary[MealMark.MealMarkType.Check.rawValue] = newArray
                }
            }else{
               markImage.image = UIImage(named: "Cross_Mark.png")
                
                if var crossesList = self.marksDictionary[MealMark.MealMarkType.Cross.rawValue] {
                    self.marksDictionary[MealMark.MealMarkType.Cross.rawValue]?.append(markPostion)
                }else{
                    var newArray = [CGPoint]()
                    newArray.append(markPostion)
                    self.marksDictionary[MealMark.MealMarkType.Cross.rawValue] = newArray
                }
            }
            
            /** Add Check Mark to Images List. */
            let imageKey = generateImageKey(imageStartLocation)
            self.marksImagesDictionary[imageKey] = markImage
            self.mealImageView?.addSubview(markImage)
        }
    }
    
    /** User did Press Back Button. */
    func backButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /** Get Meal Image from Server. */
    func loadMealImage() {
        
        /** Start Animating the Loading Indicator. */
        self.loadingImageIndicator.startAnimating()
        
        /** Load the image from Server. */
        if let mealImageData  =  self.selectedMeal?.imageOriginal {
            mealImageData.getDataInBackgroundWithBlock({ (imageData : NSData?, error : NSError? ) -> Void in
                
                if (error == nil) {
                    let image = UIImage(data: imageData!)
                    //image object implementation
                    self.mealImageView?.image = image
                }else{
                   self.mealImageView?.image = nil 
                }
                self.loadingImageIndicator?.stopAnimating()
                
                
                }, progressBlock: { (progressDone : CInt) -> Void in
                    if( Int(progressDone) == 1){
                        self.loadingImageIndicator?.stopAnimating()
                    }
                
            })
        }else{
            self.loadingImageIndicator?.stopAnimating()
            self.mealImageView?.image = nil
        }
        
        self.mealImageView?.contentMode = UIViewContentMode.ScaleToFill
        self.loadingImageIndicator.hidesWhenStopped = true
        self.mealImageView?.userInteractionEnabled = true
        var imageGesture = UITapGestureRecognizer(target: self, action: "coachDidTapOnMeal:")
        imageGesture.numberOfTapsRequired = 1
        imageGesture.delegate = self
        self.mealImageView?.addGestureRecognizer(imageGesture)
        
    }

    /** Setup Action Tab Bar. */
    func setupAtionTabBar() {
        
        /** Setup the main configuration for tabbar. */
        self.actionsToolBar?.setBackgroundImage(UIImage(named: "TabBar_Background.png"), forToolbarPosition:UIBarPosition.Any , barMetrics: UIBarMetrics.Default)
        self.actionsToolBar?.tintColor = UIColor.whiteColor()
        
        /** Set Tab Bar Items according to Login Type. */
        if(User.isLoginUserCoach() == true){
            
            let imageSize = CGSize(width: 30, height: 30)
            
            /** Add Coach Note Button. */
            self.coachAddNoteButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            self.coachAddNoteButton?.setImage(UIImage(named: "Add_Note_Button.png"), forState: UIControlState.Normal)
            self.coachAddNoteButton?.frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
            self.coachAddNoteButton?.addTarget(self, action: "coachDidSelectAddNote", forControlEvents: UIControlEvents.TouchUpInside)
            self.coachAddNoteButton?.tag = 0
            var coachAddNoteBarItem = UIBarButtonItem(customView: self.coachAddNoteButton!)
            
            /** Add Tick Mark Button. */
            self.AddTickMarkButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            self.AddTickMarkButton?.setImage(UIImage(named: "Add_Tick_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.AddTickMarkButton?.frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
            self.AddTickMarkButton?.addTarget(self, action: "coachDidSelectAddTickMark", forControlEvents: UIControlEvents.TouchUpInside)
            self.AddTickMarkButton?.tag = 1
            var AddTickMarkBarItem = UIBarButtonItem(customView: self.AddTickMarkButton!)
            
            /** Add Cross Mark Button. */
            self.addCrossMarkButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            self.addCrossMarkButton?.setImage(UIImage(named: "Add_Cross_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.addCrossMarkButton?.frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
            self.addCrossMarkButton?.addTarget(self, action: "coachDidSelectAddCrossMark", forControlEvents: UIControlEvents.TouchUpInside)
            self.addCrossMarkButton?.tag = 2
            var addCrossMarkBarItem = UIBarButtonItem(customView: self.addCrossMarkButton!)
 
            
            /** Add Remove Mark Button. */
            self.removeMarkButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            self.removeMarkButton?.setImage(UIImage(named: "Remove_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.removeMarkButton?.frame = CGRectMake(0, 0, imageSize.width, imageSize.height)
            self.removeMarkButton?.addTarget(self, action: "coachDidSelectRemoveMark", forControlEvents: UIControlEvents.TouchUpInside)
            self.removeMarkButton?.tag = 3
            var removeMarkBarItem = UIBarButtonItem(customView: self.removeMarkButton!)
            
            /** Add Flexible Space Bar Item. */
            var flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: "")
        
            /** Add Itmes To Tool Bar. */
            var itemsList : [UIBarButtonItem!] = [coachAddNoteBarItem,flexibleSpace,AddTickMarkBarItem,flexibleSpace,addCrossMarkBarItem,flexibleSpace,removeMarkBarItem]
            
            self.actionsToolBar?.setItems(itemsList, animated: true)

        
        }else{
            
            /** Meal Date TabBar Item. */
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy - hh:mm a"
            var mealCreationDate = dateFormatter.stringFromDate(self.selectedMeal!.createdAt!)
            self.mealDateBarItem = UIBarButtonItem(title: mealCreationDate, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
            
            /** Add Flexible Space Bar Item. */
            var flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: "")
            
            /** Add Coach Note TabBar Item. */
            self.coachNoteBarItem = UIBarButtonItem(image: UIImage(named: "User_Note_Button.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "userDidSelectReadCoachNote")
            
        
            /** Add Itmes To Tool Bar. */
            var itemsList : [UIBarButtonItem!] = [self.mealDateBarItem,flexibleSpace,self.coachNoteBarItem]
            self.actionsToolBar?.setItems(itemsList, animated: true)
            
        }
    }
    
    /** setup Navigation Bar Items. */
    func setupNavigationBarItems() {
        
        //In Case the Login User is Coach
        if(User.isLoginUserCoach() == true){
            
            /** Init Left Bar Items View. */
            self.leftBarItemsView = UIView(frame: CGRectMake(0, 0, 85, 40))
            self.leftBarItemsView?.backgroundColor = UIColor.clearColor()
            
            /** Add User Note Bar Item. */
            self.userNoteButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            self.userNoteButton?.setImage(UIImage(named: "User_Note_Button.png"), forState: UIControlState.Normal)
            self.userNoteButton?.frame = CGRectMake(45, 0, 40, 40)
            self.userNoteButton?.addTarget(self, action: "coachDidSelectUserNote", forControlEvents: UIControlEvents.TouchUpInside)
            
            /** Add Pin/UnPin Meal Bar Item. */
            self.pinMealButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            
            /** Upade the image.*/
            self.setPinMealImage()

            self.pinMealButton?.frame = CGRectMake(0, 0, 40, 40)
            self.pinMealButton?.addTarget(self, action: "coachDidSelectPinUnPinMeal", forControlEvents: UIControlEvents.TouchUpInside)
 

            self.leftBarItemsView?.addSubview(self.userNoteButton!)
            self.leftBarItemsView?.addSubview(self.pinMealButton!)
            
            /** Init Save Bar Item when the coach wants to add Tick/Cross Mark. */
            self.saveButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            self.saveButton?.frame = CGRectMake(40, 0, 40, 40)
            var colors = [UIColor(red: 97.0/255.0, green: 223.0/255.0, blue: 220.0/255.0, alpha: 1.0).CGColor,UIColor(red: 152.0/255.0, green: 236.0/255.0, blue: 150.0/255.0, alpha: 1.0).CGColor]
            var imageView = UIUtilities.getImageWithColor(UIColor.whiteColor(), size: CGSize(width: 40, height: 40))
            imageView = imageView.setLinearGradientColors(colors)
            self.saveButton?.setTitleColor(UIColor(patternImage: imageView), forState: UIControlState.Normal)
            self.saveButton?.setTitle("Save", forState: UIControlState.Normal)
            self.saveButton?.addTarget(self, action: "coachDidSaveMarkers", forControlEvents: UIControlEvents.TouchUpInside)
            self.leftBarItemsView?.addSubview(self.saveButton!)
            
            /** Init Save Indictor View when the coach click save to add Tick/Cross Marks to cloud. */
            self.saveActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            self.saveActivityIndicatorView?.frame = CGRectMake(40, 0, 40, 40)
            self.leftBarItemsView?.addSubview(self.saveActivityIndicatorView!)
            
            /** Cancel Bar Item. */
            self.cancelBarItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "coachDidDiscardChanges")
            
            /** Add Items to Navigation Bar. */
            self.showHideNavigationBarItemsForMarkers(false)
            
        }else{
           
            /** Init Left Bar Items View. */
            self.leftBarItemsView = UIView(frame: CGRectMake(0, 0, 40, 40))
            self.leftBarItemsView?.backgroundColor = UIColor.clearColor()
            
            /** Add User Note Bar Item. */
            self.userNoteButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            self.userNoteButton?.setImage(UIImage(named: "Add_Note_Button.png"), forState: UIControlState.Normal)
            self.userNoteButton?.frame = CGRectMake(0, 0, 40, 40)
            self.userNoteButton?.addTarget(self, action: "userDidSelectAddNote", forControlEvents: UIControlEvents.TouchUpInside)
            
             self.leftBarItemsView?.addSubview(self.userNoteButton!)
        }
        
        /** Add Fixed Space Bar Item. */
        var fixedSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: "")
        fixedSpace.width = -12
        self.navigationItem.rightBarButtonItems = [fixedSpace,UIBarButtonItem(customView: self.leftBarItemsView!)]
    }
    
    /** Calculate Image Center. */
    func calculateImagefrom(imageCenter :  CGPoint) -> CGPoint {
        //Add cehck Image To Meal Image
        var imageX : CGFloat = 0.0
        var imageY : CGFloat = 0.0
        //Set Image X
        if(imageCenter.x<20){
            imageX = 0
        }else if((self.mealImageView!.frame.size.width - imageCenter.x) < 20.0){
            imageX = self.mealImageView!.frame.size.width - 40
        }else{
            imageX = imageCenter.x - 20
        }
        
        //Set Image Y
        if(imageCenter.y<20){
            imageY = 0
        }else if((self.mealImageView!.frame.size.height - imageCenter.y) < 20.0){
            imageY = self.mealImageView!.frame.size.height - 40
        }else{
            imageY = imageCenter.y - 20
        }
        
        return CGPoint(x: imageX, y: imageY)
    }
    
    /** Generate Image Key. */
    func generateImageKey(imageStartLocation : CGPoint) -> String {
        return "x= \(imageStartLocation.x) y=\(imageStartLocation.y)"
    }
    
    /** Coach Did Tap on Meal Image. */
    func coachDidTapOnMeal(recognizer:UITapGestureRecognizer) {
        
        if (self.saveButton?.hidden == false){
           var touchPoint = recognizer.locationInView(self.mealImageView) as CGPoint
                if(self.AddTickMarkButton?.selected == true){
                    var isNotInterSectWithChecks = self.canAddNewMark(touchPoint)
                    if (isNotInterSectWithChecks == nil) {
                        
                        /** Calculate Image from Touch Loaction. */
                        var imageStartLocation = calculateImagefrom(touchPoint)
                        
                        if var ticksList = self.marksDictionary[MealMark.MealMarkType.Check.rawValue] {
                            self.marksDictionary[MealMark.MealMarkType.Check.rawValue]?.append(touchPoint)
                        }else{
                            var newArray = [CGPoint]()
                            newArray.append(touchPoint)
                            self.marksDictionary[MealMark.MealMarkType.Check.rawValue] = newArray
                        }
                        
                        var checkImage = UIImageView(frame: CGRectMake(imageStartLocation.x, imageStartLocation.y, 40.0, 40.0))
                        
                        checkImage.image = UIImage(named: "Tick_Mark.png")
                        self.mealImageView?.addSubview(checkImage)
                        
                        /** Add Check Mark to Images List. */
                        let imageKey = generateImageKey(imageStartLocation)
                        if var tickImagesList = self.marksImagesDictionary[imageKey] {
                            self.marksImagesDictionary[imageKey] = checkImage
                        }else{
                            self.marksImagesDictionary[imageKey] = checkImage
                        }
                    }

                }else if(self.addCrossMarkButton?.selected == true){
                    var isNotInterSectWithCrosses = self.canAddNewMark(touchPoint)
                    if (isNotInterSectWithCrosses == nil){
        
                        /** Calculate Image from Touch Loaction. */
                        var imageStartLocation = calculateImagefrom(touchPoint)
                        
                        if var crossesList = self.marksDictionary[MealMark.MealMarkType.Cross.rawValue] {
                            self.marksDictionary[MealMark.MealMarkType.Cross.rawValue]?.append(touchPoint)
                        }else{
                            var newArray = [CGPoint]()
                            newArray.append(touchPoint)
                            self.marksDictionary[MealMark.MealMarkType.Cross.rawValue] = newArray
                        }
                        
                        var crossImage = UIImageView(frame: CGRectMake(imageStartLocation.x, imageStartLocation.y, 40.0, 40.0))
                        
                        crossImage.image = UIImage(named: "Cross_Mark.png")
                        self.mealImageView?.addSubview(crossImage)
                        
                        /** Add Cross Mark to Images List. */
                        let imageKey = generateImageKey(imageStartLocation)
                        if var crossImagesList = self.marksImagesDictionary[imageKey] {
                            self.marksImagesDictionary[imageKey] = crossImage
                        }else{
                            self.marksImagesDictionary[imageKey] = crossImage
                        }
      
                    }
                }else if(self.removeMarkButton?.selected == true){
                    if var selectedMark = self.canAddNewMark(touchPoint) {
                        var imageStartLocation = calculateImagefrom(selectedMark.0)
                       let imageKey = generateImageKey(imageStartLocation)
                        if var selectedImage = self.marksImagesDictionary[imageKey] {
                            /** Remove it From List. */
                            selectedImage.removeFromSuperview()
                            self.marksImagesDictionary.removeValueForKey(imageKey)
                            if selectedMark.1 == MealMark.MealMarkType.Check.rawValue {
                                if var markIndex = find(self.marksDictionary[MealMark.MealMarkType.Check.rawValue]!, selectedMark.0) {
                                    self.marksDictionary[MealMark.MealMarkType.Check.rawValue]!.removeAtIndex(markIndex)
                                }
                            }else {
                                if var markIndex = find(self.marksDictionary[MealMark.MealMarkType.Cross.rawValue]!, selectedMark.0) {
                                    self.marksDictionary[MealMark.MealMarkType.Cross.rawValue]!.removeAtIndex(markIndex)
                                }
                            }
                        }
                    }
                }
            
        }
    }
    
    /** Can Add New Mark. */
    func canAddNewMark(location : CGPoint ) -> (CGPoint, String)? {
        
        /** Has Inertsections between two Points. */
        func hasIntersection(pointOne : CGPoint , pointTwo : CGPoint) -> Bool {
            var distance = sqrt(pow((abs(pointOne.x - pointTwo.x)),2) + pow(abs((pointOne.y - pointTwo.y)),2));
            
            if(distance < (40.0/2.0 + 40.0/2.0)){
                return true
            }
            return false
        }
        
        if var ticksList = self.marksDictionary[MealMark.MealMarkType.Check.rawValue] {
            for mark in self.marksDictionary[MealMark.MealMarkType.Check.rawValue]! as [CGPoint] {
                if(hasIntersection(location, mark) == true) {
                    return (mark, MealMark.MealMarkType.Check.rawValue)
                }
            }
        }
        
        if var crossList = self.marksDictionary[MealMark.MealMarkType.Cross.rawValue] {
            for mark in self.marksDictionary[MealMark.MealMarkType.Cross.rawValue]! as [CGPoint] {
                if(hasIntersection(location, mark) == true) {
                    return (mark, MealMark.MealMarkType.Cross.rawValue)
                }
            }
        }
        

        return nil
    }
    
    /** Coach Did Select Add Note. */
    func coachDidSelectAddNote() {
        self.setSelectedImage(self.coachAddNoteButton!)
        self.showHideNavigationBarItemsForMarkers(false)
    
        self.coachNoteViewController = nil
        self.coachNoteViewController = NoteViewController(nibName: "NoteViewController", bundle: nil)
        self.coachNoteViewController.setNotePlaceholder(FoogMessages.AddNoteToUserMeal)
        self.coachNoteViewController.oldNote = self.selectedMeal?.coachComments
        self.coachNoteViewController.delegate = self

        self.navigationController!.presentViewController(self.coachNoteViewController, animated: true, completion: nil)
    }
    
    /** User Did Select Add Note. */
    func userDidSelectAddNote() {
        
        self.coachNoteViewController = nil
        self.coachNoteViewController = NoteViewController(nibName: "NoteViewController", bundle: nil)
        self.coachNoteViewController.setNotePlaceholder(FoogMessages.AddNoteToYourMeal)
        self.coachNoteViewController.oldNote = self.selectedMeal?.userComments
        self.coachNoteViewController.delegate = self
        
        self.navigationController!.presentViewController(self.coachNoteViewController, animated: true, completion: nil)
    }
    
    /** This method is invoked when user edit his note and click done button. */
    func noteEditorDidEditNote(noteText : String) {
        
        //In Case the Login User is Coach
        if(User.isLoginUserCoach() == true){
            /** Update Coach Comments. */
            if(!(noteText == self.selectedMeal!.coachComments)){
                self.selectedMeal?.coachCommentedAt = NSDate()
                self.selectedMeal?.coachComments = noteText
                self.mealModel?.updateCoachNote()
            }
        }else{
            /** Update User Comments. */
            if(!(noteText == self.selectedMeal!.userComments)){
                self.selectedMeal?.userCommentedAt = NSDate()
                self.selectedMeal?.userComments = noteText
                self.mealModel?.updateUserNote()
            }
        }
        
    }
    
    /** Coach Did Select Discards Changes. */
    func coachDidDiscardChanges() {
        self.setSelectedImage(self.coachAddNoteButton!)
        self.showHideNavigationBarItemsForMarkers(false)
    }
    
    /** Coach Did Select Save Markers. */
    func coachDidSaveMarkers() {
        
        var checksList = [CGPoint]()
        if var tempList = self.marksDictionary[MealMark.MealMarkType.Check.rawValue] {
            checksList = tempList
        }
        
        var crossesList = [CGPoint]()
        if var tempList = self.marksDictionary[MealMark.MealMarkType.Cross.rawValue] {
            crossesList = tempList
        }
        
        /** Save Data To Cloud. */
        self.mealModel?.addMarksList(checksList, corssesList: crossesList, imageSize : self.mealImageView!.bounds.size)
        
        self.saveButton?.hidden = true
        self.saveActivityIndicatorView?.hidden = false
        self.saveActivityIndicatorView?.startAnimating()
        self.pinMealButton?.hidden = true
        self.userNoteButton?.hidden = true
        self.cancelBarItem?.enabled = false
        self.AddTickMarkButton?.enabled = false
        self.addCrossMarkButton?.enabled = false
        self.coachNoteBarItem?.enabled = false
        self.removeMarkButton?.enabled = false
        
    }
    
    /** Coach Did Select Add Tick Mark. */
    func coachDidSelectAddTickMark() {
        self.setSelectedImage(self.AddTickMarkButton!)

        self.showHideNavigationBarItemsForMarkers(true)

    }
    
    /** Coach Did Select Add Cross Mark. */
    func coachDidSelectAddCrossMark() {
        self.setSelectedImage(self.addCrossMarkButton!)
        
        self.showHideNavigationBarItemsForMarkers(true)

    }
    
    /** Coach Did Select Remove Mark. */
    func coachDidSelectRemoveMark() {
        self.setSelectedImage(self.removeMarkButton!)
        
        self.showHideNavigationBarItemsForMarkers(true)
    }
    
    /** User Did Select Read Coach Notes. */
    func userDidSelectReadCoachNote() {
        var noteViewerViewController  = NoteViewerViewController(nibName: "NoteViewerViewController" , bundle: nil)
        noteViewerViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        noteViewerViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.navigationController?.presentViewController(noteViewerViewController, animated: true, completion: nil)
        noteViewerViewController.setNoteTitle("Coach's Note")
        noteViewerViewController.setNotePlaceholder(FoogMessages.NoCoachNote)
        noteViewerViewController.setNoteText(self.selectedMeal!.coachComments)
        self.mealModel?.userDidReadCoachNote()
    }
    
    /** Show/Hide Naviagtion Bar Items for Adding/Removing Markers. */
    func showHideNavigationBarItemsForMarkers(show : Bool) {
        if(show == true){
            self.saveButton?.hidden = false
            self.pinMealButton?.hidden = true
            self.userNoteButton?.hidden = true
            self.navigationItem.leftBarButtonItem = self.cancelBarItem
        }else{
            self.saveActivityIndicatorView?.hidden = false
            self.saveButton?.hidden = true
            self.pinMealButton?.hidden = false
            self.userNoteButton?.hidden = false
            self.navigationItem.leftBarButtonItem = self.backBarItem
        }
        self.saveActivityIndicatorView?.hidden = true
    }
    
    /** Set Selected Image and reset the other Bar Items. */
    func setSelectedImage(selectedButtun : UIButton) {
        if(selectedButtun.tag == 0){
            self.mealInstructionLabel.hidden = true
            self.AddTickMarkButton?.setImage(UIImage(named: "Add_Tick_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.AddTickMarkButton?.selected = false
            self.addCrossMarkButton?.setImage(UIImage(named: "Add_Cross_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.addCrossMarkButton?.selected = false
           self.removeMarkButton?.setImage(UIImage(named: "Remove_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.removeMarkButton?.selected = false
        }else if(selectedButtun.tag == 1){
            self.mealInstructionLabel.hidden = false
            self.AddTickMarkButton?.setImage(UIImage(named: "Add_Tick_Mark_Selected.png"), forState: UIControlState.Normal)
            self.addCrossMarkButton?.setImage(UIImage(named: "Add_Cross_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.removeMarkButton?.setImage(UIImage(named: "Remove_Mark_NotSelected.png"), forState: UIControlState.Normal)
            
            //Set Selected
            self.AddTickMarkButton?.selected = true
            self.addCrossMarkButton?.selected = false
            self.removeMarkButton?.selected = false
        }else if(selectedButtun.tag == 2){
            self.mealInstructionLabel.hidden = false
            self.AddTickMarkButton?.setImage(UIImage(named: "Add_Tick_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.addCrossMarkButton?.setImage(UIImage(named: "Add_Cross_Mark_Selected.png"), forState: UIControlState.Normal)
            self.removeMarkButton?.setImage(UIImage(named: "Remove_Mark_NotSelected.png"), forState: UIControlState.Normal)
            
            //Set Selected
            self.AddTickMarkButton?.selected = false
            self.addCrossMarkButton?.selected = true
            self.removeMarkButton?.selected = false
            
        }else if(selectedButtun.tag == 3){
            self.mealInstructionLabel.hidden = false
            self.AddTickMarkButton?.setImage(UIImage(named: "Add_Tick_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.addCrossMarkButton?.setImage(UIImage(named: "Add_Cross_Mark_NotSelected.png"), forState: UIControlState.Normal)
            self.removeMarkButton?.setImage(UIImage(named: "Remove_Mark_Selected.png"), forState: UIControlState.Normal)
            
            //Set Selected
            self.AddTickMarkButton?.selected = false
            self.addCrossMarkButton?.selected = false
            self.removeMarkButton?.selected = true
        }
    }
    
    /** Coach Did Select User Note. */
    func coachDidSelectUserNote() {
        
        // Hold meal's user.
        let user = AppDelegate.getAppDelegate().userTabBarController?.selectedUser
        
        var noteViewerViewController  = NoteViewerViewController(nibName: "NoteViewerViewController" , bundle: nil)
        
        if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 {
            self.navigationController!.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        } else {
            noteViewerViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        }
        
        noteViewerViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        noteViewerViewController.setNoteTitle("\(user!.firstName)'s Note")
        self.navigationController?.presentViewController(noteViewerViewController, animated: true, completion: nil)
        
        if self.selectedMeal!.userComments == "" {
            noteViewerViewController.setNotePlaceholder(FoogMessages.NoUserNote)
        } else {
            noteViewerViewController.setNoteText(self.selectedMeal!.userComments)
        }
        self.mealModel?.coachDidReadUserNote()
    }
    
    /** Coach Did Select Pin/UnPin Meal. */
    func coachDidSelectPinUnPinMeal() {
    
        if(self.selectedMeal!.isPinned == true){
            self.selectedMeal?.isPinned = false
        }else{
            self.selectedMeal?.isPinned = true
        }
        
        /** Upade the image.*/
        self.setPinMealImage()
        
        /** Update the Meal. */
        self.mealModel?.pinAMeal()
    }
    
    func setPinMealImage(){
        if(self.selectedMeal!.isPinned == true){
            self.pinMealButton?.setImage(UIImage(named: "Pin_Meal_Selected.png"), forState: UIControlState.Normal)
        }else{
            self.pinMealButton?.setImage(UIImage(named: "Pin_Meal_NotSelected.png"), forState: UIControlState.Normal)
        }
    }
}
