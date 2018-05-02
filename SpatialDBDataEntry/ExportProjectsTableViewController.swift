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
        return DataManager.shared.projects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ExportProjectsTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ExportProjectsTableViewCell else {
            fatalError("The dequeued cell is not an instance of ExportProjectsTableViewCell!")
        }
        
        let project = DataManager.shared.projects[indexPath.row]
        
        cell.projectNameLabel.text = project.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedProjects: [Project] = []
        
        selectedProjects.append(DataManager.shared.projects[indexPath.row])
        
        // Ask the data manager to create CSVs and email them
        let (projectsString, sitesString, samplesString) = DataManager.shared.exportSelectedProjects(selectedProjects: selectedProjects)
        
        if MFMailComposeViewController.canSendMail() {
            let emailController = MFMailComposeViewController()
            emailController.mailComposeDelegate = self
            emailController.setToRecipients([selectedProjects[1].contactEmail]) //attempt to set default email
            emailController.setSubject("Project Export")
            emailController.setMessageBody("Please find attached.", isHTML: false)
            
            emailController.addAttachmentData(projectsString.data(using: .utf8)!, mimeType: "text/csv", fileName: "Projects.csv")
            emailController.addAttachmentData(sitesString.data(using: .utf8)!, mimeType: "text/csv", fileName: "Sites.csv")
            emailController.addAttachmentData(samplesString.data(using: .utf8)!, mimeType: "text/csv", fileName: "Samples.csv")
            
            present(emailController, animated: true, completion: nil)
        }
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
    
    @IBAction func doneExportingProjects(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func doneSelectingProjects(_ sender: UIBarButtonItem) {
//        // Get selected projects to a list
//        let selectedProjects: [Project] = getSelectedProjects()
//        
//        if selectedProjects.isEmpty {
//            dismiss(animated: true, completion: nil)
//            return
//        }
//        
//        // Ask the data manager to create CSVs and email them
//        let (projectsString, sitesString, samplesString) = DataManager.shared.exportSelectedProjects(selectedProjects: selectedProjects)
//        
//        if MFMailComposeViewController.canSendMail() {
//            let emailController = MFMailComposeViewController()
//            emailController.mailComposeDelegate = self
//            emailController.setToRecipients([])
//            emailController.setSubject("Projects Export")
//            emailController.setMessageBody("Please find attached.", isHTML: false)
//            
//            emailController.addAttachmentData(projectsString.data(using: .utf8)!, mimeType: "text/csv", fileName: "Projects.csv")
//            emailController.addAttachmentData(sitesString.data(using: .utf8)!, mimeType: "text/csv", fileName: "Sites.csv")
//            emailController.addAttachmentData(samplesString.data(using: .utf8)!, mimeType: "text/csv", fileName: "Samples.csv")
//            
//            present(emailController, animated: true, completion: nil)
//        }
//    }

}
