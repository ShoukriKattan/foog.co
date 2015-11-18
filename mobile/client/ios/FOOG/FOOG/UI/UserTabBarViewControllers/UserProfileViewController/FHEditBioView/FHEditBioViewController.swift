//
//  FHEditBioViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/5/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Parse

class FHEditBioViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - FHEditBioViewController
    
    /** IBOutlet to space from scroll view's bottom to view's bottom constraint. */
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    /** IBOutlet to week start UI text field which use a UIPicker as input view. */
    @IBOutlet weak var weekStartTF: UITextField!
    
    /** IBOutlet to height UI input text field. */
    @IBOutlet weak var heightTF: UITextField!
    
    /** IBOutlet to diet UI input text field. */
    @IBOutlet weak var dietTF: UITextField!
    
    /** IBOutlet to goal UI input text view. */
    @IBOutlet weak var goalsTV: UITextView!
    
    @IBOutlet weak var goalTVHeightConstraint: NSLayoutConstraint!
    
    /** Reference to associated user to this view. */
    var user : User!
    
    /** Reference to client info object of associated user. */
    var clientInfo : ClientInfo!
    
    /** Handler for click event on Save button at navigation bar. */
    func saveBtnClicked() {
        
        // Make sure that keyboard will not show up again.
        self.view.endEditing(true)
        
        // Show modal activity view.
        self.presentViewController(ModalActivityViewController.modalActivityViewController(self), animated: false, completion: nil)
        
        // Save all user's info to the back end.
        self.clientInfo.weekStartDay = self.weekStartTF.text
        self.clientInfo.height = self.heightTF.text
        self.clientInfo.diet = self.dietTF.text
        self.clientInfo.goals = self.goalsTV.text
        if let coach = user.coach {
          self.clientInfo.coach = coach
        }
        
        
        self.clientInfo.saveInBackgroundWithBlock { (success : Bool, error : NSError?) -> Void in
            
            if (success) {
                self.dismissViewControllerAnimated(false, completion: nil)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                
                // Hide modal activity view.
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
                    if (!success) {
                        // TODO: Handle any errors.
                        
                    }
                
                })
            }
            
        }
        
    }
    
    /** Handler for click event on Cancel button at navigation bar. */
    func cancelBtnClicked() {
        // Just pop this view to return to previous view without savinging any changes.
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /** Resize scroll view to keep all fields visible when keyboard show up. */
    func keyboardDidShow(notification : NSNotification) {
        let frameValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrame = frameValue.CGRectValue()
        
        self.scrollViewBottomConstraint.constant = keyboardFrame.height
    }
    
    /** Resize scroll view to fill the whole view when keyboard hides. */
    func keyboardWillHide() {
        self.scrollViewBottomConstraint.constant = 0
        self.weekStartTF.userInteractionEnabled = true
    }
    
    /** Update goals text view height to fit its content. */
    func goalsTextViewAutoFitContent(animated : Bool) {
        
        // When goal text view content change, make sure that text view auto extend to fit its content.
        let text = NSString(string: self.goalsTV.text)
        
        let contentInset = self.goalsTV.contentInset
        
        let frameSize = CGSizeMake(self.goalsTV.bounds.size.width - 10, CGFloat.infinity)
        let font = self.goalsTV.font
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.Center
        let newSize = text.boundingRectWithSize(frameSize, options: (NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading), attributes: [NSFontAttributeName : font, NSParagraphStyleAttributeName : style], context: NSStringDrawingContext())
        
        let newHeight = newSize.height < 35 ? 35 : ceil(newSize.height) + 17
        if newHeight != self.goalTVHeightConstraint.constant {
            
            if animated {
                self.view.layoutIfNeeded()
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.goalTVHeightConstraint.constant = newHeight
                    self.view.layoutIfNeeded()
                })
            } else {
                self.goalTVHeightConstraint.constant = newHeight
                self.view.layoutIfNeeded()
            }
            
        }
        
    }
    
    // MARK: - UITextFieldDelegate
    
    /** Move focus between different UI input text fields when return keyboard button is pressed. */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.heightTF) {
            self.dietTF.becomeFirstResponder()
        } else if (textField == self.dietTF) {
            self.goalsTV.becomeFirstResponder()
        }
        
        return true
    }
    
    // MARK: - UITextViewDelegate
    
    
    func textViewDidChange(textView: UITextView) {
        
        self.goalsTextViewAutoFitContent(true)
        
    }
    
    // MARK: - UIPickerViewDataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return WeekDays[row]
    }
    
    // MARK: - UIPickerViewDelegate
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Update selected day at week start text field.
        self.weekStartTF.text = WeekDays[row]
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set FOOG default gradient background.
        self.view.addDefaultGradientBackground()
        
        // Set view's title.
        self.title = "Edit Bio"
        
        // Set Goals text view place holder.
        self.goalsTV.setPlaceholder("Goals")
        
        // Add save and cancel buttons.
        let saveBtn = UIButton()
        saveBtn.setTitle("Save", forState: UIControlState.Normal)
        saveBtn.addTarget(self, action: Selector("saveBtnClicked"), forControlEvents: UIControlEvents.TouchUpInside)
        saveBtn.sizeToFit()
        saveBtn.setFoogDefaultTitleGradientColor()
        saveBtn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Highlighted)
        let saveBarItem = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.rightBarButtonItem = saveBarItem
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelBtnClicked"))
        
        // Set up Week start field to use picker view.
        let weekStartPicker = UIPickerView()
        weekStartPicker.dataSource = self
        weekStartPicker.delegate = self
        self.weekStartTF.inputView = weekStartPicker
        self.weekStartTF.tintColor = UIColor.clearColor()
        
        // Register for keyboard notifications to resize scroll view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardDidShow:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardWillHideNotification, object: nil)
        
        // Assign client's info the the UI.
        let weekStartDay = self.clientInfo.weekStartDay
        self.weekStartTF.text = weekStartDay
        self.heightTF.text = self.clientInfo.height
        self.dietTF.text = self.clientInfo.diet
        self.goalsTV.text = self.clientInfo.goals
        
//        self.goalsTextViewAutoFitContent(false)
        
        // Find index of client's week start day.
        let dayIndex = (WeekDays as NSArray).indexOfObject(weekStartDay)
        weekStartPicker.selectRow(dayIndex < 7 ? dayIndex : 0, inComponent: 0, animated: false)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
//        self.goalsTextViewAutoFitContent(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
