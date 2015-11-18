//
//  NotificationViewCell.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 7/16/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import ParseUI

import Parse

class NotificationViewCell: UITableViewCell {

    /** UI Components */
    @IBOutlet weak var notificationTextLabel: UILabel!
    @IBOutlet weak var notificationImageView: UIImageView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var notificationArrowImageView: UIImageView!
    @IBOutlet weak var separatorImageView: UIImageView!
    
    /** Cell Delegate */
    var delegate : NotificationViewCellDelegate?
    
    /** Notification ViewCell Identifier */
    static let CellIdentifier : String = "NotificationViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        /** Set Separator Color. */
        self.separatorImageView.backgroundColor = UIColor(patternImage: UIUtilities.getGradientGreenImage(false, size: CGSize(width: self.contentView.frame.size.width, height: 1)))
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /** Populate Cell Data. */
    func populateData(notification : Notification){
        
        /** Build Coach Name. */
        var coach = notification.coach
        var coachDisplayedName = ""
        if let firstName = coach?.firstName {
            coachDisplayedName = firstName
        }
        
        if let lastName = coach?.lastName {
            coachDisplayedName += " " + lastName
        }
        
        /** Build User Name. */
        var user = notification.user
        var userDisplayedName = ""
        if let firstName = user?.firstName {
            userDisplayedName = firstName
        }
        
        if let lastName = user?.lastName {
            userDisplayedName += " " + lastName
        }
        
        /** Coach Commented Notification. */
        if(notification.notificationType == Notification.NotificationType.CoachCommented){
           
            /** Set Meal Image. */
            self.setMealImage(notification)
            
            /** Show Notification Arrow. */
            self.notificationArrowImageView.hidden = false
            
            /** Set Text. */
            self.notificationTextLabel.text = String(format:"Coach %@ commented on your Meal", coachDisplayedName)
        }
        /** Coach Reviewed Meal Notification. */
        else if(notification.notificationType == Notification.NotificationType.CoachReviewedMeal){
            
            /** Set Meal Image. */
            self.setMealImage(notification)
            
            /** Show Notification Arrow. */
            self.notificationArrowImageView.hidden = false
            
            /** Set Text. */
            self.notificationTextLabel.text = "Your Coach has reviewed your meal. Check it out!"
        }
        /** Coach Review Meals Reminder Notification. */
        else if(notification.notificationType == Notification.NotificationType.CoachReviewMealsReminder){
            /** Set Image. */
            self.setReminderImage()
            
            /** Show Notification Arrow. */
            self.notificationArrowImageView.hidden = false
            
            /** Set Text. */
            self.notificationTextLabel.text = "You have non-reviewed meal for " + userDisplayedName
        }
        /** New Meals Posted Notification. */
        else if(notification.notificationType == Notification.NotificationType.NewMeal){
            
            /** Set Meal Image. */
            self.setMealImage(notification)
            
            /** Show Notification Arrow. */
            self.notificationArrowImageView.hidden = false
            
            /** Set Text. */
            self.notificationTextLabel.text = userDisplayedName + " submitted a new Meal."
        }
        /** Summary Available Coach Notification. */
        else if(notification.notificationType == Notification.NotificationType.SummaryAvailableCoach){
            /** Set Image. */
            self.setReminderImage()
            
            /** Show Notification Arrow. */
            self.notificationArrowImageView.hidden = true
            
            /** Set Text. */
            self.notificationTextLabel.text = userDisplayedName + " week summary is available."
        }
        /** Summary Available User Notification. */
        else if(notification.notificationType == Notification.NotificationType.SummaryAvailableUser){
            /** Set Image. */
            self.setReminderImage()
            
            /** Show Notification Arrow. */
            self.notificationArrowImageView.hidden = false
            
            /** Set Text. */
            self.notificationTextLabel.text = "Your week summary is available."
        }
        /** Summary Reminder End Of Week Notification. */
        else if(notification.notificationType == Notification.NotificationType.SummaryReminderEndOfWeek){
            /** Set Image. */
            self.setReminderImage()
            
            /** Show Notification Arrow. */
            self.notificationArrowImageView.hidden = false
            
            /** Set Text. */
            self.notificationTextLabel.text = String(format: "Tomorrow is end of week for %@. Snap a photo of your client!", userDisplayedName)
        }
        /** User Commented Notification. */
        else if(notification.notificationType == Notification.NotificationType.UserCommented){
            /** Set Meal Image. */
            self.setMealImage(notification)
            
            /** Show Notification Arrow. */
            self.notificationArrowImageView.hidden = false
            
            /** Set Text. */
            self.notificationTextLabel.text = String(format: "%@ commented on Meal.", userDisplayedName)
        }
        /** User Submitted No Meals Notification. */
        else if(notification.notificationType == Notification.NotificationType.UserSubmittedNoMeals){
            /** Set Image. */
            self.setReminderImage()
            
            /** Show Notification Arrow. */
            self.notificationArrowImageView.hidden = true
            
            /** Set Text. */
           self.notificationTextLabel.text = "You Didn't submit any meals for this week"
        }
    }
    
    /** Set Reminder Image. */
    func setReminderImage(){
        self.loadingActivityIndicator.hidden = true
        self.loadingActivityIndicator.stopAnimating()
        self.notificationImageView.image = UIImage(named:"Reminder_Image.png")
    }
    
    /** Set Meal Image. */
    func setMealImage(notification : Notification){
        self.loadingActivityIndicator.hidden = false
        self.loadingActivityIndicator.startAnimating()
        self.notificationImageView.image = nil
        var imageFile = notification.targetMeal?.imageThumbnail
        imageFile?.getDataInBackgroundWithBlock({ (imageData : NSData?, error : NSError?) -> Void in
            
            self.loadingActivityIndicator.stopAnimating()
            self.loadingActivityIndicator.hidden = true
            
            if(error != nil){
                
            }else{
                self.notificationImageView.image = UIImage(data: imageData!)
            }
        })
    }
}

/** Notification View Cell Protocol */
@objc protocol NotificationViewCellDelegate {
    
    
}
