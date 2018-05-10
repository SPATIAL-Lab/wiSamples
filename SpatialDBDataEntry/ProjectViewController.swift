//
//  ProjectViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/20/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit
import os.log

class ProjectViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var contactEmailTextField: UITextField!
    @IBOutlet weak var sampleIDPrefixTextField: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    /* This value is either passed by `ProjectTableViewController` via `prepare(for:sender)`
        or construct as part of adding a new project.
     */
    var project: Project?
    var defaultType: SampleType = SampleType.ground
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text field delegates
        projectNameTextField.delegate = self
        contactNameTextField.delegate = self
        contactEmailTextField.delegate = self
        sampleIDPrefixTextField.delegate = self
       
        // Set picker view delegates
        typePicker.delegate = self
        typePicker.dataSource = self

        //TODO: Move to storyboard
        // Create a UISegmentedControl to toggle between map styles
        let styleToggle = UISegmentedControl(items: ["Streets", "Satellite"])
        styleToggle.translatesAutoresizingMaskIntoConstraints = false
        styleToggle.selectedSegmentIndex = 0
        view.insertSubview(styleToggle)
        styleToggle.addTarget(self, action: #selector(changeStyle(sender:)), for: .valueChanged)

        // Configure autolayout constraints for the UISegmentedControl 
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[styleToggle]-40-|", options: [], metrics: nil, views: ["styleToggle" : styleToggle]))
        NSLayoutConstraint.activate([NSLayoutConstraint(item: styleToggle, attribute: .top, relatedBy: .equal, toItem: typePicker, attribute: .bottom, multiplier: 1, constant: 10)])
        
        // Register for keyboard events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWasShown(notification:)),
            name: NSNotification.Name.UIKeyboardDidShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillBeHidden(notification:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )

        
        // Disable the save button
        saveButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Set the title if editing project name.
        if textField === projectNameTextField {
            navigationItem.title = textField.text
        }
        
        // Hide the keyboard.
        self.view.endEditing(true)
        
        checkAndEnableSaveButton()
        return true
    }
    
    //MARK: UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SampleType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        defaultType = SampleType(rawValue: row)!
    }
    
    //MARK: UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SampleType(rawValue: row)?.description
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed...cancelling.", log: OSLog.default, type: OSLogType.debug)
            return
        }
        
        // Extract properties for a new project.
        let projectName = projectNameTextField.text ?? ""
        let contactName = contactNameTextField.text ?? ""
        let contactEmail = contactEmailTextField.text ?? ""
        let sampleIDPrefix = sampleIDPrefixTextField.text ?? ""
        let defaultMap = styleToggle.selectedSegmentIndex
        
        // Create a new project
        project = Project(name: projectName, contactName: contactName, contactEmail: contactEmail, sampleIDPrefix: sampleIDPrefix, sites: nil, samples: nil, defaultType: defaultType, defaultMap: defaultMap)
    }
    
    //MARK: Actions
    
    @IBAction func cancelNewProject(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    func checkAndEnableSaveButton() {
        if projectNameTextField.text!.isEmpty == false && sampleIDPrefixTextField.text!.isEmpty == false {
            saveButton.isEnabled = true;
        }
        else {
            saveButton.isEnabled = false;
        }
    }
/*
    @objc private func keyboardDidShow(notification: Notification) {
        adjustInsetForKeyboardShow(notification: notification)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        //adjustInsetForKeyboardShow(notification: notification)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    
    private func adjustInsetForKeyboardShow(notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

        let activeFieldBase = activeField.frame.maxY
        let keyboardHeight = (keyboardFrame.minY - 100)
        
        if activeFieldBase > keyboardHeight{
            scrollView.contentInset.bottom += (activeFieldBase - keyboardHeight)
        }
    }
 */
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }


}

