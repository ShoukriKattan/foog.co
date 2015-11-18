//
//  ModalActivityViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/9/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class ModalActivityViewController: UIViewController {
    
    // MARK: ModalActivityViewController
    
    /** Returns instance of ModalActivityViewController to be presented over current context with default transition. */
    class func modalActivityViewController(context : UIViewController) -> ModalActivityViewController {
        let modalActivityViewController = ModalActivityViewController(nibName: "ModalActivityViewController", bundle: nil)
        if NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 {
            if let tabBarController = context.tabBarController {
                tabBarController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            } else if let navigationController = context.navigationController {
                navigationController.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
            }
        } else {
            modalActivityViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        }
        modalActivityViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        return modalActivityViewController
    }
    
    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
