//
//  ProjectViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/20/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit
import os.log

class ProjectViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var contactEmailTextField: UITextField!
    @IBOutlet weak var sampleIDPrefixTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    /* This value is either passed by `ProjectTableViewController` via `prepare(for:sender)`
        or construct as part of adding a new project.
     */
    var project: Project?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text field delegates
        projectNameTextField.delegate = self
        contactNameTextField.delegate = self
        contactEmailTextField.delegate = self
        sampleIDPrefixTextField.delegate = self
        
        // Disable save button
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
        project = Project(name: projectName, contactName: contactName, contactEmail: contactEmail, sampleIDPrefix: sampleIDPrefix, sites: nil, samples: nil)
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

