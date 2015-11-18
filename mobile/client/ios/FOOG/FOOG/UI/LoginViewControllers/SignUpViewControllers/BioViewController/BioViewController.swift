//
//  BioViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/25/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class BioViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    // MARK: - BioViewController
    
    /** IBOutlet to mail scroll view. */
    @IBOutlet weak var scrollView: UIScrollView!
    
    /** IBOutlet to scroll view height contraint to be changed when keyboard show / hide. */
    @IBOutlet weak var scrollViewHeightConstraint: NSLayoutConstraint!
    
    /** UI constraint for camera button height. */
    @IBOutlet weak var cameraBtnHeightConstraint: NSLayoutConstraint!
    
    /** IBOutlet to camera / profile photo button UI field. */
    @IBOutlet weak var cameraBtn: UIButton!
    
    /** IBOutlet to first name input text UI text field. */
    @IBOutlet weak var firstNameTF: UITextField!
    
    /** IBOutlet to last name input text UI text field. */
    @IBOutlet weak var lastNameTF: UITextField!
    
    /** IBOutlet to date of birth input UI text field. */
    @IBOutlet weak var dobTF: UITextField!
    
    /** IBOutlet to name of GYM input UI text field. */
    @IBOutlet weak var nameOfGymTF: UITextField!
    
    /** IBOutlet to male button UI field. */
    @IBOutlet weak var maleBtn: UIButton!
    
    /** IBOutlet to female button UI field. */
    @IBOutlet weak var femaleBtn: UIButton!
    
    /** Reference to selected date of birth. */
    var dob : NSDate? = nil
    
    /** Reference to user's profile photo. */
    var profilePhoto : UIImage?
    
    /** Reference user instance associated to this bio view. */
    var user : User!
    
    
    
    /** 
        Handler for navigation bar done button. 
        Validate user input and register new user at backend.
    */

    func doneBtnClicked() {
        
        // Validate user input.
        let firstName = self.firstNameTF.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let lastName = self.lastNameTF.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let nameOfGym = self.nameOfGymTF.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (count(firstName) == 0) {
            FoogAlert.show(FoogMessages.EnterFirstName, context: self)
            return
        }
        
        if (count(lastName) == 0) {
            FoogAlert.show(FoogMessages.EnterLastName, context: self)
            return
        }
        
        if (self.user.isCoach == false && self.dob == nil) {
            FoogAlert.show(FoogMessages.EnterDateOfBirth, context: self)
            return
        }
        
        // Make sure that keyboard will not re-appear.
        self.view.endEditing(true)
        
        // Make sure that user set his profile picture.
        if (!self.user.isCoach && self.profilePhoto == nil) {
            FoogAlert.show(FoogMessages.SetProfilePhoto, context: self)
            return
        }
        
        // Display modal activity indicator.
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: true, completion: nil)
        
        // Save user bio at Parse backend.
        self.user.firstName = firstName
        self.user.lastName = lastName
        if (self.user.isCoach) {
            self.user.gymName = nameOfGym
        } else {
            self.user.dateOfBirth = self.dob!
            // Associate user profile photo to Parse.
            let resizedPhoto = self.profilePhoto?.resizedImageWithContentMode(UIViewContentMode.ScaleAspectFit, bounds: CGSizeMake(300, 300), interpolationQuality: kCGInterpolationHigh)
            let profilePhoto = PFFile(data: UIImageJPEGRepresentation(resizedPhoto, 0.9))
            self.user.image = profilePhoto
        }
        self.user.sex = self.maleBtn.selected ? SexType.Male : SexType.Female
        self.user.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            // Hide modal activity indicator.
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                // Check if any error occured.
                if (error != nil) {
                    FoogAlert.show(FoogMessages.ErrorUpdatingBio, context: self)
                    return
                } else {
                    // For coach, proceed to phone verification view.
                    if (self.user.isCoach) {
                        let phoneVerificationViewController = PhoneVerificationViewController(nibName: "PhoneVerificationViewController", bundle: nil)
                        self.navigationController?.pushViewController(phoneVerificationViewController, animated: true)
                    } else {
                        // For client user, proceed to synch with coach view.
                        let syncViewController = SyncViewController(nibName: "SyncViewController", bundle: nil)
                        let syncNavigationController = UINavigationController(rootViewController: syncViewController)
                        self.presentViewController(syncNavigationController, animated: true, completion: nil)
                    }
                }
            })
            
        }
        
    }

    /** Handler for click event on male button which must be marked as selected. */
    @IBAction func maleButtonPressed(sender: AnyObject) {
        self.maleBtn.selected = true
        self.femaleBtn.selected = false
    }
    
    /** Handler for click event on female button which must be marked as selected. */
    @IBAction func femaleButtonPressed(sender: AnyObject) {
        self.maleBtn.selected = false
        self.femaleBtn.selected = true
    }
    
    /** Handler for click event on camera button to set user profile photo. */
    @IBAction func cameraBtnClicked(sender: AnyObject) {
        
        if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 {
            
            var actionSheet = UIActionSheet()
            actionSheet.delegate = self
            actionSheet.addButtonWithTitle("Take Photo")
            actionSheet.addButtonWithTitle("Upload Photo")
            actionSheet.addButtonWithTitle("Cancel")
            actionSheet.cancelButtonIndex = 2
            actionSheet.showInView(self.view)
            
        } else {
            
            // Show action sheet with option to take photo by camera or select photo from photos.
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: { (alertAction : UIAlertAction!) -> Void in
                self.setProfilePhotoByCamera()
            }))
            actionSheet.addAction(UIAlertAction(title: "Upload Photo", style: UIAlertActionStyle.Default, handler: { (alertAction : UIAlertAction!) -> Void in
                self.setProfilePhotoByPhotos()
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(actionSheet, animated: true, completion: nil)
        }
        
    }
    
    /** Set user profile photo by taking a new photo by camera. */
    func setProfilePhotoByCamera() {
        
        // Do nothing if Camera source type is not available.
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            FoogAlert.show(FoogMessages.ErrorCameraIsNotAvailable, context: self)
        }
        
    }
    
    /** Set user profile photo by choose photo from iPhone photos, crop it and upload it. */
    func setProfilePhotoByPhotos() {
    
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    /** Resize scroll view to keep all fields visible when keyboard show up. */
    func keyboardDidShow() {
        self.scrollViewHeightConstraint.constant = self.view.bounds.height - 200
        // Make sure all input fields are visible for user more.
        if (!self.user.isCoach) {
            var scrollPosition = self.scrollView.contentSize.height - self.scrollViewHeightConstraint.constant
            self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollPosition), animated: true)
        }
    }
    
    /** Resize scroll view to fill the whole view when keyboard hides. */
    func keyboardWillHide() {
        self.scrollViewHeightConstraint.constant = self.view.bounds.height
    }
    
    /** Changed selected DOB when date picker value change. */
    func dobPickerValueChanged() {
        let datePicker = self.dobTF.inputView as! UIDatePicker
        self.dob = datePicker.date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        self.dobTF.text = dateFormatter.stringFromDate(self.dob!)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    /** Hold picked photo as profile photo. */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.profilePhoto = image
        self.cameraBtn.setImage(image, forState: UIControlState.Normal)
        
        self.cameraBtn.imageView!.layer.cornerRadius = self.cameraBtn.imageView!.frame.size.height/2
        self.cameraBtn.imageView!.layer.masksToBounds = true
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /** Just dismiss image picker when user cancel. */
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - UITextFieldDelegate
    
    /** Move focus between input text fields when keyboard enter button is pressed. */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if (textField == self.firstNameTF) {
            self.lastNameTF.becomeFirstResponder()
        } else if (textField == self.lastNameTF) {
            if (self.user.isCoach) {
                self.nameOfGymTF.becomeFirstResponder()
            } else {
                self.dobTF.becomeFirstResponder()
            }
        } else if (textField == self.nameOfGymTF) {
            self.doneBtnClicked()
        }
        
        return true
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            self.setProfilePhotoByCamera()
        } else if buttonIndex == 1 {
            self.setProfilePhotoByPhotos()
        }
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set FOOG default gradient background.
        self.view.addDefaultGradientBackground()
        
        // Set proper view's field according to user type if coach or user.
        if (self.user.isCoach) {
            // Hide camera button, Date of Birth text field and show name of gym text field.
            self.cameraBtnHeightConstraint.constant = 0
            self.dobTF.hidden = true
            self.nameOfGymTF.hidden = false
        } else {
            // Setup date picker for date of birth text field.
            let datePicker = UIDatePicker()
            datePicker.maximumDate = NSDate(timeIntervalSinceNow: (-10*12*30*24*60*60))
            datePicker.minimumDate = NSDate(timeIntervalSinceNow: (-130*12*30*24*60*60))
            datePicker.datePickerMode = UIDatePickerMode.Date
            datePicker.addTarget(self, action: Selector("dobPickerValueChanged"), forControlEvents: UIControlEvents.ValueChanged)
            self.dobTF.inputView = datePicker
        }
        
        // Set view's title and navigation bar button items.
        self.title = "My Bio"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: self.user.isCoach ? "NextButton.png" : "DoneButton.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: "doneBtnClicked")
        
        // Set proper selected / unselected backgrounds for male and female buttons.
        self.maleBtn.setBackgroundImage(UIImage(named: "SegmentLeftUnselected.png"), forState: UIControlState.Normal)
        self.maleBtn.setBackgroundImage(UIImage(named: "SegmentLeftSelected.png"), forState: UIControlState.Selected)
        self.maleBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.maleBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
        self.femaleBtn.setBackgroundImage(UIImage(named: "SegmentRightUnselected.png"), forState: UIControlState.Normal)
        self.femaleBtn.setBackgroundImage(UIImage(named: "SegmentRightSelected.png"), forState: UIControlState.Selected)
        self.femaleBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.femaleBtn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
        
        // Register for keyboard notifications to resize scroll view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardWillHideNotification, object: nil)
        
        // Hide keyboard when user scroll down.
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        
        // Hide / Show proper UI fields to match Coach / User mode.
        // Default is user mode.
        if (self.user.isCoach) {
            
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
