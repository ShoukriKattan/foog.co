//
//  FHCoachIntroViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 6/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class CoachIntroViewController: UIViewController {
    
    /** IBOutlet to Coach ID label UI field. */
    @IBOutlet weak var coachIdLbl: UILabel!
    
    /** IBOutlet to into text view UI field. */
    @IBOutlet weak var intoTV: UITextView!
    
    
    /** Handler for click event on coach users button at navigation bar. */
    func next() {
        
        // Show coach view.
        LandingViewController.showCoachView(false)
        
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set default gradient background.
        self.view.addDefaultGradientBackground()
        
        // Set default gradient to Coach ID label.
        self.coachIdLbl.setFoogDefaultTitleGradientColor()
        
        // Add Foog logo to Navigation Bar.
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Foog_Icon.png"))
        
        /** Next Button. */
        var nextButton =  UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        nextButton!.frame = CGRectMake(0, 0, 40, 40)
        nextButton?.setTitle("Next", forState: UIControlState.Normal)
        nextButton?.titleLabel?.font = UIFont(name: UIUtilities.FontsName.helveticaFont, size: 18.0)
        nextButton?.titleLabel?.textColor = UIColor.whiteColor()
        nextButton?.backgroundColor = UIColor.clearColor()
        nextButton?.titleLabel?.textAlignment = NSTextAlignment.Center
        nextButton?.addTarget(self, action: "next", forControlEvents: UIControlEvents.TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextButton!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
