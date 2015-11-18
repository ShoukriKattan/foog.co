//
//  NoteViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/8/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController, UINavigationBarDelegate {
    
    // MARK: NoteViewController
    
    /** IBOutlet to note's text view UI field. */
    @IBOutlet weak var noteTV: UITextView!
    
    /** Navigation item for note view's navigation bar. */
    @IBOutlet private weak var barNavigationItem: UINavigationItem!
    
    /** Optional placeholder for the note. */
    private var notePlaceholder : String?
    
    /** Old note to be placed before this view appears. */
    var oldNote : String!
    
    /** Delegate to be invoked when user edit his note and click done button. */
    weak var delegate : NoteEditorViewDelegate?
    
    
    // Dissmiss thie view and pass user note to invoker.
    func xButtonClicked() {
        
        // Hide keyboard first.
        self.view.endEditing(true)
        
        // Invoke delegate it if is specified.
        if (self.delegate != nil) {
            self.delegate?.noteEditorDidEditNote(self.noteTV.text)
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func setNotePlaceholder(placeholder : String) {
        self.notePlaceholder = placeholder
        if let tv = self.noteTV {
            tv.setPlaceholder(placeholder)
        }
    }
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set focus to note's text view and show keyboard.
        self.noteTV.becomeFirstResponder()
        
        // Set placeholder for note text view.
        if let placeholder = self.notePlaceholder {
            self.noteTV.setPlaceholder(placeholder)
        }
        
        // Set done button at right side of navigation bar.
        let xBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("xButtonClicked"))
        
        self.barNavigationItem.rightBarButtonItem = xBtn
    }
    
    /** Set old note to note text view if it is set. */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.noteTV.text = self.oldNote
        
        // Set focus to note's text view and show keyboard.
        self.noteTV.becomeFirstResponder()
    }
    
    // MARK: UINavigationBarDelegate
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    
}

/** Protocol to invoke delegate of note editor when note is edited. */
protocol NoteEditorViewDelegate : class {
    
    /** This method is invoked when user edit his note and click done button. */
    func noteEditorDidEditNote(noteText : String)
    
}
