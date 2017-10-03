//
//  Project.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation
import os.log

enum ProjectEditResult: Int {
    // Project edit results
    // Load
    case loadProjectsFailure
    case loadProjectsSuccess
    // Save
    case saveProjectsFailure
    case saveProjectsSuccess
    // Add
    case addProjectFailureIdExists
    case addProjectSuccess
    // Remove
    case removeProjectFailureNotFound
    case removeProjectSuccess
    
    // Site edit results
    // Add
    case addSiteFailureIdExists
    case addSiteFailureProjectNotFound
    case addSiteSuccess
    // Remove
    case removeSiteFailureNotFound
    case removeSiteFailureProjectNotFound
    case removeSiteSuccess
    
    var description : String {
        switch self {
        case .loadProjectsFailure: return "loadProjectsFailure"
        case .loadProjectsSuccess: return "loadProjectsSuccess"
        case .saveProjectsFailure: return "saveProjectsFailure"
        case .saveProjectsSuccess: return "saveProjectsSuccess"
        case .addProjectFailureIdExists: return "addProjectFailureIdExists"
        case .addProjectSuccess: return "addProjectSuccess"
        case .removeProjectFailureNotFound: return "removeProjectFailureNotFound"
        case .removeProjectSuccess: return "removeProjectSuccess"
        case .addSiteFailureIdExists: return "addSiteFailureIdExists"
        case .addSiteFailureProjectNotFound: return "addSiteFailureProjectNotFound"
        case .addSiteSuccess: return "addSiteSuccess"
        case .removeSiteFailureNotFound: return "removeSiteFailureNotFound"
        case .removeSiteFailureProjectNotFound: return "removeSiteFailureProjectNotFound"
        case .removeSiteSuccess: return "removeSiteSuccess"
        }
    }
}

class Project: NSObject, NSCoding {
    
    //MARK: Globals
    
    private static var projectsMasterList: [Project] = [Project]()
    
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
    
    //MARK: Global Data Access
    
    static func getProjects() -> [Project] {
        return Project.projectsMasterList
    }
    
    static func addNew(project: Project) -> ProjectEditResult {
        // Check if an existing project has the same id as the new one
        for existingProject in Project.projectsMasterList {
            if existingProject.id == project.id {
                return ProjectEditResult.addProjectFailureIdExists
            }
        }
        
        // Add the new project
        Project.projectsMasterList.append(project)
        
        // Save
        Project.saveProjects()
        
        return ProjectEditResult.addProjectSuccess
    }
    
    static func removeExisting(project: Project) -> ProjectEditResult {
        // Check if the project exists
        if let projectIndex = Project.projectsMasterList.index(of: project) {
            // Remove the project
            Project.projectsMasterList.remove(at: projectIndex)
            
            // Save
            Project.saveProjects()
            
            return ProjectEditResult.removeProjectSuccess
        }
        
        return ProjectEditResult.removeProjectFailureNotFound
    }
    
    static func addNew(site: Site, toProject: Project) -> ProjectEditResult {
        // Check if the project exists
        if let projectIndex = Project.projectsMasterList.index(of: toProject) {
            // Check if an existing site has the same id as the new one
            for existingSite in Project.projectsMasterList[projectIndex].sites {
                if existingSite.id == site.id {
                    return ProjectEditResult.addSiteFailureIdExists
                }
            }
            
            // Add the new site
            Project.projectsMasterList[projectIndex].sites.append(site)
            
            // Save
            Project.saveProjects()
            
            return ProjectEditResult.addSiteSuccess
        }
        
        return ProjectEditResult.addSiteFailureProjectNotFound
    }
    
    static func removeExisting(site: Site, fromProject: Project) -> ProjectEditResult {
        // Check if the project exists
        if let projectIndex = Project.projectsMasterList.index(of: fromProject) {
            // Check if the site exists
            if let siteIndex = Project.projectsMasterList[projectIndex].sites.index(of: site) {
                // Remove the site
                Project.projectsMasterList[projectIndex].sites.remove(at: siteIndex)
                
                // Save
                Project.saveProjects()
                
                return ProjectEditResult.removeSiteSuccess
            }
            
            return ProjectEditResult.removeSiteFailureNotFound
        }
        
        return ProjectEditResult.removeSiteFailureProjectNotFound
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
    
    static func saveProjects() -> ProjectEditResult {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(Project.projectsMasterList, toFile: Project.ArchiveURL.path)
        return isSuccessfulSave ? ProjectEditResult.saveProjectsSuccess : ProjectEditResult.saveProjectsFailure
    }
    
    static func loadProjects() -> ProjectEditResult {
        if let loadedProjects = NSKeyedUnarchiver.unarchiveObject(withFile: Project.ArchiveURL.path) as? [Project] {
            Project.projectsMasterList = loadedProjects
            return ProjectEditResult.loadProjectsSuccess
        }
        
        return ProjectEditResult.loadProjectsFailure
    }
}
