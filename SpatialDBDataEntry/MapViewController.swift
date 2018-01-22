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

enum MapPanFetchResultType: Int {
    case withinWindow
    case leftOfWindow
    case rightOfWindow
    case aboveWindow
    case belowWindow
    
    var description: String {
        switch self {
        case .withinWindow:         return "Within Window"
        case .leftOfWindow:         return "Left of Window"
        case .rightOfWindow:        return "Right of Window"
        case .aboveWindow:          return "Above Window"
        case .belowWindow:          return "Below Window"
        }
    }
    
    static var count: Int {
        return 5
    }
}

class MapViewController: UIViewController,
CLLocationManagerDelegate,
MKMapViewDelegate,
DataManagerResponseDelegate {
    
    //MARK: Properties
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    // Project properties
    var projectIndex: Int = -1
    
    // MapView properties
    var lastUpdatedLocation: CLLocation = CLLocation()
    let maxLatitudeDelta: Double = 0.05
    var siteAnnotationList: [SiteAnnotation] = []
    var lastRegionCenter: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    // Site fetching
    var hasFetchedInitially: Bool = false
    let siteFetchWindowSize: Double = 10
    let siteFetchIncrementSize: Double = 0.045 // (5km / earthRadius) * radiansToDegrees
    let minLocationErrorTolerance: Double = 5
    var lastMinLatLong: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var lastMaxLatLong: CLLocationCoordinate2D = CLLocationCoordinate2D()

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

        // Plot saved sites
        let savedSites = SiteAnnotation.loadSiteAnnotations(fromSites: Project.projects[projectIndex].sites)
        siteAnnotationList.append(contentsOf: savedSites)
        mapView.addAnnotations(siteAnnotationList)
        
        // Center map on selected location if valid else ask location manager
        initSelectedSite()
        
        // Enable the save button if viewing an existing site
        saveButton.isEnabled = selectedExistingSite
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        // TODO: Dispose the oldest sites from the annotations list
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Save off the difference from the previous update
        let distanceFromLastUpdatedLocation = manager.location!.distance(from: lastUpdatedLocation)
        lastUpdatedLocation = manager.location!
        
        // Fetch initial sites only once
        // Fetch initial sites only if the updated location has stabilized
        if !hasFetchedInitially && distanceFromLastUpdatedLocation.isLess(than: minLocationErrorTolerance) {
            hasFetchedInitially = true
            
            // Get a window around the user's current location
            let (minLatLong, maxLatLong) = getMinMaxLatLong(location: lastUpdatedLocation, rangeInKM: siteFetchWindowSize)
            
            // Update the window dimensions
            updateWindow(mapRegionCenter: lastUpdatedLocation.coordinate, minLatLong: minLatLong, maxLatLong: maxLatLong)
            
            // Fetch sites for the current window
            fetchSites(minLatLong: minLatLong, maxLatLong: maxLatLong)
            
            // Center map on selected location if valid else ask location manager
            initSelectedSite()
        }
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
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
//        print("regionWillChange \(mapView.region.center)")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // Check if the map has been zoomed out beyond the maximum
        if Double(mapView.region.span.latitudeDelta) > maxLatitudeDelta {
            // Zoom back in to the user's current location
            let correctedRegion = MKCoordinateRegionMake(lastUpdatedLocation.coordinate, MKCoordinateSpanMake(maxLatitudeDelta * 0.5, maxLatitudeDelta * 0.5))
            mapView.setRegion(correctedRegion, animated: true)
            
            return
        }
        
        // Check if the map has been panned far enough to fetch new sites
        let mapPanFetchResult = mustFetchSites(newMapRegionCenter: mapView.region.center)
        
        fetchSites(minLatLong: lastMinLatLong, maxLatLong: lastMaxLatLong)
        
        print("MapPanFetchResult: \(mapPanFetchResult.description)")
        
        if mapPanFetchResult != MapPanFetchResultType.withinWindow {
//            // Update min, max lat-long
//            switch mapPanFetchResult {
//            case MapPanFetchResultType.leftOfWindow:
//                break
//            case MapPanFetchResultType.rightOfWindow:
//                break
//            case MapPanFetchResultType.aboveWindow:
//                break
//            case MapPanFetchResultType.belowWindow:
//                break
//            default:
//                return
//            }
//            
//            // Calculate delta in the window
//            
//            // Fetch sites for the delta
        }
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
    
    //MARK: DataManagerResponseDelegate
    
    func fetchSites(minLatLong: CLLocationCoordinate2D, maxLatLong: CLLocationCoordinate2D) {
        print("Fetching sites in range \(minLatLong), \(maxLatLong)...")
        
        // Request for sites in the range of latitude and longitude
        DataManager.shared.fetchSites(delegate: self, minLatLong: minLatLong, maxLatLong: maxLatLong)
    }
    
    func receiveSites(errorMessage: String, sites: [Site]) {
        // Get site annotations for each received site
        let receivedSites = SiteAnnotation.loadSiteAnnotations(fromSites: sites)
        // Cache the annotations that aren't already cached
        let newSites = getNewSitesFromReceivedSites(receivedSiteAnnotations: receivedSites)
        
        if !newSites.isEmpty {
            print("Plotting \(newSites.count) out of \(receivedSites.count) received sites...")
            
            // Save the new sites
            siteAnnotationList.append(contentsOf: newSites)
            
            // Plot the site annotations
            mapView.addAnnotations(newSites)
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
        // If not site was selected, center map on the user's current location
        if existingSiteID.isEmpty {
            centerMapOnLocation(location: locationManager.location!.coordinate)
        }
        else {
            // Select the annotation that matches the selected location's site ID
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
    
    private func getNewSitesFromReceivedSites(receivedSiteAnnotations: [SiteAnnotation]) -> [SiteAnnotation] {
        // Filter out existing sites
        let newSiteAnnotations = receivedSiteAnnotations.filter {
            !siteAnnotationList.contains($0)
        }

        return newSiteAnnotations
    }
    
    private func updateWindow(mapRegionCenter: CLLocationCoordinate2D, minLatLong: CLLocationCoordinate2D, maxLatLong: CLLocationCoordinate2D) {
        lastRegionCenter = mapRegionCenter
        lastMinLatLong = minLatLong
        lastMaxLatLong = maxLatLong
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMake(location, MKCoordinateSpanMake(maxLatitudeDelta * 0.25, maxLatitudeDelta * 0.25))
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func mustFetchSites(newMapRegionCenter: CLLocationCoordinate2D) -> MapPanFetchResultType {
        if newMapRegionCenter.latitude < lastMinLatLong.latitude {
            return MapPanFetchResultType.belowWindow
        }
        else if newMapRegionCenter.longitude < lastMinLatLong.longitude {
            return MapPanFetchResultType.leftOfWindow
        }
        else if newMapRegionCenter.latitude > lastMaxLatLong.latitude {
            return MapPanFetchResultType.aboveWindow
        }
        else if newMapRegionCenter.longitude > lastMaxLatLong.longitude {
            return MapPanFetchResultType.rightOfWindow
        }
        
        return MapPanFetchResultType.withinWindow
    }
    
    private func getMinMaxLatLong(location: CLLocation, rangeInKM: Double) -> (min: CLLocationCoordinate2D, max: CLLocationCoordinate2D) {
        let latitude: Double = Double(location.coordinate.latitude)
        let longitude: Double = Double(location.coordinate.longitude)
        
        let radiusEarth: Double = 6378;
        let radiansToDegrees: Double = 180 / Double.pi
        let degreesToRadians: Double = Double.pi / 180
        
        let minLatitude = latitude - (rangeInKM / radiusEarth) * radiansToDegrees
        let maxLatitude = latitude + (rangeInKM / radiusEarth) * radiansToDegrees
        let minLongitude = longitude - (rangeInKM / radiusEarth) * radiansToDegrees / cos(latitude * degreesToRadians)
        let maxLongitude = longitude + (rangeInKM / radiusEarth) * radiansToDegrees / cos(latitude * degreesToRadians)
        
        return (CLLocationCoordinate2D(latitude: minLatitude, longitude: minLongitude), CLLocationCoordinate2D(latitude: maxLatitude, longitude: maxLongitude))
    }

}
