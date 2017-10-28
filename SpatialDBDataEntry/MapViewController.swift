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

class MapViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var locationSelected: CLLocationCoordinate2D = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
