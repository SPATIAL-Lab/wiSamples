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
    @IBOutlet weak var projectIDLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let projectIDLabelSuffix: String = "Project ID: "

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
        let projectID = projectIDLabel.text ?? ""
        
        // Create a new project
        project = Project(id: projectID, name: projectName, contactName: contactName, contactEmail: contactEmail, sites: nil)
    }
    
    //MARK: Actions
    
    @IBAction func cancelNewProject(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func generateProjectID(_ sender: UIButton) {
        let projectName = projectNameTextField.text ?? ""
        
        if projectName.isEmpty {
            os_log("Project name was empty. Cannot generate project ID!", log: OSLog.default, type: OSLogType.debug)
            return
        }
        
        // Generate a project ID based on the name.
        projectIDLabel.text = projectIDLabelSuffix + projectName + "_01"
        
        // Enable the save button
        saveButton.isEnabled = true
    }
}

