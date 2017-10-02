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
    
    var projects = [Project]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let savedProjects = Project.loadProjects() {
            projects = savedProjects
        }
        else {
            loadSampleProjects()
        }
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
        return projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ProjectTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProjectTableViewCell else {
            fatalError("The dequeued cell is not an instance of ProjectTableViewCell!")
        }

        let project = projects[indexPath.row]
        
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
            projects.remove(at: indexPath.row)
            
            // Save projects
            Project.saveProjects(projects: projects)
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
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
            
            let selectedProject = projects[indexPath.row]
            siteTableViewController.project = selectedProject
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
    }

    //MARK: Actions

    @IBAction func unwindToProjectList(sender: UIStoryboardSegue) {
        if let projectViewController = sender.source as? ProjectViewController, let project = projectViewController.project {
            // Add a new project
            let newIndexPath = IndexPath(row: projects.count, section: 0)
            projects.append(project)
            tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
            
            // Save projects
            Project.saveProjects(projects: projects)
        }
    }
    
    //MARK: Private Methods
    
    private func loadSampleProjects() {
        guard let project1 = Project(id: "001", name: "TestProject_01", contactName: "John Doe", contactEmail: "", sites: loadSampleSites()) else {
            fatalError("Unable to instantiate project1")
        }
        
        guard let project2 = Project(id: "002", name: "TestProject_02", contactName: "Jane Doe", contactEmail: "", sites: loadSampleSites()) else {
            fatalError("Unable to instantiate project2")
        }
        
        guard let project3 = Project(id: "003", name: "TestProject_03", contactName: "Gabe Bowen", contactEmail: "", sites: loadSampleSites()) else {
            fatalError("Unable to instantiate project3")
        }
        
        projects += [project1, project2, project3]
    }
    
    private func loadSampleSites() -> [Site] {
        guard let site1 = Site(id: "s_01", name: "Site_01") else {
            fatalError("Unable to instantiate site1")
        }
        
        guard let site2 = Site(id: "s_02", name: "Site_02") else {
            fatalError("Unable to instantiate site2")
        }
        
        return [site1, site2]
    }
    
}
