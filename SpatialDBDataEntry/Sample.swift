//
//  Sample.swift
//  SpatialDBDataEntry
//
//  Created by Karan Sequeira on 10/11/17.
//  Copyright © 2017 University of Utah. All rights reserved.
//

import Foundation
import os.log
import CoreLocation

enum SampleType: Int {
    case invalid
    case ground
    case lake
    case riverOrStream
    case tap
    case precipitation
    case spring
    case ocean
    case irrigation
    case bottled
    case iceCore
    case snowPit
    case firnCore
    case vapor
    case canal
    case sprinkler
    case mine
    case cloudWater
    
    var description: String {
        switch self {
        case .invalid:              return "Invalid"
        case .ground:               return "Ground"
        case .lake:                 return "Lake"
        case .riverOrStream:        return "River or Stream"
        case .tap:                  return "Tap"
        case .precipitation:        return "Precipitation"
        case .spring:               return "Spring"
        case .ocean:                return "Ocean"
        case .irrigation:           return "Irrigation"
        case .bottled:              return "Bottled"
        case .iceCore:              return "Ice Core"
        case .snowPit:              return "Snow Pit"
        case .firnCore:             return "Firn Core"
        case .vapor:                return "Vapor"
        case .canal:                return "Canal"
        case .sprinkler:            return "Sprinkler"
        case .mine:                 return "Mine"
        case .cloudWater:           return "Cloud Water"
        }
    }
}

class Sample: NSObject, NSCoding {
    
    //MARK: Properties
    
    var id: String
    var location: CLLocationCoordinate2D
    var type: SampleType
    var dateTime: Date
    var startDateTime: Date
    
    //MARK: Types
    
    struct PropertyKeys {
        static let sampleID = "sampleID"
        static let location = "location"
        static let type = "sampleType"
        static let dateTime = "dateTime"
        static let startDateTime = "startDateTime"
    }
    
    //MARK: Initialization
    
    init?(id: String, location: CLLocationCoordinate2D, type: SampleType, dateTime: Date, startDateTime: Date) {
        guard !id.isEmpty else {
            return nil
        }
        
        self.id = id
        self.location = location
        self.type = type
        self.dateTime = dateTime
        self.startDateTime = startDateTime
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKeys.sampleID)
        aCoder.encode(location, forKey: PropertyKeys.location)
        aCoder.encode(type, forKey: PropertyKeys.type)
        aCoder.encode(dateTime, forKey: PropertyKeys.dateTime)
        aCoder.encode(startDateTime, forKey: PropertyKeys.startDateTime)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(forKey: PropertyKeys.sampleID) as? String else {
            os_log("Unable to decode the id for a Site object!", log: .default, type: .debug)
            return nil
        }
        
        let location = aDecoder.decodeObject(forKey: PropertyKeys.location) as? CLLocationCoordinate2D
        let type = aDecoder.decodeObject(forKey: PropertyKeys.type) as? SampleType
        let dateTime = aDecoder.decodeObject(forKey: PropertyKeys.dateTime) as? Date
        let startDateTime = aDecoder.decodeObject(forKey: PropertyKeys.startDateTime) as? Date
        
        self.init(id: id, location: location!, type: type!, dateTime: dateTime!, startDateTime: startDateTime!)
    }
    
}
