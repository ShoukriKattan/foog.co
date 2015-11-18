//
//  FHPickerViewController.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/7/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

class FHPickerViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource {
    
    /** UI Components */
    @IBOutlet weak var picker : UIPickerView?
    
    /** Picker Delegate */
    var delegate : FHPickerViewControllerDelegate?
    
    /** Selected Index. */
    var selectedIndex : Int = 0
    
    /** Data List */
    var dataList : [String] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set Selected Index in Picker View
        self.picker?.selectRow(self.selectedIndex, inComponent: 0, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataList.count
    }
    
    /** Populate Data in Picker. */
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.dataList[row]
    }
    
    /** Height of row in Picker. */
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
       return 44.0
    }

    @IBAction func doneClicked(sender: AnyObject) {
        var selectedIndex = self.picker!.selectedRowInComponent(0)
        
        self.delegate?.FHPickerViewControllerDidSelectDone!(self.dataList[selectedIndex])
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
        self.delegate?.FHPickerViewControllerDidCancel!()
    }
}

/** FHPicker View Controller Protocol */
@objc protocol FHPickerViewControllerDelegate {
    
    /** FHPicker did select an Item */
    optional func FHPickerViewControllerDidSelectDone(selectedItem :  String)
    
    /** FHPicker did select Cancel */
    optional func FHPickerViewControllerDidCancel()
}