//
//  ExportProjectsTableViewController.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 1/30/18.
//  Copyright © 2018 University of Utah. All rights reserved.
//

import MessageUI
import UIKit

class ExportProjectsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    //MARK: Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Table view data source

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
    
    //MARK: MailMFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check if mail was sent
        if result == .sent {
            // Add another dismiss so we're back to the settings screen
            dismiss(animated: true, completion: nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Actions
    
    @IBAction func cancelSelectingProjects(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneSelectingProjects(_ sender: UIBarButtonItem) {
        // Get selected projects to a list
        let selectedProjects: [Project] = getSelectedProjects()
        
        if selectedProjects.isEmpty {
            dismiss(animated: true, completion: nil)
            return
        }
        
        // Ask the data manager to create CSVs and email them
        let (projectsString, sitesString, samplesString) = DataManager.shared.exportSelectedProjects(selectedProjects: selectedProjects)
        
        if MFMailComposeViewController.canSendMail() {
            let emailController = MFMailComposeViewController()
            emailController.mailComposeDelegate = self
            emailController.setToRecipients([])
            emailController.setSubject("Projects Export")
            emailController.setMessageBody("Please find attached.", isHTML: false)
            
            emailController.addAttachmentData(projectsString.data(using: .utf8)!, mimeType: "text/csv", fileName: "Projects.csv")
            emailController.addAttachmentData(sitesString.data(using: .utf8)!, mimeType: "text/csv", fileName: "Sites.csv")
            emailController.addAttachmentData(samplesString.data(using: .utf8)!, mimeType: "text/csv", fileName: "Samples.csv")
            
            present(emailController, animated: true, completion: nil)
        }
    }

    //MARK: Methods
    
    private func getSelectedProjects() -> [Project] {
        var selectedProjects: [Project] = []
        
        for index in 0...Project.projects.count {
            let indexPath = IndexPath(row: index, section: 0)
            if let exportProjectCell = tableView!.cellForRow(at: indexPath) as? ExportProjectsTableViewCell {
                if exportProjectCell.selectedSwitch.isOn {
                    selectedProjects.append(Project.projects[index])
                }
            }
        }
        
        return selectedProjects
    }

}
