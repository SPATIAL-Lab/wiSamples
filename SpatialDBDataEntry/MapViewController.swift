//
//  MapViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/27/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit
import MapKit
import os.log
import CoreLocation

class MapViewController: UIViewController,
CLLocationManagerDelegate,
MKMapViewDelegate {
    
    //MARK: Properties
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    // Project properties
    var projectIndex: Int = -1
    
    // MapView properties
    var lastUpdatedLocation: CLLocation = CLLocation()
    let regionRadius: CLLocationDistance = 2000
    var siteAnnotationList: [SiteAnnotation] = []

    // Site properties
    var selectedExistingSite: Bool = false
    var existingSiteID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
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
            os_log("Location services are disabled!", log: .default, type: .debug)
        }
        
        // TODO: This must also include sites saved by the user.
        // Plot sample sites
        siteAnnotationList = SiteAnnotation.loadSitesFromFile(withName: "SampleSites")
        mapView.addAnnotations(siteAnnotationList)
        
        // Center map on selected location if valid else ask location manager
        initSelectedSite()
        
        // Enable the save button if viewing an existing site
        saveButton.isEnabled = selectedExistingSite
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastUpdatedLocation = manager.location!
    }
    
    //MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? SiteAnnotation else {
            return nil
        }
        
        let identifier = "SiteAnnotation"
        var view: MKPinAnnotationView
        
        // Reuse a dequeued view else create one
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
        }
        
        // Check if the site annotation matches with the selected location
        if annotation.id == existingSiteID {
            view.pinTintColor = UIColor.yellow
        }
        else {
            view.pinTintColor = UIColor.orange
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pinAnnotation = view as? MKPinAnnotationView {
            pinAnnotation.pinTintColor = UIColor.yellow
        }
        
        centerMapOnLocation(location: (view.annotation?.coordinate)!)
        
        // Update the title
        if let siteAnnotation = view.annotation as? SiteAnnotation {
            existingSiteID = siteAnnotation.id
            navigationItem.title = siteAnnotation.id
        }
        else {
            existingSiteID = ""
            navigationItem.title = "My Location"
        }
        
        saveButton.isEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let pinAnnotation = view as? MKPinAnnotationView {
            pinAnnotation.pinTintColor = UIColor.orange
        }
        
        existingSiteID = ""
        navigationItem.title = ""
        saveButton.isEnabled = false
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowSiteView" {
            guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            
            guard let siteViewController = navigationController.viewControllers[0] as? SiteViewController else {
                fatalError("Unexpected presented view controller \(navigationController.presentedViewController)")
            }
            
            siteViewController.generatedSiteID = Project.projects[projectIndex].getIDForNewSite()
            siteViewController.projectIndex = projectIndex
            siteViewController.newLocation = lastUpdatedLocation
        }
    }
    
    //MARK: Actions
    
    @IBAction func cancelSetLocation(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveLocation(_ sender: UIBarButtonItem) {
        // Check if an existing site id exists
        selectedExistingSite = !existingSiteID.isEmpty
        
        if selectedExistingSite {
            // If an existing site was selected, unwind to the sample view
            performSegue(withIdentifier: "UnwindOnSiteSelected", sender: self)
            }
        else {
            // If a new site was selected, show the site view
            performSegue(withIdentifier: "ShowSiteView", sender: self)
        }
    }
    
    //MARK: Private Methods
    
    private func initSelectedSite() {
        if existingSiteID.isEmpty {
            centerMapOnLocation(location: locationManager.location!.coordinate)
        }
        else {
            // Select the annotation that matches the selected location
            for siteAnnotation in siteAnnotationList {
                if siteAnnotation.id == existingSiteID {
                    centerMapOnLocation(location: siteAnnotation.coordinate)
                    mapView.selectAnnotation(siteAnnotation, animated: true)
                    navigationItem.title = siteAnnotation.id
                    break
                }
            }
        }
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}
