//
//  SampleViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/9/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit
import os.log
import CoreLocation

class SampleViewController: UIViewController,
UITextFieldDelegate,
UIPickerViewDelegate,
UIPickerViewDataSource,
CLLocationManagerDelegate {

    //MARK: Properties
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var sampleIDTextField: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /* This value is either passed by `SampleTableViewController` via `prepare(for:sender)`
     or constructed as part of adding a new sample.
     */
    var sample: Sample?
    var generatedSampleID: String = ""
    var selectedType: SampleType = SampleType.ground
    var lastUpdatedLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var selectedDate: Date = Date()
    var depth: Int = 0
    var volume: Int = 0
    var phase: PhaseType = PhaseType.liquid
    var comments: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text field delegates
        sampleIDTextField.delegate = self
        
        // Set picker view delegates
        typePicker.delegate = self
        typePicker.dataSource = self
        
        // Initialize sample ID
        sampleIDTextField.text = generatedSampleID

        // Initialize location
        // Request location usage
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        else {
            os_log("Location services are disabled!", log: .default, type: .debug)
        }
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
        if textField === sampleIDTextField {
            navigationItem.title = textField.text
        }
        
        // Hide the keyboard.
        textField.resignFirstResponder()
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
        selectedType = SampleType(rawValue: row)!
    }
    
    //MARK: UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SampleType(rawValue: row)?.description
    }

    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastUpdatedLocation = (manager.location?.coordinate)!
    }
    
    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed...cancelling.", log: OSLog.default, type: OSLogType.debug)
            return
        }
        
        // Extract properties for a new sample.
        let sampleID = sampleIDTextField.text ?? ""
        
        // Create a new sample
        sample = Sample(id: sampleID, location: lastUpdatedLocation, type: selectedType, dateTime: selectedDate, startDateTime: selectedDate)
        
        sample!.depth = depth
        sample!.volume = volume
        sample!.phase = phase
        sample!.comments = comments
    }

    //MARK: Actions
    
    @IBAction func unwindToSampleView(sender: UIStoryboardSegue) {
        if let sampleMiscDataViewController = sender.source as? SampleMiscDataViewController {
            depth = sampleMiscDataViewController.depth
            volume = sampleMiscDataViewController.volume
            phase = sampleMiscDataViewController.selectedPhase
            comments = sampleMiscDataViewController.comments
        }
    }
    
    @IBAction func cancelNewSample(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func collectionDateSelected(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
}
