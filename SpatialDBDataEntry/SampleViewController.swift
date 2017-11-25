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
UIPickerViewDataSource {

    //MARK: Properties
    
    @IBOutlet weak var sampleIDTextField: UITextField!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var collectionDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /* This value is either passed by `SampleTableViewController` via `prepare(for:sender)`
     or constructed as part of adding a new sample.
     */
    var sample: Sample?
    
    // Project properties
    var projectIndex: Int = -1
    
    // Sample properties
    var generatedSampleID: String = ""
    var type: SampleType = SampleType.ground
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var siteID: String = ""
    var collectionDate: Date = Date()
    
    // Sample misc properties
    var depth: Int = -1
    var volume: Int = -1
    var phase: PhaseType = PhaseType.none
    var startCollectionDate: Date = Date.distantFuture
    var comments: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set text field delegates
        sampleIDTextField.delegate = self
        
        // Set picker view delegates
        typePicker.delegate = self
        typePicker.dataSource = self

        // Setup views if editing an existing sample
        if let existingSample = sample {
            
            // Update data variables
            generatedSampleID = existingSample.id
            type = existingSample.type
            location = existingSample.location
            collectionDate = existingSample.dateTime
            depth = existingSample.depth
            volume = existingSample.volume
            phase = existingSample.phase
            startCollectionDate = existingSample.startDateTime
            comments = existingSample.comments
            
            // Update view
            sampleIDTextField.text = existingSample.id
            navigationItem.title = existingSample.id
            typePicker.selectRow(existingSample.type.rawValue, inComponent: 0, animated: false)
            collectionDatePicker.setDate(existingSample.dateTime, animated: false)
        }
        else {
            // Initialize sample ID
            sampleIDTextField.text = generatedSampleID
            navigationItem.title = generatedSampleID
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
        type = SampleType(rawValue: row)!
    }
    
    //MARK: UIPickerViewDataSource
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return SampleType(rawValue: row)?.description
    }
    
    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "ShowMapView":
            guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            
            guard let mapViewController = navigationController.viewControllers[0] as? MapViewController else {
                fatalError("Unexpected presented view controller \(navigationController.presentedViewController)")
            }
            
            mapViewController.projectIndex = projectIndex
            mapViewController.locationSelected = location
            
        case "ShowSampleMiscData":
            guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            
            guard let sampleMiscDataViewController = navigationController.viewControllers[0] as? SampleMiscDataViewController else {
                fatalError("Unexpected presented view controller \(navigationController.presentedViewController)")
            }
            
            sampleMiscDataViewController.depth = depth
            sampleMiscDataViewController.volume = volume
            sampleMiscDataViewController.phase = phase
            sampleMiscDataViewController.startCollectionDate = startCollectionDate
            sampleMiscDataViewController.comments = comments
            
        default:
            guard let button = sender as? UIBarButtonItem, button === saveButton else {
                os_log("The save button was not pressed...cancelling.", log: OSLog.default, type: OSLogType.debug)
                return
            }
            
            // Extract properties for a new sample.
            let sampleID = sampleIDTextField.text ?? ""
            
            // Create a new sample
            sample = Sample(id: sampleID, location: location, type: type, dateTime: collectionDate, startDateTime: startCollectionDate)
            
            sample!.depth = depth
            sample!.volume = volume
            sample!.phase = phase
            sample!.comments = comments
        }
    }

    //MARK: Actions
    
    @IBAction func unwindToSampleView(sender: UIStoryboardSegue) {
        if let sampleMiscDataViewController = sender.source as? SampleMiscDataViewController {
            depth = sampleMiscDataViewController.depth
            volume = sampleMiscDataViewController.volume
            phase = sampleMiscDataViewController.phase
            startCollectionDate = sampleMiscDataViewController.startCollectionDate
            comments = sampleMiscDataViewController.comments
        }
        else if let mapViewController = sender.source as? MapViewController {
            location = mapViewController.locationSelected
        }
        else if let siteViewController = sender.source as? SiteViewController {
            siteID = siteViewController.site!.id
        }
    }
    
    @IBAction func cancelNewSample(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func collectionDateSelected(_ sender: UIDatePicker) {
        collectionDate = sender.date
    }
    
}
