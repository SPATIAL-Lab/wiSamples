//
//  Project.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation

class Project {
    
    //MARK: Properties
    
    var id: String
    var name: String
    var contactName: String
    var contactEmail: String
    
    //MARK: Initialization
    
    init?(id: String, name: String, contactName: String, contactEmail: String) {
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
    }
}
