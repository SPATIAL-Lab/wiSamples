//
//  SettingsViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 1/30/18.
//  Copyright © 2018 University of Utah. All rights reserved.
//

import CoreLocation
import UIKit

class SettingsViewController: UIViewController,
    CLLocationManagerDelegate,
    DataManagerResponseDelegate {
    
    //MARK: Properties
    
    let locationManager = CLLocationManager()
    var lastUpdatedLocation: CLLocation = CLLocation()
    
    @IBOutlet weak var importProjectsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize location
        // Request location usage
        locationManager.requestWhenInUseAuthorization()
        
        // Setup location services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        else {
            print("Location services are disabled!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastUpdatedLocation = manager.location!
    }
    
    //MARK: DataManagerResponseDelegate
    
    func receiveSites(errorMessage: String, sites: [Site]) {
        importProjectsButton.setTitle("Cached \(sites.count) sites", for: UIControlState.normal)

        DispatchQueue.global(qos: .utility).async {
            print("Copying sites...")
            DataManager.shared.cachedSites = sites
            print("Sorting sites...")
            DataManager.shared.cachedSites.sort(by: self.siteSortPredicate)
            print("Saving sites...")
            DataManager.shared.saveCachedSites()
            print("Done.")
            
            DispatchQueue.main.async {
                self.finishedProcessingCachedSites()
            }
        }
    }

    //MARK: Actions
    
    @IBAction func ImportProjects(_ sender: UIButton) {
        sender.isEnabled = false
        print("Fetching all sites.")
        DataManager.shared.fetchAllSites(delegate: self)
    }
    
    @IBAction func unwindToSettings(sender: UIStoryboardSegue) {

    }
    
    //MARK: Private Methods
    
    private func siteSortPredicate(siteA: Site, siteB: Site) -> Bool {
        return CLLocation(latitude: siteA.location.latitude, longitude: siteA.location.longitude).distance(from: lastUpdatedLocation) < CLLocation(latitude: siteB.location.latitude, longitude: siteB.location.longitude).distance(from: lastUpdatedLocation)
    }
    
    private func finishedProcessingCachedSites() {
//        for i in 0...999 {
//            let distance = lastUpdatedLocation.distance(from: CLLocation(latitude: DataManager.shared.cachedSites[i].location.latitude, longitude: DataManager.shared.cachedSites[i].location.longitude))
//            print("Site:\(i) Distance:\(distance)")
//        }
    }
}
