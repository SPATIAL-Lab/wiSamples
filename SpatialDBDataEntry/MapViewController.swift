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
    
    var locationSelected: CLLocationCoordinate2D = CLLocationCoordinate2D()
    let regionRadius: CLLocationDistance = 5000

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
        
        // Center map on selected location if valid else ask location manager
        if locationSelected.latitude == 0 && locationSelected.longitude == 0 {
            centerMapOnLocation(location: locationManager.location!.coordinate)
        }
        else {
            centerMapOnLocation(location: locationSelected)
        }
        
        // Plot sample sites
        let siteAnnotationList = SiteAnnotation.loadSitesFromFile(withName: "SampleSites")
        mapView.addAnnotations(siteAnnotationList)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSelected = (manager.location?.coordinate)!
    }
    
    //MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? SiteAnnotation else {
            return nil
        }
        
        let identifier = "SiteAnnotation"
        var view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        }
        else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
        }
        
        return view
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed...cancelling.", log: OSLog.default, type: OSLogType.debug)
            return
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
