//
//  SiteTableViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/1/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit

class SiteTableViewController: UITableViewController {

    //MARK: Properties
    
    var projectIndex: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !Project.isValid(projectIndex: projectIndex) {
            fatalError("Project was nil!")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        navigationItem.title = DataManager.shared.projects[projectIndex].name + " Sites"
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
        return DataManager.shared.projects[projectIndex].sites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SiteTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SiteTableViewCell else {
            fatalError("The dequequed cell is not an instance of SiteTableViewCell!")
        }

        let site = DataManager.shared.projects[projectIndex].sites[indexPath.row]
        
        cell.siteIDLabel.text = site.id
        
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
            // Delete the site
            DataManager.shared.projects[projectIndex].sites.remove(at: indexPath.row)

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: Actions
    
    @IBAction func unwindToSiteList(sender: UIStoryboardSegue) {
        if let siteViewController = sender.source as? SiteViewController, let site = siteViewController.site {
            if !Project.isValid(projectIndex: projectIndex) {
                fatalError("Project was nil!")
            }
            
            // Get an index for the new cell
            let newIndexPath = IndexPath(row: DataManager.shared.projects[projectIndex].sites.count, section: 0)
            
            // Add the new site
            DataManager.shared.projects[projectIndex].sites.append(site)
            
            // Add the new site to the table
            tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
            
            // Save data
            DataManager.shared.saveProjects()
        }
    }
    
}
