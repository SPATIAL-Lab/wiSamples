//
//  ExportProjectsTableViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 1/30/18.
//  Copyright © 2018 University of Utah. All rights reserved.
//

import UIKit

class ExportProjectsTableViewController: UITableViewController {

    //MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Project.projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ExportProjectsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ExportProjectsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ExportProjectsTableViewCell!")
        }
        
        let project = Project.projects[indexPath.row]
        
        cell.projectNameLabel.text = project.name
        
        return cell
    }

    //MARK: Methods
    
    func getSelectedProjectIndices() -> [Int] {
        var selectedIndices: [Int] = []
        
        for index in 0...Project.projects.count {
            let indexPath = IndexPath(row: index, section: 0)
            if let exportProjectCell = tableView!.cellForRow(at: indexPath) as? ExportProjectsTableViewCell {
                if exportProjectCell.selectedSwitch.isOn {
                    selectedIndices.append(index)
                }
            }
        }
        
        return selectedIndices
    }

}
