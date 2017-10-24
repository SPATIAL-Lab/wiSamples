//
//  SampleMiscDataViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/23/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit
import os.log

class SampleMiscDataViewController: UIViewController,
UITextFieldDelegate,
UIPickerViewDelegate,
UIPickerViewDataSource
{
    
    //MARK: Properties
    
    @IBOutlet weak var depthTextField: UITextField!
    @IBOutlet weak var volumeTextField: UITextField!
    @IBOutlet weak var phasePicker: UIPickerView!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var depth: Int = 0
    var volume: Int = 0
    var selectedPhase: PhaseType = PhaseType.liquid
    var comments: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set text field delegates
        depthTextField.delegate = self
        volumeTextField.delegate = self
        commentsTextField.delegate = self
        
        // Set picker view delegates
        phasePicker.delegate = self
        phasePicker.dataSource = self
        
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
        return PhaseType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPhase = PhaseType(rawValue: row)!
    }
    
    //MARK: UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return PhaseType(rawValue: row)?.description
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed...cancelling.", log: OSLog.default, type: OSLogType.debug)
            return
        }
        
        depth = Int(depthTextField.text!)!
        volume = Int(volumeTextField.text!)!
        comments = commentsTextField.text!
    }
    
    //MARK: Actions
    
    @IBAction func cancelMiscSampleData(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    func checkAndEnableSaveButton() {
        if depthTextField.text!.isEmpty == false && volumeTextField.text!.isEmpty == false {
            saveButton.isEnabled = true;
        }
        else {
            saveButton.isEnabled = false;
        }
    }
    
}
