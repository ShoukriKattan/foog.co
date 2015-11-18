//
//  ClientInfoDataSouce.swift
//  FOOG
//
//  Created by Jayel Zaghmoutt on 6/6/15.
//  Copyright (c) 2015 FOOG. All rights reserved.
//

import UIKit

import Foundation

extension ClientInfoTableViewController: UITableViewDataSource , ClientInfoTextViewCellDelegate, ClientInfoTextFieldCellDelegate {
   
    /** Cell Type. */
    enum CellType : Int {
        case WeeklyStartDay = 0
        case HeightType
        case WeightType
        case BodyFatType
        case DietType
        case GoalsType
        
        
        static let allValues = [WeeklyStartDay,HeightType,WeightType,BodyFatType,DietType,GoalsType]
        
        var placeHolder:String {
            switch(self){
            case .HeightType :
                return "Height"
            case .WeightType:
                return "Weight in Ibs"
            case .BodyFatType:
                return "Body Fat Percentage"
            case .DietType:
                return "Special Diet (if any)"
            case .GoalsType:
                return "Goals"
            case .WeeklyStartDay:
                return "Select Program Start Day"
            }
        }
    }
    

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == CellType.WeeklyStartDay.rawValue) {
            self.weeklyStartDayPickerViewController = FHPickerViewController(nibName: "FHPickerViewController", bundle: nil)
            self.weeklyStartDayPickerViewController?.delegate = self
            self.weeklyStartDayPickerViewController?.dataList = DayOfWeek.strings
            self.weeklyStartDayPickerViewController?.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext

            if(self.selectedClientInfo.weekStartDay.isEmpty == false){
                var selectedDay = DayOfWeek(value: self.selectedClientInfo.weekStartDay)
                self.weeklyStartDayPickerViewController?.selectedIndex = selectedDay.rawValue
            }else{
                self.weeklyStartDayPickerViewController?.selectedIndex = 0
                
            }
            
            self.navigationController?.presentViewController(self.weeklyStartDayPickerViewController!, animated: true, completion: nil)
        }
    }
    
    /** Number Of Sections In TableView. */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /** Number Of Rows in Section. */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellType.allValues.count
    }
    
    /** Height of Header Section. */
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1.0
    }
    
    /** View of Header Section. */
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 1.0))
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    /** Height of Footer Section. */
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 3
    }
    
    /** View of Footer Section. */
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var footerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 3))
        footerView.backgroundColor = UIColor.clearColor()
        return footerView
    }
    
    /** Height Of Row. */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //Get Data
        if(indexPath.row == CellType.GoalsType.rawValue){
            var height  = ClientInfoTextViewCell.getGoalsTextHeight(self.selectedClientInfo.goals, width: Float(self.view.frame.size.width)) + 20.0
            return height
        }else{
            return 60.0
        }
    }
    
    /** Configure the Cell. */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
 
        if(indexPath.row == CellType.HeightType.rawValue){
            /** Get Cell. */
            var cell = tableView.dequeueReusableCellWithIdentifier(ClientInfoTextFieldViewCell.CellIdentifier) as! ClientInfoTextFieldViewCell
            
            /** Setup Cell Text Field. */
            cell.textField.tag = CellType.HeightType.rawValue
            cell.setTextFieldPlaceHolder( CellType.HeightType.placeHolder)
            cell.textField.returnKeyType = UIReturnKeyType.Next
            cell.textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
            cell.delegate  = self
            
            if(selectedClientInfo.height.isEmpty == false){
                cell.textField.text = selectedClientInfo.height
            }else{
                cell.textField.text = ""
            }
            
            return cell
        }
        else if(indexPath.row == CellType.WeightType.rawValue){
            
            /** Get Cell. */
            var cell = tableView.dequeueReusableCellWithIdentifier(ClientInfoTextFieldViewCell.CellIdentifier) as! ClientInfoTextFieldViewCell
            
            /** Setup Cell Text Field. */
            cell.textField.tag = CellType.WeightType.rawValue
            cell.setTextFieldPlaceHolder( CellType.WeightType.placeHolder)
            cell.textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
            cell.textField.returnKeyType = UIReturnKeyType.Next
            cell.delegate  = self
            
            if(selectedClientInfo.weight.isEmpty == true){
               cell.textField.text = ""
            }else{
                cell.textField.text = selectedClientInfo.weight
            }
            
            return cell
            
        }
        else if(indexPath.row == CellType.BodyFatType.rawValue){
            /** Get Cell. */
            var cell = tableView.dequeueReusableCellWithIdentifier(ClientInfoTextFieldViewCell.CellIdentifier) as! ClientInfoTextFieldViewCell
            
            /** Setup Cell Text Field. */
            cell.textField.tag = CellType.BodyFatType.rawValue
            cell.setTextFieldPlaceHolder( CellType.BodyFatType.placeHolder)
            cell.textField.returnKeyType = UIReturnKeyType.Next
            cell.textField.keyboardType = UIKeyboardType.NumbersAndPunctuation
            cell.delegate  = self
            
            if(selectedClientInfo.bodyFatPercentage == 0.0){
                cell.textField.text = ""
            }else{
                 cell.textField.text = String(format: "%.2f %", selectedClientInfo.bodyFatPercentage)
            }
        
            return cell
            
        }
        else if(indexPath.row == CellType.DietType.rawValue){
            /** Get Cell. */
            var cell = tableView.dequeueReusableCellWithIdentifier(ClientInfoTextFieldViewCell.CellIdentifier) as! ClientInfoTextFieldViewCell
            
            /** Setup Cell Text Field. */
            cell.textField.tag = CellType.DietType.rawValue
            cell.setTextFieldPlaceHolder( CellType.DietType.placeHolder)
            cell.textField.returnKeyType = UIReturnKeyType.Next
            cell.delegate  = self
            
            if(selectedClientInfo.diet.isEmpty == true){
                cell.textField.text = ""
            }else{
                cell.textField.text = selectedClientInfo.diet
            }
            
            return cell
        }
        else if(indexPath.row == CellType.WeeklyStartDay.rawValue){
            
            let cellIdentifier = "ProgramStartDayIdentifier"
            /** Get Cell. */
            var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
            
            if(cell == nil){
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier) as UITableViewCell
                
                /** Setup Cell Text Field. */
                cell?.textLabel?.textAlignment = NSTextAlignment.Center
                cell?.textLabel?.text = CellType.WeeklyStartDay.placeHolder
                cell?.textLabel?.textColor = UIColor(white: 1.0, alpha: 0.5)
                cell?.textLabel?.font = UIFont(name: UIUtilities.FontsName.helveticaFont, size: 20.0)
                cell?.backgroundColor = UIColor.clearColor()
                cell?.textLabel?.backgroundColor = UIColor.clearColor()
                cell?.selectionStyle = UITableViewCellSelectionStyle.None
                
                /** Set Separator Inset. */
                cell?.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20)
            }
            
            if(self.selectedClientInfo.weekStartDay.isEmpty == true){
                cell?.textLabel?.text = CellType.WeeklyStartDay.placeHolder
                cell?.textLabel?.textColor = UIColor(white: 1.0, alpha: 0.5)
            }else{
                cell?.textLabel?.textColor = UIColor(white: 1.0, alpha: 1.0)
                cell?.textLabel?.text = DayOfWeek(value: selectedClientInfo.weekStartDay).string()
            }
            
            return cell!
        }else{
            /** Get Cell. */
            var cell = tableView.dequeueReusableCellWithIdentifier(ClientInfoTextViewCell.CellIdentifier) as! ClientInfoTextViewCell
            
            /** Setup Cell Text View. */
            cell.textView.tag = CellType.GoalsType.rawValue
            cell.textView.returnKeyType = UIReturnKeyType.Done
            cell.delegate  = self
            
            if(selectedClientInfo.goals.isEmpty == true){
                cell.textView.text = CellType.GoalsType.placeHolder
                cell.textView.textColor =  UIColor(white: 1.0, alpha: 0.5)
            }else{
                cell.textView.text = selectedClientInfo.goals
                cell.textView.textColor =  UIColor.whiteColor()
            }
            
            return cell
        }
    }
    

    /**ClientInfo TextView Text Did Changed */
    func clientInfoTextViewTextDidChanged(textView: UITextView){
        if(textView.text == CellType.GoalsType.placeHolder) {
           self.selectedClientInfo.goals = ""
        }else{
            self.selectedClientInfo.goals = textView.text 
        }
    
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: CellType.GoalsType.rawValue, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }


    /**ClientInfo TextView Text Finished Editing */
    func clientInfoTextFieldCellTextDidFinishedEditing(nextFieldIndex : Int)
    {
        /** Get Next Cell. */
        if(nextFieldIndex < CellType.GoalsType.rawValue){
            var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: nextFieldIndex, inSection: 0)) as! ClientInfoTextFieldViewCell
            cell.textField.becomeFirstResponder()
        }else{
            var cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forItem: nextFieldIndex, inSection: 0)) as! ClientInfoTextViewCell
            cell.textView.becomeFirstResponder()
        }
    }
    
    /**ClientInfo TextView Text Did Changed */
    func clientInfoTextFieldCellTextDidChanged(textField: UITextField){
        if(textField.tag == CellType.HeightType.rawValue){
            self.selectedClientInfo.height = textField.text
        }else if(textField.tag == CellType.WeightType.rawValue){
            self.selectedClientInfo.weight = textField.text
        }else if(textField.tag == CellType.BodyFatType.rawValue){
            self.selectedClientInfo.bodyFatPercentage = (textField.text as NSString).floatValue
        }else if(textField.tag == CellType.DietType.rawValue){
            self.selectedClientInfo.diet = textField.text
        }
    }

}
