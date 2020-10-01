//
//  Site.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 9/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation
import os.log
import CoreLocation

class Site: NSObject, NSCoding {
    
    //MARK: Properties
    
    var id: String
    var name: String
    var location: CLLocationCoordinate2D
    var elevation: Double = -9999
    var address: String = ""
    var city: String = ""
    var stateOrProvince: String = ""
    var country: String = ""
    var comments: String = ""
    
    //MARK: Types
    
    struct PropertyKeys {
        // Site data
        static let siteID = "siteID"
        static let siteName = "siteName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let elevation = "elevation"
        static let address = "address"
        static let city = "city"
        static let stateOrProvince = "stateOrProvince"
        static let country = "country"
        static let comments = "siteComments"
    }
    
    //MARK: Initialization
    
    @objc init?(id: String, name: String, location: CLLocationCoordinate2D) {
        guard !id.isEmpty else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.location = location
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKeys.siteID)
        aCoder.encode(name, forKey: PropertyKeys.siteName)
        aCoder.encode(Double(location.latitude), forKey: PropertyKeys.latitude)
        aCoder.encode(Double(location.longitude), forKey: PropertyKeys.longitude)
        aCoder.encode(elevation, forKey: PropertyKeys.elevation)
        aCoder.encode(address, forKey: PropertyKeys.address)
        aCoder.encode(city, forKey: PropertyKeys.city)
        aCoder.encode(stateOrProvince, forKey: PropertyKeys.stateOrProvince)
        aCoder.encode(country, forKey: PropertyKeys.country)
        aCoder.encode(comments, forKey: PropertyKeys.comments)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: PropertyKeys.siteID) as? String else {
            os_log("Unable to decode the id for a Site object!", log: .default, type: .debug)
            return nil
        }
        
        let name = aDecoder.decodeObject(forKey: PropertyKeys.siteName) as? String
        let latitude = aDecoder.decodeDouble(forKey: PropertyKeys.latitude)
        let longitude = aDecoder.decodeDouble(forKey: PropertyKeys.longitude)
        let location = CLLocationCoordinate2DMake(CLLocationDegrees(latitude), CLLocationDegrees(longitude))
        let elevation = aDecoder.decodeDouble(forKey: PropertyKeys.elevation)
        let address = aDecoder.decodeObject(forKey: PropertyKeys.address) as? String
        let city = aDecoder.decodeObject(forKey: PropertyKeys.city) as? String
        let stateOrProvince = aDecoder.decodeObject(forKey: PropertyKeys.stateOrProvince) as? String
        let country = aDecoder.decodeObject(forKey: PropertyKeys.country) as? String
        let comments = aDecoder.decodeObject(forKey: PropertyKeys.comments) as? String
        
        self.init(id: id, name: name!, location: location)
        
        self.elevation = elevation
        self.address = address ?? ""
        self.city = city ?? ""
        self.stateOrProvince = stateOrProvince ?? ""
        self.country = country ?? ""
        self.comments = comments ?? ""
    }
}
