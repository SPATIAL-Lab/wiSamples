//
//  DataManager.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 11/29/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import CoreLocation
import Foundation

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
    
    //MARK: Remote site fetching
    
    func fetchSites(delegate: DataManagerResponseDelegate, minLatLong: CLLocationCoordinate2D, maxLatLong: CLLocationCoordinate2D) {
        dataTask?.cancel()
        responseDelegate = delegate

        let sitesURL: URL = URL(string: "http://wateriso.utah.edu/api/sites_for_mobile.php")!
        var sitesRequest: URLRequest = URLRequest(url: sitesURL)
        
        sitesRequest.httpMethod = "POST"
        sitesRequest.addValue("application/json", forHTTPHeaderField: "ContentType")
        
        let sitesRequestBodyString: String = "{" +
            "\"latitude\": { \"Min\": \(minLatLong.latitude), \"Max\": \(maxLatLong.latitude) }," +
            "\"longitude\": { \"Min\": \(minLatLong.longitude), \"Max\": \(maxLatLong.longitude) }" +
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
            print("Couldn't get JSON from response!")
            return
        }
        
        guard let dict = json as? [String: Any] else {
            print("Couldn't parse response!")
            return
        }
        
        guard let sitesDict = dict["sites"] as? [Any] else {
            print("Couldn't get sites from response!")
            return
        }
        
        var sites: [Site] = []
        for siteFromDict in sitesDict {
            guard let siteDict = siteFromDict as? [String: Any] else {
                print("Couldn't get site from response")
                return
            }
            
            let id = siteDict["Site_ID"] as? String
            let name = siteDict["Site_Name"] as? String
            let latitude = siteDict["Latitude"] as? Double
            let longitude = siteDict["Longitude"] as? Double
            let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            
            let site: Site = Site(id: id ?? "nil", name: name ?? "", location: coordinate)!
            
            sites.append(site)
        }
        
        self.responseDelegate?.receiveSites(errorMessage: self.errorMessage, sites: sites)
        self.responseDelegate = nil
    }
    
    func fetchAllSites() {
        
    }
    
    //MARK: Data exporting
    
    func exportSelectedProjects(selectedProjects: [Project]) -> (projectsString: String, sitesString: String, samplesString: String) {
        // Create containers
        var projectsString = "Project_ID,Contact_Name,Contact_Email,Citation,URL,Project_Name,Proprietary\n"
        var sitesString = "Site_ID,Site_Name,Latitude,Longitude,Elevation_mabsl,Address,City,State_or_Province,Country,Site_Comments\n"
        var samplesString = "Sample_ID,Sample_ID_2,Site_ID,Type,Start_Date,Start_Time,Collection_Date,Collection_Time,Sample_Volume_ml,Collector_type,Phase,Depth_meters,Sample_Source,Sample_Ignore,Sample_Comments,Project_ID\n"
        
        // Export each project
        for project in selectedProjects {
            projectsString.append(exportSingle(project: project))
            
            // Export each site
            for site in project.sites {
                sitesString.append(exportSingle(site: site, project: project))
            }
            
            // Export each sample
            for sample in project.samples {
                samplesString.append(exportSingle(sample: sample, project: project))
            }
        }
        
        return (projectsString, sitesString, samplesString)
    }
    
    private func exportSingle(project: Project) -> String {
        return "\(project.name),\(project.contactName),\(project.contactEmail),,,\(project.name)\n"
    }
    
    private func exportSingle(site: Site, project: Project) -> String {
        let elevationString: String = site.elevation < 0 ? "" : String(site.elevation)
        
        return "\(site.id),\(site.name),\(Double(site.location.latitude)),\(Double(site.location.longitude)),\(elevationString),\(site.address),\(site.city),\(site.stateOrProvince),\(site.country),\(site.comments)\n"
    }
    
    private func exportSingle(sample: Sample, project: Project) -> String {
        var startDateString: String = ""
        var startTimeString: String = ""
        if sample.startDateTime.compare(Date.distantFuture) == ComparisonResult.orderedAscending {
            startDateString = DateFormatter.localizedString(from: sample.startDateTime, dateStyle: .short, timeStyle: .none)
            startTimeString = DateFormatter.localizedString(from: sample.startDateTime, dateStyle: .none, timeStyle: .short)
        }
        
        let collectionDateString: String = DateFormatter.localizedString(from: sample.dateTime, dateStyle: .short, timeStyle: .none)
        let collectionTimeString: String = DateFormatter.localizedString(from: sample.dateTime, dateStyle: .none, timeStyle: .short)
        let depthString: String = sample.depth < 0 ? "" : String(sample.depth)
        let volumeString: String = sample.volume < 0 ? "" : String(sample.volume)
        
        return "\(sample.id),,\(sample.siteID),\(sample.type.description),\(startDateString),\(startTimeString),\(collectionDateString),\(collectionTimeString),\(volumeString),,\(sample.phase.description),\(depthString),,,\(sample.comments),\(project.name)\n"
    }
}
