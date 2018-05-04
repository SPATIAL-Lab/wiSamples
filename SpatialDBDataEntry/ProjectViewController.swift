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

    /* This value is either passed by `ProjectTableViewController` via `prepare(for:sender)`
        or construct as part of adding a new project.
     */
    var project: Project?
    var defaultType: SampleType = SampleType.ground
    
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
        textField.resignFirstResponder()
        
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
        
        // Create a new project
        project = Project(name: projectName, contactName: contactName, contactEmail: contactEmail, sampleIDPrefix: sampleIDPrefix, sites: nil, samples: nil, defaultType:defaultType)
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
}

