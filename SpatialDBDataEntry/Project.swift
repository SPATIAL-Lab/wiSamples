//
//  Project.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation
import CoreLocation

class Project: NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String
    var contactName: String
    var contactEmail: String
    var sampleIDPrefix: String
    var sites: [Site]
    var samples: [Sample]
    
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
        return projectIndex >= 0 && projectIndex < DataManager.shared.projects.count
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
            print("Unable to decode the name for a Project object!")
            return nil
        }
        
        let contactName = aDecoder.decodeObject(forKey: PropertyKeys.contactName) as? String
        let contactEmail = aDecoder.decodeObject(forKey: PropertyKeys.contactEmail) as? String
        let sampleIDPrefix = aDecoder.decodeObject(forKey: PropertyKeys.sampleIDPrefix) as? String
        let sites = aDecoder.decodeObject(forKey: PropertyKeys.sites) as? [Site]
        let samples = aDecoder.decodeObject(forKey: PropertyKeys.samples) as? [Sample]
        
        self.init(name: name, contactName: contactName!, contactEmail: contactEmail!, sampleIDPrefix: sampleIDPrefix!, sites: sites!, samples: samples!)
    }
    
}
