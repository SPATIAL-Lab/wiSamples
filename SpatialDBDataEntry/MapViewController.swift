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
    
    var selectedExistingSite: Bool = false
    var locationSelected: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var lastUpdatedLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    let regionRadius: CLLocationDistance = 2000

    var siteAnnotationList: [SiteAnnotation] = []
    
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
        if locationSelected.latitude == 0 && locationSelected.longitude == 0 {
            centerMapOnLocation(location: locationManager.location!.coordinate)
        }
        else {
            centerMapOnLocation(location: locationSelected)
            
            // Select the annotation that matches the selected location
            for siteAnnotation in siteAnnotationList {
                if siteAnnotation.coordinate.latitude == locationSelected.latitude && siteAnnotation.coordinate.longitude == locationSelected.longitude {
                    mapView.selectAnnotation(siteAnnotation, animated: true)
                    break
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastUpdatedLocation = (manager.location?.coordinate)!
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
        let annotationCoordinate = (view.annotation?.coordinate)!
        if annotationCoordinate.latitude == locationSelected.latitude && annotationCoordinate.longitude == locationSelected.longitude {
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
        
        locationSelected = (view.annotation?.coordinate)!
        centerMapOnLocation(location: locationSelected)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let pinAnnotation = view as? MKPinAnnotationView {
            pinAnnotation.pinTintColor = UIColor.orange
        }
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed...cancelling.", log: OSLog.default, type: OSLogType.debug)
            return
        }
        
        // Check if an existing location was selected
        if locationSelected.latitude != 0 || locationSelected.longitude != 0 {
            for siteAnnotation in siteAnnotationList {
                if siteAnnotation.coordinate.latitude == locationSelected.latitude && siteAnnotation.coordinate.longitude == locationSelected.longitude {
                    selectedExistingSite = true
                    break
                }
            }
        }
        // This means no location was selected
        else {
            selectedExistingSite = false
            // Use last updated location as selected location
            locationSelected = lastUpdatedLocation
        }
    }
    
    //MARK: Actions
    
    @IBAction func cancelSetLocation(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}
