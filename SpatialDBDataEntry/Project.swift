//
//  Project.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation
import os.log
import CoreLocation

class Project: NSObject, NSCoding {
    
    //MARK: Globals
    
    static var enableSampleProjects: Bool = false
    static var projects: [Project] = [Project]()
    
    //MARK: Properties
    
    var name: String
    var contactName: String
    var contactEmail: String
    var sampleIDPrefix: String
    var sites: [Site]
    var samples: [Sample]
    
    //MARK: Archiving paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("projects")
    
    //MARK: Types
    
    struct PropertyKeys {
        // Project data
        static let projectName = "projectName"
        static let contactName = "contactName"
        static let contactEmail = "contactEmail"
        static let sampleIDPrefix = "sampleIDPrefix"
        static let sites = "sites"
        static let samples = "samples"
    }
    
    //MARK: Initialization
    
    init?(name: String, contactName: String, contactEmail: String, sampleIDPrefix: String, sites: [Site]?, samples: [Sample]?) {
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.contactName = contactName
        self.contactEmail = contactEmail
        self.sampleIDPrefix = sampleIDPrefix
        self.sites = sites ?? []
        self.samples = samples ?? []
    }
    
    //MARK: Behavior
    
    func getIDForNewSample() -> String {
        if samples.count > 0 {
            let lastSample = samples[samples.count - 1]
            let splitSampleID = lastSample.id.components(separatedBy: sampleIDPrefix + String("SAMPLE-"))
            if splitSampleID.count > 1 {
                let newSampleID = Int(splitSampleID[1])! + 1
                return sampleIDPrefix + String(format: "SAMPLE-%02d", newSampleID)
            }
        }
        
        return sampleIDPrefix + String(format: "SAMPLE-%02d", samples.count + 1)
    }
    
    func getIDForNewSite() -> String {
        if sites.count > 0 {
            let lastSite = sites[sites.count - 1]
            let splitSiteID = lastSite.id.components(separatedBy: sampleIDPrefix + String("SITE-"))
            if splitSiteID.count > 1 {
                let newSiteID = Int(splitSiteID[1])! + 1
                return sampleIDPrefix + String(format: "SITE-%02d", newSiteID)
            }
        }
        
        return sampleIDPrefix + String(format: "SITE-%02d", sites.count + 1)
    }
    
    //MARK: Global Data Helpers
    
    static func isValid(projectIndex: Int) -> Bool {
        return projectIndex >= 0 && projectIndex < projects.count
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKeys.projectName)
        aCoder.encode(contactName, forKey: PropertyKeys.contactName)
        aCoder.encode(contactEmail, forKey: PropertyKeys.contactEmail)
        aCoder.encode(sampleIDPrefix, forKey: PropertyKeys.sampleIDPrefix)
        aCoder.encode(sites, forKey: PropertyKeys.sites)
        aCoder.encode(samples, forKey: PropertyKeys.samples)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKeys.projectName) as? String else {
            os_log("Unable to decode the name for a Project object!", log: OSLog.default, type: OSLogType.debug)
            return nil
        }
        
        let contactName = aDecoder.decodeObject(forKey: PropertyKeys.contactName) as? String
        let contactEmail = aDecoder.decodeObject(forKey: PropertyKeys.contactEmail) as? String
        let sampleIDPrefix = aDecoder.decodeObject(forKey: PropertyKeys.sampleIDPrefix) as? String
        let sites = aDecoder.decodeObject(forKey: PropertyKeys.sites) as? [Site]
        let samples = aDecoder.decodeObject(forKey: PropertyKeys.samples) as? [Sample]
        
        self.init(name: name, contactName: contactName!, contactEmail: contactEmail!, sampleIDPrefix: sampleIDPrefix!, sites: sites!, samples: samples!)
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
        if enableSampleProjects {
            deleteSavedProjects()
            loadSampleProjects()
            return
        }
        
        if let savedProjects = NSKeyedUnarchiver.unarchiveObject(withFile: Project.ArchiveURL.path) as? [Project] {
            projects = savedProjects
            os_log("Projects loaded successfully.", log: .default, type: .debug)
        }
        else {
            os_log("Projects failed to load!", log: .default, type: .debug)
        }
    }
    
    //MARK: Private Methods
    
    private static func loadSampleProjects() {
        let location = CLLocationCoordinate2DMake(CLLocationDegrees(40.764941), CLLocationDegrees(-111.842194))
        
        guard let site1 = Site(id: "TP1-JD-SITE-01", name: "Site_01", location: location) else {
            fatalError("Unable to instantiate site1")
        }
        
        let date = Date()
        guard let sample1 = Sample(id: "TP1-JD-SAMPLE-01", siteID: "TP1-JD-SITE-01", type: SampleType.lake, dateTime: date, startDateTime: date) else {
            fatalError("Unable to instantiate sample1")
        }
        
        guard let project1 = Project(name: "TestProject_01", contactName: "John Doe", contactEmail: "", sampleIDPrefix: "TP1-JD-", sites: [site1], samples: [sample1]) else {
            fatalError("Unable to instantiate project1")
        }
        
        projects += [project1]
        
        os_log("Sample projects loaded successfully.", log: .default, type: .debug)
    }
    
    private static func deleteSavedProjects() {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: Project.ArchiveURL.path)
            os_log("Saved projects deleted successfully.", log: .default, type: .debug)
        }
        catch {
            os_log("Failed to delete failed projects!", log: .default, type: .debug)
        }
    }
}
