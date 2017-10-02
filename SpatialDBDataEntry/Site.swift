//
//  Site.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation
import os.log

class Site: NSObject, NSCoding {
    
    //MARK: Properties
    
    var id: String
    var name: String
    
    //MARK: Types
    
    struct PropertyKeys {
        // Site data
        static let siteID = "siteID"
        static let siteName = "siteName"
    }
    
    //MARK: Initialization
    
    init?(id: String, name: String) {
        guard !id.isEmpty else {
            return nil
        }
        
        self.id = id
        self.name = name
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKeys.siteID)
        aCoder.encode(name, forKey: PropertyKeys.siteName)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: PropertyKeys.siteID) as? String else {
            os_log("Unable to decode the id for a Site object!", log: .default, type: .debug)
            return nil
        }
        
        let name = aDecoder.decodeObject(forKey: PropertyKeys.siteName) as? String
        
        self.init(id: id, name: name!)
    }
}
