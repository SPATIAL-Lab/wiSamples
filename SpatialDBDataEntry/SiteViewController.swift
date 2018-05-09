//
//  SiteViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/1/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit
import os.log
import CoreLocation

class SiteViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var siteIDTextField: UITextField!
    @IBOutlet weak var siteNameTextField: UITextField!
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Project properties
    var projectIndex: Int = -1
    var site: Site?
    
    // Site properties
    var generatedSiteID: String = ""
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var elevation: Double = -9999
    var address: String = ""
    var city: String = ""
    var stateOrProvince: String = ""
    var country: String = ""
    
    // Map properties
    var newLocation: CLLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set text field delegates
        siteIDTextField.delegate = self
        siteNameTextField.delegate = self
        
        // Initialize the site id
        siteIDTextField.text = generatedSiteID
        navigationItem.title = generatedSiteID
        
        initSiteProperties()
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
        if textField === siteIDTextField {
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
        site = Site(id: siteID, name: siteName, location: location)
        
        // Fill in the remaining information
        site!.elevation = elevation
        site!.address = address
        site!.city = city
        site!.stateOrProvince = stateOrProvince
        site!.country = country
        site!.comments = commentsTextField.text ?? ""
        
        // Add the new site to this project
        DataManager.shared.projects[projectIndex].sites.append(site!)
    }

    //MARK: Actions
    
    @IBAction func cancelNewSite(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func initSiteProperties() {
        self.location = newLocation.coordinate
        self.elevation = newLocation.altitude
        
        CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                os_log("Reverse geocode location failed!", log: OSLog.default, type: OSLogType.debug)
                return
            }
            
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                self.address = placemark.subThoroughfare ?? ""
                if self.address != "" {self.address += " "}
                self.address += placemark.thoroughfare ?? ""
                self.city = placemark.locality ?? ""
                self.stateOrProvince = placemark.administrativeArea ?? ""
                self.country = placemark.isoCountryCode ?? ""
            }
        })
    }
}
