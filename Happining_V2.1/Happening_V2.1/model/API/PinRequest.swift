//
//  PinRequest.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/3/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import CoreLocation

class PinRequest: BaseRequest {
    
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var distance:Double = 500
    var userID:String = ""
    
    override func urlRequest() -> NSURLRequest? {
        var params = NSDictionary(objectsAndKeys:
            self.latitude, PARAM_LAT,
            self.longitude, PARAM_LONG,
            self.distance, PARAM_DISTANCE,
            self.userID, PARAM_USER_ID,
            self.page, PARAM_PAGE
        )
        
        println("Param \(params)")

        return API.requestWith(BASE_URL, path:API_GET_PINS, parameters: params)
    }
    
    override func responseClass() -> AnyClass {
        return PinResponse.self
    }
}

class PinDetailRequest: BaseRequest {
    
    var userID:String = ""
    var pinID:String = ""
    
    override func urlRequest() -> NSURLRequest? {
        var params = NSDictionary(objectsAndKeys:
            self.pinID, PARAM_PIN_ID,
            self.userID, PARAM_USER_ID
        )
        
        println("Param \(params)")
        
        return API.requestWith(BASE_URL, path:API_GET_PIN, parameters: params)
    }
    
    override func responseClass() -> AnyClass {
        return PinResponse.self
    }
}

class PinResponse: BaseResponse {
    var pins:[Pin] = []

    override func createModelsWithJSON(JSON: AnyObject) {
        println("PinResponse JSON \(JSON)")
        
        var pinfromResult:NSArray? = JSON["pins"] as? NSArray
        //println(pinfromResult)
        var pinList: [Pin] = [];
        
        if pinfromResult != nil {
            for pinDict in pinfromResult! {
                //println(_stdlib_getTypeName(pinDict))
                var pin:Pin?
                if pinDict is NSDictionary {
                    pin = Pin(pinDict: pinDict as NSDictionary)
                    addDictanceToPin(pin)
                    pinList.append(pin!)
                }
            }
        } else if self.request.isKindOfClass(PinDetailRequest.self) {
            var pin = Pin(pinDict: JSON as NSDictionary)
            addDictanceToPin(pin)
            pinList.append(pin)
        }
        
        self.pins = pinList
    }
    
    func addDictanceToPin(pin:Pin?) {
        var request = self.request as? PinRequest
        if request != nil {
            var pinLocation = CLLocation(latitude: pin!.location.coordinate.latitude, longitude: pin!.location.coordinate.longitude)
            var currentLocation = CLLocation(latitude: request!.latitude, longitude: request!.longitude)
            //println("pinLocation \(pinLocation)")
            //println("currentLocation \(currentLocation)")
            var distanceInMeters = currentLocation.distanceFromLocation(pinLocation)
            //println("distanceInMeters \(distanceInMeters)")
            pin!.distance = Float(distanceInMeters*0.001)
        }
    }
}
