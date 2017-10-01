//
//  SiteViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/1/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit
import os.log

class SiteViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var siteIDTextField: UITextField!
    @IBOutlet weak var siteNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /* This value is either passed by `SiteTableViewController` via `prepare(for:sender)`
     or construct as part of adding a new site.
     */
    var site: Site?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set text field delegates
        siteIDTextField.delegate = self
        siteNameTextField.delegate = self
        
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
        if textField === siteNameTextField {
            navigationItem.title = textField.text
        }
        
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed...cancelling.", log: OSLog.default, type: OSLogType.debug)
            return
        }

        // Extract properties for a new site
        let siteID = siteIDTextField.text ?? ""
        let siteName = siteNameTextField.text ?? ""
        
        // Create a new site
        site = Site(id: siteID, name: siteName)
    }

    //MARK: Actions
    
    @IBAction func GetSiteLocation(_ sender: UIButton) {
        saveButton.isEnabled = true
    }
    
    
}
