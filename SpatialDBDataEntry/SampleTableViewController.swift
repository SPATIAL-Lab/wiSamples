//
//  SampleTableViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/9/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import UIKit

class SampleTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var projectIndex: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !Project.isValid(projectIndex: projectIndex) {
            fatalError("Project was nil!")
        }
        
        navigationItem.title = "Samples"
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
        return DataManager.shared.projects[projectIndex].samples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SampleTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SampleTableViewCell else {
            fatalError("The dequequed cell is not an instance of SampleTableViewCell!")
        }
        
        let sample = DataManager.shared.projects[projectIndex].samples[indexPath.row]
        
        cell.sampleIDLabel.text = sample.id
        
        return cell
    }

    // Support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the sample
            DataManager.shared.projects[projectIndex].samples.remove(at: indexPath.row)
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Save data
            DataManager.shared.saveProjects()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "AddNewSample":
            guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            
            guard let sampleViewController = navigationController.viewControllers[0] as? SampleViewController else {
                fatalError("Unexpected presented view controller \(navigationController.presentedViewController)")
            }
            
            sampleViewController.projectIndex = projectIndex
            sampleViewController.generatedSampleID = DataManager.shared.projects[projectIndex].getIDForNewSample()
            
        case "ShowSample":            
            guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination \(segue.destination)")
            }
            
            guard let sampleViewController = navigationController.viewControllers[0] as? SampleViewController else {
                fatalError("Unexpected presented view controller \(navigationController.presentedViewController)")
            }
            
            guard let selectedSampleCell = sender as? SampleTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedSampleCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedSample = DataManager.shared.projects[projectIndex].samples[indexPath.row]
            sampleViewController.projectIndex = projectIndex
            sampleViewController.sample = selectedSample
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
    }
    
    //MARK: Actions
    
    @IBAction func unwindToSampleList(sender: UIStoryboardSegue) {
        if let sampleViewController = sender.source as? SampleViewController, let sample = sampleViewController.sample {
            if !Project.isValid(projectIndex: projectIndex) {
                fatalError("Project was nil!")
            }
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing sample
                DataManager.shared.projects[projectIndex].samples[selectedIndexPath.row] = sample
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Get an index for the new cell
                let newIndexPath = IndexPath(row: DataManager.shared.projects[projectIndex].samples.count, section: 0)
                
                // Add the new sample
                DataManager.shared.projects[projectIndex].samples.append(sample)
                
                // Add the new sample to the table
                tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.automatic)
            }
            
            // Save data
            DataManager.shared.saveProjects()
        }
    }

}
