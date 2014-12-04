//
//  LocationRequest.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 12/4/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

class LocationRequest: BaseRequest {

    var latitude:Double = 0.0
    var longitude:Double = 0.0

    override func urlRequest() -> NSURLRequest? {
        var params = NSDictionary(objectsAndKeys:
            self.latitude, PARAM_LAT,
            self.longitude, PARAM_LONG
        )
        
        println("Param \(params)")
        
        return API.requestWith(BASE_URL, path:API_GET_LOCATION, parameters: params)
    }
    
    override func responseClass() -> AnyClass {
        return LocationResponse.self
    }
}

class LocationResponse: BaseResponse {
    var locations:[Location] = []
    
    override func createModelsWithJSON(JSON: AnyObject) {
        println("LocationResponse JSON \(JSON)")
        
        var locationResult:NSArray? = JSON["locations"] as? NSArray
        var locationList: [Location] = [];
        if locationResult != nil {
            for loc in locationResult! {
                var locationDict = loc["location"] as? NSDictionary
                if locationDict != nil {
                    var location:Location = Location(locationDict: locationDict!)
                    locationList.append(location)
                }
            }
        }
        
        println(locationList)
        self.locations = locationList
    }
}