//
//  ProjectTableViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit
import os.log

class ProjectTableViewController: UITableViewController {
    
    //MARK: Properties

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ProjectTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProjectTableViewCell else {
            fatalError("The dequeued cell is not an instance of ProjectTableViewCell!")
        }

        let project = DataManager.shared.projects[indexPath.row]
        
        cell.projectNameLabel.text = project.name
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */


    // Support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the project
            DataManager.shared.projects.remove(at: indexPath.row)
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Save data
            DataManager.shared.saveProjects()
        }
        else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "AddNewProject":
            os_log("Adding a new project.", log: OSLog.default, type: OSLogType.debug)
            
        case "ShowSites":
            guard let siteTableViewController = segue.destination as? SiteTableViewController else {
                fatalError("The top view controller was not a SiteTableViewController!")
            }
            
            guard let selectedProjectCell = sender as? ProjectTableViewCell else {
                fatalError("Unexpected sender \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedProjectCell) else {
                fatalError("The selected cell is not being displayed by the table!")
            }
            
            siteTableViewController.projectIndex = indexPath.row
            
        case "ShowSamples":
            guard let sampleTableViewController = segue.destination as? SampleTableViewController else {
                fatalError("The top view controller was not a SampleTableViewController")
            }
            
            guard let selectedProjectCell = sender as? ProjectTableViewCell else {
                fatalError("Unexpected sender \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedProjectCell) else {
                fatalError("The selected cell is not being displayed by the table!")
            }
            
            sampleTableViewController.projectIndex = indexPath.row
            
        case "ShowSettings":
            print("Showing settings.")
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
    }

    //MARK: Actions

    @IBAction func unwindToProjectList(sender: UIStoryboardSegue) {
        if let projectViewController = sender.source as? ProjectViewController, let project = projectViewController.project {
            // Get an index for the new cell
            let newIndexPath = IndexPath(row: DataManager.shared.projects.count, section: 0)
            
            // Add the new project
            DataManager.shared.projects.append(project)
            
            // Add the new project to the table
            tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
            
            // Save data
            DataManager.shared.saveProjects()
        }
    }
    
    //MARK: Private Methods
    
}
