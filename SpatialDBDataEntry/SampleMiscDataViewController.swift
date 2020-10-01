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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var depthTextField: UITextField!
    @IBOutlet weak var volumeTextField: UITextField!
    @IBOutlet weak var phasePicker: UIPickerView!
    @IBOutlet weak var startCollectionDatePicker: UIDatePicker!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var toolbar: UIToolbar? = nil

    var depth: Double = -9999.0
    var volume: Double = -9999.0
    var phase: PhaseType = PhaseType.none
    var startCollectionDate: Date = Date.distantFuture
    var startCollectionTimeZone: TimeZone? = nil
    var comments: String = ""
    var activeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set text field delegates
        depthTextField.delegate = self
        volumeTextField.delegate = self
        commentsTextField.delegate = self
        
        // Set picker view delegates
        phasePicker.delegate = self
        phasePicker.dataSource = self
        
        // Register for keyboard events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWasShown(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillBeHidden(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        // Add a `Done` button to the numeric text fields
        initToolbar()
        depthTextField.inputAccessoryView = toolbar
        volumeTextField.inputAccessoryView = toolbar
        
        // Check if editing an existing sample
        if depth != -9999 {
            depthTextField.text = String(depth)
        }
        
        if volume != -9999 {
            volumeTextField.text = String(volume)
        }
        
        phasePicker.selectRow(phase.rawValue, inComponent: 0, animated: false)
        
        if startCollectionDate.compare(Date.distantFuture) == ComparisonResult.orderedAscending {
            startCollectionDatePicker.setDate(startCollectionDate, animated: false)
        }
        
        commentsTextField.text = comments
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
        self.view.endEditing(true)
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
        phase = PhaseType(rawValue: row)!
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
        
        if depthTextField.text!.isEmpty == false {
            depth = Double(depthTextField.text!)!
        }
        
        if volumeTextField.text!.isEmpty == false {
            volume = Double(volumeTextField.text!)!
        }
        
        comments = commentsTextField.text!
    }
    
    //MARK: Actions
    
    @IBAction func cancelMiscSampleData(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startCollectionDateSelected(_ sender: UIDatePicker) {
        startCollectionDate = sender.date
        startCollectionTimeZone = TimeZone.current
    }
    
    //MARK: Private Methods
    
    private func initToolbar() {
        toolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(SampleMiscDataViewController.doneButtonAction))
        
        toolbar!.setItems([flexSpace, doneBtn], animated: false)
        toolbar!.sizeToFit()
    }
    
    @objc private func doneButtonAction() {
        // Hide the keyboard.
        self.view.endEditing(true)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
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
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
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
/*
    @objc private func keyboardWillShow(notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    private func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
    } */
    
}
