//
//  PostPinRequest.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/22/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

class PostPinRequest: BaseRequest {

    var latitude:Double = 0.0
    var longitude:Double = 0.0
    var userID:String = ""
    var pinType = "1"
    var pinLocality = ""
    var pinSubLocality = ""
    var pinText = ""
    var pinImage:UIImage?
    var pinVideo:NSData?
    
    override func urlRequest() -> NSURLRequest? {
        var data = NSDictionary(objectsAndKeys:
            self.pinType, PARAM_PIN_TYPE,
            NSDictionary(objectsAndKeys:
                self.pinLocality, PARAM_LOCALITY,
                self.pinSubLocality, PARAM_SUB_LOCALITY,
                [self.longitude, self.latitude], PARAN_COORDINATE,
                "Point", PARAM_TYPE
            ), PARAM_LOCATION,
            self.pinText, PARAM_TEXT,
            self.userID, PARAM_USER_ID
        )
        
        var jsonData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.allZeros, error: nil)
        
        var params = NSMutableDictionary(objectsAndKeys:
            NSString(data: jsonData!, encoding: NSUTF8StringEncoding)!, PARAM_DATA
        )
        
        if self.pinImage != nil {
            var maxLength = max(self.pinImage!.size.width, self.pinImage!.size.height)
            if maxLength > 2000 {
                var scaleTo = (100.0/maxLength)*20.0
                self.pinImage = self.pinImage!.scaleImageToScale(scaleTo)
            }
            
            self.pinImage = self.pinImage!.fixOrientation()
            
            params.setObject(UIImageJPEGRepresentation(self.pinImage!.scaleImageToScale(0.5), 0.5), forKey: PARAM_THUMBNAIL)
            
            if self.pinVideo != nil {
                params.setObject(self.pinVideo!, forKey: PARAM_VIDEO)
            } else {
                params.setObject(UIImageJPEGRepresentation(self.pinImage!, 0.5), forKey: PARAM_IMAGE)
            }
        } else {
            return API.requestPostWith(BASE_URL, path:API_ADD_PIN, parameters: params)
        }
        
        //{"pinType":1,"location":{"type":"Point","locality":"Bangkok Thailand","subLocality":"จามจุรี 24 floor","coordinates":[100.5309391,13.732464]},"text":"ggg","userId":"543e72b9e7bc519606823385"}
        
        //println("Param \(params)")
        
        return API.requestUploadWith(BASE_URL, path:API_ADD_PIN, parameters: params)
    }
    
    override func responseClass() -> AnyClass {
        return PinResponse.self
    }
}

class PinLikeRequest: BaseRequest {
    var userID:String = ""
    var pinID:String = ""
    var isLike = false
    
    override func urlRequest() -> NSURLRequest? {
        var data = NSDictionary(objectsAndKeys:
            self.userID, PARAM_USER_ID,
            Int(self.isLike), PARAM_LIKE
        )
        
        var jsonData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.allZeros, error: nil)
        
        var params = NSDictionary(objectsAndKeys:
            NSString(data: jsonData!, encoding: NSUTF8StringEncoding)!, PARAM_DATA,
            self.pinID, PARAM_PIN_ID
        )
        
        return API.requestPostWith(BASE_URL, path:API_LIKE, parameters: params)
    }
}

class PostCommentRequest: PinLikeRequest {
    var text:String = ""

    override func urlRequest() -> NSURLRequest? {
        var data = NSDictionary(objectsAndKeys:
            self.userID, PARAM_USER_ID,
            self.text, PARAM_COMMENT
        )
        
        var jsonData = NSJSONSerialization.dataWithJSONObject(data, options: NSJSONWritingOptions.allZeros, error: nil)
        
        var params = NSDictionary(objectsAndKeys:
            NSString(data: jsonData!, encoding: NSUTF8StringEncoding)!, PARAM_DATA,
            self.pinID, PARAM_PIN_ID
        )
        
        return API.requestPostWith(BASE_URL, path:API_ADD_COMMENT, parameters: params)
    }
}