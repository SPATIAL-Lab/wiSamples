//
//  SettingsViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 1/30/18.
//  Copyright © 2018 University of Utah. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController,
    DataManagerResponseDelegate {
    
    //MARK: Properties
    @IBOutlet weak var importProjectsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: DataManagerResponseDelegate
    func receiveSites(errorMessage: String, sites: [Site]) {
        importProjectsButton.setTitle("Cached \(sites.count) sites", for: UIControlState.normal)

        DispatchQueue.main.async {
            Project.cachedSites = sites
            Project.saveCachedSites()
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
}
