//
//  DataManager.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 11/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation
import CoreLocation
import os.log

protocol DataManagerResponseDelegate: class {
    func receiveSites(errorMessage: String, sites: [Site])
}

class DataManager: NSObject
{
    static var shared: DataManager = DataManager()
    
    let session: URLSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var responseDelegate: DataManagerResponseDelegate?
    var errorMessage: String = ""
    
    func fetchSites(delegate: DataManagerResponseDelegate, location: CLLocation, rangeInKM: Double) {
        dataTask?.cancel()
        responseDelegate = delegate

        let sitesURL: URL = URL(string: "http://wateriso.utah.edu/api/sites.php")!
        var sitesRequest: URLRequest = URLRequest(url: sitesURL)
        
        sitesRequest.httpMethod = "POST"
        sitesRequest.addValue("application/json", forHTTPHeaderField: "ContentType")
        
        let latitude: Double = Double(location.coordinate.latitude)
        let longitude: Double = Double(location.coordinate.longitude)
        
        let radiusEarth: Double = 6378;
        let radiansToDegrees: Double = 180 / Double.pi
        let degreesToRadians: Double = Double.pi / 180
        
        let minLatitude = latitude - (rangeInKM / radiusEarth) * radiansToDegrees
        let maxLatitude = latitude + (rangeInKM / radiusEarth) * radiansToDegrees
        let minLongitude = longitude - (rangeInKM / radiusEarth) * radiansToDegrees / cos(latitude * degreesToRadians)
        let maxLongitude = longitude + (rangeInKM / radiusEarth) * radiansToDegrees / cos(latitude * degreesToRadians)
        
        let sitesRequestBodyString: String = "{" +
            "\"latitude\": { \"Min\": \(minLatitude), \"Max\": \(maxLatitude) }," +
            "\"longitude\": { \"Min\": \(minLongitude), \"Max\": \(maxLongitude) }," +
            "\"elevation\": null," +
            "\"countries\": null," +
            "\"states\": null," +
            "\"collection_date\": null," +
            "\"types\": null," +
            "\"h2\": null," +
            "\"o18\": null," +
            "\"project_ids\": null" +
        "}"
        
        let sitesRequestBodyData: Data = sitesRequestBodyString.data(using: .utf8)!
        sitesRequest.httpBody = sitesRequestBodyData
        
        dataTask = session.dataTask(with: sitesRequest) { data, response, error in
            defer { self.dataTask = nil }
            
            if let error = error {
                self.errorMessage += error.localizedDescription
            }
            else if let data = data {
                DispatchQueue.main.async {
                    self.receiveSites(data)
                }
            }
        }
        
        dataTask?.resume()
    }
    
    func receiveSites(_ data: Data) {
        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            os_log("Couldn't get JSON from response!", log: .default, type: .debug)
            return
        }
        
        guard let dict = json as? [String: Any] else {
            os_log("Couldn't parse response!", log: .default, type: .debug)
            return
        }
        
        guard let sitesDict = dict["sites"] as? [Any] else {
            os_log("Couldn't get sites from response!", log: .default, type: .debug)
            return
        }
        
        var sites: [Site] = []
        for siteFromDict in sitesDict {
            guard let siteDict = siteFromDict as? [String: Any] else {
                os_log("Couldn't get site from response")
                return
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
            
            let site: Site = Site(id: id!, name: name ?? "", location: coordinate)!
            
            // Fill in the remaining information
            site.elevation = elevation ?? 0
            site.address = address ?? ""
            site.city = city ?? ""
            site.stateOrProvince = stateOrProvince ?? ""
            site.country = country ?? ""
            site.comments = comments ?? ""
            
            sites.append(site)
        }
        
        self.responseDelegate?.receiveSites(errorMessage: self.errorMessage, sites: sites)
        self.responseDelegate = nil
    }
}
