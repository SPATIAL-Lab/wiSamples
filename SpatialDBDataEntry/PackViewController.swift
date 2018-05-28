
//
//  PackViewController.swift
//  SpatialDBDataEntry
//
//  Created by Gabe Bowen on 5/8/18.
//  Copyright © 2018 University of Utah. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class PackViewController: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {

    let locationManager = CLLocationManager()
    var lastUpdatedLocation: CLLocation = CLLocation()
    let minLocationErrorTolerance: Double = 30
    var hasFetchedInitially: Bool = false
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var packButton: UIBarButtonItem!
    @IBOutlet weak var donePack: UIBarButtonItem!
    var popup: UIView!
    var progressView: UIProgressView!
    var textView: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setStyle(index: 0)
        
        // Create a UISegmentedControl to toggle between map styles
        let styleToggle = UISegmentedControl(items: ["Streets", "Satellite"])
        styleToggle.translatesAutoresizingMaskIntoConstraints = false
        styleToggle.backgroundColor = UIColor.white
        styleToggle.selectedSegmentIndex = 0
        view.insertSubview(styleToggle, aboveSubview: mapView)
        styleToggle.addTarget(self, action: #selector(changeStyle(sender:)), for: .valueChanged)

        // Configure autolayout constraints for the UISegmentedControl to align
        // at the bottom of the map view and above the Mapbox logo and attribution
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-40-[styleToggle]-40-|", options: [], metrics: nil, views: ["styleToggle" : styleToggle]))
        NSLayoutConstraint.activate([NSLayoutConstraint(item: styleToggle, attribute: .bottom, relatedBy: .equal, toItem: mapView.logoView, attribute: .top, multiplier: 1, constant: -20)])
        
        // Initialize location
        // Request location usage
        locationManager.requestWhenInUseAuthorization()
        
        // Setup location services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        packButton.isEnabled = Reachability.isConnectedToNetwork()
        
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackProgressDidChange), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveError), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offlinePackDidReceiveMaximumAllowedMapboxTiles), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Save off the difference from the previous update
        let distanceFromLastUpdatedLocation = manager.location!.distance(from: lastUpdatedLocation)
        lastUpdatedLocation = manager.location!
        
        if !hasFetchedInitially && distanceFromLastUpdatedLocation.isLess(than: minLocationErrorTolerance) {
            
            hasFetchedInitially = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.mapView.setCenter(self.lastUpdatedLocation.coordinate, zoomLevel: 10, animated: true)
            }
        }
    }
    
    deinit {
        // Remove offline pack observers.
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func startOfflinePackDownload(_ sender: UIBarButtonItem) {
        // Create a region that includes the current viewport and any tiles needed to view it when zoomed further in.
        // Because tile count grows exponentially with the maximum zoom level, you should be conservative with your `toZoomLevel` setting.
        let maxzoom = min(mapView.zoomLevel + 5, 19)
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: mapView.zoomLevel, toZoomLevel: maxzoom)
        
        // Store some data for identification purposes alongside the downloaded resources.
        let userInfo = ["name": "My Offline Pack"]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
 
        // Set up notifications
        if popup == nil {
            popup = UIView()
            let superFrame = view.bounds.size
            popup.frame = CGRect(x: superFrame.width / 6, y: superFrame.height * 0.70, width: (superFrame.width * 2 / 3), height: 40)
            popup.backgroundColor = UIColor.white
            popup.layer.borderColor = UIColor.black.cgColor
            popup.layer.cornerRadius = 4
            popup.layer.borderWidth = 1
        }
        view.addSubview(popup)
        
        if textView == nil {
            textView = UITextField(frame: CGRect(x: popup.frame.width / 4, y: 5, width: popup.frame.width / 2, height: 20))
            textView.textAlignment = NSTextAlignment.center
            popup.addSubview(textView)
        } else {
            textView.text = ""
        }
        if progressView != nil {
            progressView.progress = 0
        }

        
        // Clean out old packs
        let packs = MGLOfflineStorage.shared.packs!
        if packs.count > 0 {
            textView.text = "Preparing..."
            for pack in packs {
                MGLOfflineStorage.shared.removePack(pack)
            }
        }
        
        // Create and register an offline pack with the shared offline storage object.
        MGLOfflineStorage.shared.addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                // The pack couldn’t be created for some reason.
                print("Error: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            // Start downloading.
            pack!.resume()
        }
        
    }
    
    //MARK: Map Style Controller
    
    // Change the map style based on the selected index of the UISegmentedControl
    @objc func changeStyle(sender: UISegmentedControl) {
        setStyle(index: sender.selectedSegmentIndex)
    }
    
    func setStyle(index: Int) {
        switch index {
        case 0:
            mapView.styleURL = MGLStyle.streetsStyleURL
        case 1:
            mapView.styleURL = MGLStyle.satelliteStyleURL
        default:
            mapView.styleURL = MGLStyle.streetsStyleURL
        }
    }
    
    //MARK: Actions
    
    @IBAction func donePack(_ sender: UIBarButtonItem) {
        // Remove offline pack observers.
        NotificationCenter.default.removeObserver(self)
        dismiss(animated: true, completion: nil)
    }

    // MARK: - MGLOfflinePack notification handlers
    
    @objc func offlinePackProgressDidChange(notification: NSNotification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            // Set up notifications
            if popup == nil {
                popup = UIView()
                let superFrame = view.bounds.size
                popup.frame = CGRect(x: superFrame.width / 6, y: superFrame.height * 0.70, width: (superFrame.width * 2 / 3), height: 40)
                popup.backgroundColor = UIColor.white
                popup.layer.borderColor = UIColor.black.cgColor
                popup.layer.cornerRadius = 4
                popup.layer.borderWidth = 1
            }
            view.addSubview(popup)
            
            if textView == nil {
                textView = UITextField(frame: CGRect(x: popup.frame.width / 4, y: 5, width: popup.frame.width / 2, height: 20))
                textView.textAlignment = NSTextAlignment.center
                popup.addSubview(textView)
            }
            textView.text = "Packing..."

            // Setup the progress bar.
            if progressView == nil {
                progressView = UIProgressView(progressViewStyle: .default)
                progressView.frame = CGRect(x: popup.frame.width / 6, y: 29, width: popup.frame.width * 2 / 3, height: 10)
                popup.addSubview(progressView)
            }
            
            progressView.progress = progressPercentage
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
                let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
                print("Offline pack “\(userInfo["name"] ?? "unknown")” completed: \(byteCount), \(completedResources) resources")
                textView.text = "Done"

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self.popup.removeFromSuperview()
                }
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"] ?? "unknown")” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")

            }
        }
    }
    
    @objc func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackUserInfoKey.error] as? NSError {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” received error: \(error.localizedFailureReason ?? "unknown error")")
            textView.text = "Unknown error"
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                self.popup.removeFromSuperview()
            }
        }
    }
    
    @objc func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackUserInfoKey.maximumCount] as AnyObject).uint64Value {
            print("Offline pack “\(userInfo["name"] ?? "unknown")” reached limit of \(maximumCount) tiles.")
            textView.text = "Limit reached"
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                self.popup.removeFromSuperview()
            }
        }
    }
    
}
