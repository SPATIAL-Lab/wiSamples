//
//  Project.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation
import os.log

class Project: NSObject, NSCoding {
    
    //MARK: Globals
    
    static var projects: [Project] = [Project]()
    
    //MARK: Properties
    
    var id: String
    var name: String
    var contactName: String
    var contactEmail: String
    var sites: [Site]
    
    //MARK: Archiving paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("projects")
    
    //MARK: Types
    
    struct PropertyKeys {
        // Project data
        static let projectID = "projectID"
        static let projectName = "projectName"
        static let contactName = "contactName"
        static let contactEmail = "contactEmail"
        static let sites = "sites"
    }
    
    //MARK: Initialization
    
    init?(id: String, name: String, contactName: String, contactEmail: String, sites: [Site]?) {
        guard !id.isEmpty else {
            return nil
        }
        
        guard !name.isEmpty else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.contactName = contactName
        self.contactEmail = contactEmail
        self.sites = sites ?? []
    }
    
    //MARK: Global Data Helpers
    
    static func isValid(projectIndex: Int) -> Bool {
        return projectIndex >= 0 && projectIndex < projects.count
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKeys.projectID)
        aCoder.encode(name, forKey: PropertyKeys.projectName)
        aCoder.encode(contactName, forKey: PropertyKeys.contactName)
        aCoder.encode(contactEmail, forKey: PropertyKeys.contactEmail)
        aCoder.encode(sites, forKey: PropertyKeys.sites)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: PropertyKeys.projectID) as? String else {
            os_log("Unable to decode the id for a Project object!", log: OSLog.default, type: OSLogType.debug)
            return nil
        }
        
        let name = aDecoder.decodeObject(forKey: PropertyKeys.projectName) as? String
        let contactName = aDecoder.decodeObject(forKey: PropertyKeys.contactName) as? String
        let contactEmail = aDecoder.decodeObject(forKey: PropertyKeys.contactEmail) as? String
        let sites = aDecoder.decodeObject(forKey: PropertyKeys.sites) as? [Site]
        
        self.init(id: id, name: name!, contactName: contactName!, contactEmail: contactEmail!, sites: sites!)
    }
    
    static func saveProjects() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(projects, toFile: Project.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Projects saved successfully.", log: .default, type: .debug)
        }
        else {
            os_log("Projects failed to save!", log: .default, type: .debug)
        }
    }
    
    static func loadProjects() {
        if let savedProjects = NSKeyedUnarchiver.unarchiveObject(withFile: Project.ArchiveURL.path) as? [Project] {
            projects = savedProjects
            os_log("Projects loaded successfully.", log: .default, type: .debug)
        }
        else {
            os_log("Projects failed to load!", log: .default, type: .debug)
        }
    }
}
