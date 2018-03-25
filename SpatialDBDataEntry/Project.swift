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
        var newSampleID: Int = samples.count
        if newSampleID > 0 {
            for sample in samples {
                let splitSampleID = sample.id.components(separatedBy: sampleIDPrefix)
                if splitSampleID.count > 1 {
                    let afterPrefix = splitSampleID[1]
                    if let numberPartEndIndex = afterPrefix.index(afterPrefix.startIndex, offsetBy: 3, limitedBy: afterPrefix.endIndex) {
                        let numberPart = afterPrefix.substring(to: numberPartEndIndex)
                        if let number = Int(numberPart) {
                            newSampleID = number > newSampleID ? number : newSampleID
                        }
                    }
                }
            }
        }
        
        return sampleIDPrefix + String(format: "%03d", newSampleID + 1)
    }
    
    func getIDForNewSite() -> String {
        var newSiteID: Int = sites.count
        if newSiteID > 0 {
            for site in sites {
                let splitSiteID = site.id.components(separatedBy: sampleIDPrefix + String("SITE-"))
                if splitSiteID.count > 1 {
                    let afterPrefix = splitSiteID[1]
                    if let numberPartEndIndex = afterPrefix.index(afterPrefix.startIndex, offsetBy: 3, limitedBy: afterPrefix.endIndex) {
                        let numberPart = afterPrefix.substring(to: numberPartEndIndex)
                        if let number = Int(numberPart) {
                            newSiteID = number > newSiteID ? number : newSiteID
                        }
                    }
                }
            }
        }
        
        return sampleIDPrefix + String(format: "SITE-%03d", newSiteID + 1)
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
