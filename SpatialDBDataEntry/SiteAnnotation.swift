//
//  SiteAnnotation.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 11/3/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation
import MapKit
import os.log

class SiteAnnotation: NSObject,
MKAnnotation {
    
    //MARK: Properties
    
    var id: String = ""
    var name: String = ""
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var elevation: Double = -1
    var address: String = ""
    var city: String = ""
    var stateOrProvince: String = ""
    var country: String = ""
    var comments: String = ""
    
    var title: String?
    var subtitle: String?
    
    //MARK: Initialization
    
    init(id: String, name: String, coordinate: CLLocationCoordinate2D, elevation: Double, address: String, city: String, stateOrProvince: String, country: String, comments: String) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.elevation = elevation
        self.address = address
        self.city = city
        self.stateOrProvince = stateOrProvince
        self.country = country
        self.comments = comments
        
        self.title = id
        self.subtitle = name
    }
    
    //MARK: Global Data Helpers
    
    static func loadSitesFromFile(withName: String) -> [SiteAnnotation] {
        var siteAnnotationList: [SiteAnnotation] = []
        
        guard let fileName = Bundle.main.path(forResource: withName, ofType: "json") else {
            os_log("Couldn't find SampleSites.json!", log: .default, type: .debug)
            return siteAnnotationList
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fileName)) else {
            os_log("Couldn't load SampleSites.json!", log: .default, type: .debug)
            return siteAnnotationList
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            os_log("Couldn't deserialize SampleSites.json!", log: .default, type: .debug)
            return siteAnnotationList
        }
        
        guard let dict = json as? [String: Any] else {
            os_log("Couldn't parse SampleSites.json!", log: .default, type: .debug)
            return siteAnnotationList
        }
        
        guard let sites = dict["sites"] as? [Any] else {
            os_log("Couldn't get sites from SampleSites.json!", log: .default, type: .debug)
            return siteAnnotationList
        }
        
        for site in sites {
            guard let siteDict = site as? [String: Any] else {
                os_log("Couldn't get site from SampleSites.json")
                return siteAnnotationList
            }
            
            let id = siteDict["Site_ID"] as? String
            let name = siteDict["Site_Name"] as? String
            let latitude = siteDict["Latitude"] as? Double
            let longitude = siteDict["Longitude"] as? Double
            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            let elevation = siteDict["Elevation_mabsl"] as? Double
            let address = siteDict["Address"] as? String
            let city = siteDict["City"] as? String
            let stateOrProvince = siteDict["State_or_Province"] as? String
            let country = siteDict["Country"] as? String
            let comments = siteDict["Site_Comments"] as? String
            
            let siteAnnotation = SiteAnnotation(id: id ?? "",
                                                name: name ?? "",
                                                coordinate: coordinate,
                                                elevation: elevation!,
                                                address: address ?? "",
                                                city: city ?? "",
                                                stateOrProvince: stateOrProvince ?? "",
                                                country: country ?? "",
                                                comments: comments ?? "")
            siteAnnotationList.append(siteAnnotation)
        }
        
        return siteAnnotationList
    }
    
}
