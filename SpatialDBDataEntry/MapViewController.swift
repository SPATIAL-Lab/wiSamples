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
    let maxMapZoomLongitude: Double = 0.05
    var siteAnnotationList: [SiteAnnotation] = []
    var lastRegionCenter: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var selectedSiteInitialized: Bool = false
    
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
    var existingSiteLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        // Plot saved sites
        let savedSites = SiteAnnotation.loadSiteAnnotations(fromSites: Project.projects[projectIndex].sites)
        siteAnnotationList.append(contentsOf: savedSites)
        mapView.addAnnotations(siteAnnotationList)
        
        // Check if an existing site has been selected
        if !existingSiteID.isEmpty {
            hasFetchedInitially = true
            
            // Get a window around the selected site's location
            let (minLatLong, maxLatLong) = getMinMaxLatLong(location: existingSiteLocation, rangeInKM: siteFetchWindowSize)
            
            // Update the window dimensions
            updateWindow(mapRegionCenter: existingSiteLocation, minLatLong: minLatLong, maxLatLong: maxLatLong)
            
            // Fetch sites for the current window
            fetchSites(minLatLong: minLatLong, maxLatLong: maxLatLong)
        }
        
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
            let (minLatLong, maxLatLong) = getMinMaxLatLong(location: lastUpdatedLocation.coordinate, rangeInKM: siteFetchWindowSize)
            
            // Update the window dimensions
            updateWindow(mapRegionCenter: lastUpdatedLocation.coordinate, minLatLong: minLatLong, maxLatLong: maxLatLong)
            
            // Fetch sites for the current window
            fetchSites(minLatLong: minLatLong, maxLatLong: maxLatLong)
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
            existingSiteLocation = siteAnnotation.coordinate
            navigationItem.title = siteAnnotation.id
        }
        else {
            existingSiteID = ""
            existingSiteLocation = CLLocationCoordinate2D()
            navigationItem.title = "My Location"
        }
        
        saveButton.isEnabled = true
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let pinAnnotation = view as? MKPinAnnotationView {
            pinAnnotation.pinTintColor = UIColor.orange
        }
        
        existingSiteID = ""
        existingSiteLocation = CLLocationCoordinate2D()
        navigationItem.title = ""
        saveButton.isEnabled = false
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        // Check if the map has been zoomed out beyond the maximum
        if Double(mapView.region.span.longitudeDelta) > maxMapZoomLongitude {
            let correctedCenter = existingSiteID.isEmpty ? lastUpdatedLocation.coordinate : existingSiteLocation
            
            // Zoom back in to the user's current location
            let correctedRegion = MKCoordinateRegionMake(correctedCenter, MKCoordinateSpanMake(maxMapZoomLongitude * 0.9, maxMapZoomLongitude * 0.9))
            mapView.setRegion(correctedRegion, animated: true)
            
            return
        }
        
        // Check if the map has been panned far enough to fetch new sites
        let mapPanFetchResult = mustFetchSites(newMapRegionCenter: mapView.region.center)
        
        if mapPanFetchResult != MapPanFetchResultType.withinWindow {
            print("MapPanFetchResult: \(mapPanFetchResult.description)")
            
            // Calculate delta in the window
            let (deltaMinLatLong, deltaMaxLatLong) = getDeltaWindow(mapPanFetchResult: mapPanFetchResult)

            // Fetch sites for the delta
            fetchSites(minLatLong: deltaMinLatLong, maxLatLong: deltaMaxLatLong)
            
            // Expand the window by the delta
            switch mapPanFetchResult {
            case MapPanFetchResultType.leftOfWindow:
                lastMinLatLong.longitude = deltaMinLatLong.longitude
                break
                
            case MapPanFetchResultType.rightOfWindow:
                lastMaxLatLong.longitude = deltaMaxLatLong.longitude
                break
                
            case MapPanFetchResultType.aboveWindow:
                lastMaxLatLong.latitude = deltaMaxLatLong.latitude
                break
                
            case MapPanFetchResultType.belowWindow:
                lastMinLatLong.latitude = deltaMinLatLong.latitude
                break
                
            default:
                break
            }
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
        print("Fetching sites in range \(minLatLong), \(maxLatLong)")
        
        // Request for sites in the range of latitude and longitude
        DataManager.shared.fetchSites(delegate: self, minLatLong: minLatLong, maxLatLong: maxLatLong)
    }
    
    func receiveSites(errorMessage: String, sites: [Site]) {
        // Get site annotations for each received site
        let receivedSites = SiteAnnotation.loadSiteAnnotations(fromSites: sites)
        
        // Filter out annotations that are already cached
        let newSites = getNewSitesFromReceivedSites(receivedSiteAnnotations: receivedSites)
        
        if !newSites.isEmpty {
            print("Plotting \(newSites.count) out of \(receivedSites.count) received sites")
            
            // Save the new sites
            siteAnnotationList.append(contentsOf: newSites)
            
            // Plot the site annotations
            mapView.addAnnotations(newSites)
            
            // Center map on selected location if valid else ask location manager
            initSelectedSite()
            
            print("SiteAnnotations:\(siteAnnotationList.count) MapAnnotations:\(mapView.annotations.count)")
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
    
    //MARK: Map Methods
    
    private func initSelectedSite() {
        if selectedSiteInitialized {
            return
        }
        
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
                    
                    selectedSiteInitialized = true
                    return
                }
            }
        }
    }
    
    private func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMake(location, MKCoordinateSpanMake(maxMapZoomLongitude * 0.25, maxMapZoomLongitude * 0.25))
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //MARK: Site Fetch Methods
    
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
    
    private func getDeltaWindow(mapPanFetchResult: MapPanFetchResultType) -> (min: CLLocationCoordinate2D, max: CLLocationCoordinate2D) {
        
        let latitude = Double(lastUpdatedLocation.coordinate.latitude)
        let deltaLatLong = getDeltaLatLong(rangeInKM: siteFetchWindowSize)
        let degreesToRadians: Double = Double.pi / 180
        
        var minLatLong = lastMinLatLong
        var maxLatLong = lastMaxLatLong
        
        switch mapPanFetchResult {
            
        case MapPanFetchResultType.leftOfWindow:
            maxLatLong.longitude = minLatLong.longitude
            minLatLong.longitude -= deltaLatLong
            break
            
        case MapPanFetchResultType.rightOfWindow:
            minLatLong.longitude = maxLatLong.longitude
            maxLatLong.longitude += deltaLatLong
            break
            
        case MapPanFetchResultType.aboveWindow:
            minLatLong.latitude = maxLatLong.latitude
            maxLatLong.latitude += deltaLatLong / cos(latitude * degreesToRadians)
            break
            
        case MapPanFetchResultType.belowWindow:
            maxLatLong.latitude = minLatLong.latitude
            minLatLong.latitude -= deltaLatLong / cos(latitude * degreesToRadians)
            break
            
        default:
            return (minLatLong, maxLatLong)
            
        }
        
        return (minLatLong, maxLatLong)
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
    
    private func getMinMaxLatLong(location: CLLocationCoordinate2D, rangeInKM: Double) -> (min: CLLocationCoordinate2D, max: CLLocationCoordinate2D) {
        let latitude: Double = Double(location.latitude)
        let longitude: Double = Double(location.longitude)
        
        let degreesToRadians: Double = Double.pi / 180
        let deltaLatLong = getDeltaLatLong(rangeInKM: rangeInKM)
        
        let minLatitude = latitude - deltaLatLong
        let maxLatitude = latitude + deltaLatLong
        let minLongitude = longitude - deltaLatLong / cos(latitude * degreesToRadians)
        let maxLongitude = longitude + deltaLatLong / cos(latitude * degreesToRadians)
        
        return (CLLocationCoordinate2D(latitude: minLatitude, longitude: minLongitude), CLLocationCoordinate2D(latitude: maxLatitude, longitude: maxLongitude))
    }
    
    private func getDeltaLatLong(rangeInKM: Double) -> Double {
        let radiusEarth: Double = 6378
        let radiansToDegrees: Double = 180 / Double.pi
        let deltaLatLong = (rangeInKM / radiusEarth) * radiansToDegrees
        return deltaLatLong
    }

}
