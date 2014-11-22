//
//  PinRequest.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/3/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

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

class PinResponse: BaseResponse {
    var pins:[Pin] = []

    override func createModelsWithJSON(JSON: AnyObject) {
        //println("PinResponse JSON \(JSON)")
        
        var pinfromResult:NSArray? = JSON["pins"] as? NSArray
        //println(pinfromResult)
        var pinList: [Pin] = [];
        if pinfromResult != nil {
            for pinDict in pinfromResult! {
                //println(_stdlib_getTypeName(pinDict))
                if pinDict is NSDictionary {
                    pinList.append(Pin(pinDict: pinDict as NSDictionary))
                }
            }
        }
        
        self.pins = pinList
    }
}
