//
//  SettingsViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 1/30/18.
//  Copyright © 2018 University of Utah. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Actions
    
    // TODO: Remove if not required
    @IBAction func ExportProjects(_ sender: UIButton) {
        print("Export Projects")
    }
    
    @IBAction func ImportProjects(_ sender: UIButton) {
        print("Import Projects")
    }
    
    @IBAction func unwindToSettings(sender: UIStoryboardSegue) {
        if let exportProjectsTableViewController = sender.source as? ExportProjectsTableViewController {
            let selectedProjectIndices: [Int] = exportProjectsTableViewController.getSelectedProjectIndices()
            if selectedProjectIndices.isEmpty == false {
                print("Selected \(selectedProjectIndices.count) for export:")
                for index in selectedProjectIndices {
                    print("Project Name: \(Project.projects[index].name)")
                }
            }
        }
    }
}
