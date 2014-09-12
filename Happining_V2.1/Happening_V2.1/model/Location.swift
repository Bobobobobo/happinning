//
//  Location.swift
//  Happining_V2.1
//
//  Created by Tanthawat Khemavast on 28/8/14.
//  Copyright (c) 2014 Kan Boonprakub. All rights reserved.
//

import Foundation
import CoreLocation

class Location {
    
    var type: String
    var locality: String
    var subLocality: String
    var coordinate: CLLocationCoordinate2D
    
    init(type: String, locality: String, subLocality: String, latitude: Double, longitude: Double) {
        self.type = type
        self.locality = locality
        self.subLocality = subLocality
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(locationDict: NSDictionary) {
        self.type = locationDict["type"] as String
        self.locality = locationDict["locality"] as String
        self.subLocality = locationDict["subLocality"] as String
        var tempCoordinate: NSArray = locationDict["coordinates"] as NSArray
        self.coordinate = CLLocationCoordinate2D(latitude: tempCoordinate[1] as Double, longitude: tempCoordinate[0] as Double)
    }
}