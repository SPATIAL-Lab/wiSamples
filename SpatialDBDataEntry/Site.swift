//
//  Site.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation

class Site {
    
    //MARK: Properties
    
    var id: String
    var name: String
    
    //MARK: Initialization
    
    init?(id: String, name: String) {
        guard !id.isEmpty else {
            return nil
        }
        
        self.id = id
        self.name = name
    }
}
