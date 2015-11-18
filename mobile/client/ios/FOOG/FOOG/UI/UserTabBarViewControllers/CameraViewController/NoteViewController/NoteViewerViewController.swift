//
//  NoteViewerViewController.swift
//  FOOG
//
//  Created by Zafer Shaheen on 5/17/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

/** 
    NoteViewerViewController provide modal view to display provided note into pages.

    Use setNoteText(noteString) to specifiy a note after presenting this view controller on the stack.
*/
class NoteViewerViewController: UIViewController, NoteEditorViewDelegate {
    
    // MARK: NoteViewerViewController

    /** View UI field with actual preserved non-transparent rect for note view which contains other UI fields. */
    @IBOutlet private weak var noteView: UIView!
    
    /** Text view UI field used to display the note. */
    @IBOutlet private weak var noteTV: UITextView!
    
    /** Label UI field of note title. */
    @IBOutlet private weak var noteTitleLbl: UILabel!
    
    /** Edit Button UI field. */
    @IBOutlet private weak var editBtn: UIButton!
    
    /** Label UI field used to display current page number of displayed note. */
    @IBOutlet private weak var pageNumberLbl: UILabel!
    
    /** Note's previous page button UI field. */
    @IBOutlet private weak var previousBtn: UIButton!
    
    /** Note's next page button UI field. */
    @IBOutlet private weak var nextBtn: UIButton!
    
    /** Note title to be displayed.*/
    private var noteTitle : String?
    
    /** Note text to be displayed and splitted into pages. */
    private var noteText : String!
    
    /** Place holder when no note text is provided. */
    private var notePlaceholder : String?
    
    /** Array of each page's first character index. */
    private var pagesIndexes : [Int] = []
    
    /** Current visible page number. */
    private var currentPageNumber = 1
    
    /** 
        Boolean value indicates whether shown visible is editable or not.
        By default it is not editable.
        If editable, an edit button will be displayed next to note title.
    */
    var isNoteEditable = false {
        didSet {
            // Hide or show edit button according to new value of this boolean property.
            if (self.editBtn != nil) {
                self.editBtn.hidden = !isNoteEditable
            }
        }
    }
    
    /** Handler for click event of note's next page button. */
    @IBAction func nextBtnClicked(sender: AnyObject) {
        
        // Show next page.
        self.noteTV.text = self.noteText.substringFromIndex(advance(self.noteText.startIndex, self.pagesIndexes[self.currentPageNumber++])).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // Update page number label.
        self.pageNumberLbl.text = " \(self.currentPageNumber) / \(self.pagesIndexes.count)"
        
        // Enable previous button.
        self.previousBtn.enabled = true
        
        // Disable next button if last page is reached.
        self.nextBtn.enabled = self.currentPageNumber != self.pagesIndexes.count
        
        
    }
    
    /** Handler for click event of note's previousBtnClicked. */
    @IBAction func previousBtnClicked(sender: AnyObject) {
        
        // Show previous page.
        self.noteTV.text = self.noteText.substringFromIndex(advance(self.noteText.startIndex, self.pagesIndexes[--self.currentPageNumber - 1])).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // Update page number label.
        self.pageNumberLbl.text = " \(self.currentPageNumber) / \(self.pagesIndexes.count)"
        
        // Enable next button.
        self.nextBtn.enabled = true
        
        // Disable previous button if first page is reached.
        self.previousBtn.enabled = self.currentPageNumber != 1
        
    }
    
    /** Handler for click event of edit button. */
    @IBAction func editBtnClicked(sender: AnyObject) {
        
        // Present note editor with current note.
        let noteEditor = NoteViewController(nibName: "NoteViewController", bundle: nil)
        noteEditor.oldNote = self.noteText
        noteEditor.delegate = self
        self.presentViewController(noteEditor, animated: true, completion: nil)
        
    }
    
    /** Handler for click event of close button. */
    @IBAction func closeBtnClicked(sender: AnyObject) {
        // Just hide note viewer.
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func setNotePlaceholder(placeholder : String) {
        self.notePlaceholder = placeholder
        if let tv = self.noteTV {
            tv.setPlaceholder(placeholder)
        }
    }
    
    /** Set titles for this note view. */
    func setNoteTitle(title : String) {
        self.noteTitle = title
        if let noteLbl = self.noteTitleLbl {
            self.noteTitleLbl.text = title
        }
    }
    
    /** Split provided note text into pages according to view's size and display it. */
    func setNoteText(noteText : String) {
        
        // TODO: Consider text view container inset.
//        let xxx = self.noteTV.textContainerInset

        // Hold note text.
        self.noteText = noteText
        self.noteTV.text = self.noteText
        self.pagesIndexes = []
        
        // Hold charachter size according to text view font.
        let charSize = NSString(string: "A").sizeWithAttributes([NSFontAttributeName: self.noteTV.font])
        // Approximate Position of last visible word.
        // Position of last character would be affected by truncate mode
        let endPoint = CGPointMake(CGRectGetMaxX(self.noteTV.bounds) - charSize.width, CGRectGetMaxY(self.noteTV.bounds) - charSize.height)
        
        // Add first page index.
        self.pagesIndexes.append(0)
        
        // Add next pages indexes untile end of note text.
        var maxIndex = count(self.noteTV.text)
        var endPosition = self.noteTV.characterRangeAtPoint(endPoint)?.end
        if(endPosition == nil) {
            endPosition = self.noteTV.closestPositionToPoint(endPoint)
        }
        var endIndex = self.noteTV.offsetFromPosition(self.noteTV.beginningOfDocument, toPosition: endPosition!)
        while (endIndex < maxIndex) {
            // Hold next page index.
            self.pagesIndexes.append(self.pagesIndexes.last! + endIndex)
            
            // Check if next page exists.
            self.noteTV.text = self.noteTV.text.substringFromIndex(advance(self.noteTV.text.startIndex, endIndex))
            maxIndex = count(self.noteTV.text)
            endPosition = self.noteTV.characterRangeAtPoint(endPoint)?.end
            endIndex = self.noteTV.offsetFromPosition(self.noteTV.beginningOfDocument, toPosition: endPosition!)
        }
        
        // Reset text view to show first page.
        self.noteTV.text = self.noteText
        
        // Set proper Enable state of previous / next buttons.
        self.previousBtn.enabled = false
        self.nextBtn.enabled = self.pagesIndexes.count > 1 ? true : false
        
        // Update page number label.
        self.currentPageNumber = 1
        self.pageNumberLbl.text = " \(self.currentPageNumber) / \(self.pagesIndexes.count)"
        
    }
    
    // MARK: - NoteEditorViewDelegate
    
    /** Re-split edited note into pages. */
    func noteEditorDidEditNote(noteText: String) {
        self.setNoteText(noteText)
    }
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set note's title if it is specified.
        if let title = self.noteTitle {
            self.noteTitleLbl.text = title
        }
        
        // Set note's placeholder if it is specified.
        if let placeholder = self.notePlaceholder {
            self.noteTV.setPlaceholder(placeholder)
        }
        
        // Hide or show edit button according to this note is editable or not. 
        self.editBtn.hidden = !self.isNoteEditable
        
        // Set view's gradient background.
        self.noteView.addDefaultGradientBackground()

        // Set note's text view to truncate the note when it exceed view's size.
        self.noteTV.textContainer.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        // Set buttons images for disabled state.
        self.nextBtn.setImage(UIImage(named: "RightArrowDisabled.png"), forState: UIControlState.Disabled)
        self.previousBtn.setImage(UIImage(named: "LeftArrowDisabled.png"), forState: UIControlState.Disabled)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
