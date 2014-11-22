//
//  BaseRequest.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/3/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

// MARK: API URL
let BASE_URL = "http://54.179.16.196:3000"

// MARK: API FUNCTIONS
let API_LOGIN = "/login"
let API_GET_PINS = "/getPins"
let API_ADD_PIN = "/addPin"

// MARK: API PARAMS

let PARAM_PAGE = "page"

// Login
let PARAM_USERNAME = "username"
let PARAM_EMAIL = "email"
let PARAM_PASSWORD = "password"

// Get Pin
let PARAM_LAT = "latitude"
let PARAM_LONG = "longitude"
let PARAM_DISTANCE = "maxdistance"
let PARAM_USER_ID = "userId"

// Add Pin
let PARAM_PIN_TYPE = "pinType"
let PARAM_LOCATION = "location"
let PARAM_TYPE = "type"
let PARAM_LOCALITY = "locality"
let PARAM_SUB_LOCALITY = "subLocality"
let PARAN_COORDINATE = "coordinates"
let PARAM_TEXT = "text"

class API: NSObject {
    class func request(request:BaseRequest, responseClass:AnyClass, block:(result:BaseResponse) -> Void) -> NSURLSessionDataTask? {

        var urlRequest = request.urlRequest()

        if urlRequest == nil {
            return nil
        }
        
        println("URL: \(urlRequest!.URL.absoluteString)")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest!, completionHandler: { (data, response, error) -> Void in
            var className = responseClass as BaseResponse.Type
            var theResponse = className(request: request, response: response, responseError: error, data: data)
            
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                block(result: theResponse)
            })
        })
        
        task.resume()
        return task
    }
    
    class func requestPostWith(url:String, path:String?, parameters:NSDictionary?) -> NSURLRequest? {
        var urlString:NSMutableString = NSMutableString(string: url)
        
        if (path != nil) {
            urlString.appendString(path!)
        }
        
        if (parameters != nil) {
            var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            var request = NSMutableURLRequest(URL: NSURL(string: urlString)!, cachePolicy:NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval:60.0)
            request.HTTPMethod = "POST"
            
            var paramString = joinParameters(parameters)
            paramString = dropFirst(paramString)
            println("Param \(paramString)")

            var postData = paramString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            request.HTTPBody = postData

            return request
        }
        
        return nil
    }
    
    class func requestWith(url:String, path:String?, parameters:NSDictionary?) -> NSURLRequest? {
        var urlString:NSMutableString = NSMutableString(string: url)
        
        if (path != nil) {
            urlString.appendString(path!)
        }
        
        var paramString = joinParameters(parameters)
        
        if parameters != nil {
            urlString.appendString(paramString)
        }
        
        return NSURLRequest(URL: NSURL(string: urlString)!)
    }
    
    private class func joinParameters(parameters:NSDictionary?) -> String {
        var urlString:NSMutableString = NSMutableString()
        if (parameters != nil) {
            var isFirstParameters = true;
            var params:NSDictionary = parameters!
            for (key, value) in params {
                var val = "\(value)"
                if isFirstParameters {
                    isFirstParameters = false
                    urlString.appendString("?")
                } else {
                    urlString.appendString("&")
                }
                
                var customAllowedSet =  NSCharacterSet(charactersInString:"!*'\"();:@&=+$,/?%#[]% ").invertedSet
                val = val.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
                
                var param = "\(key)=\(val)"
                urlString.appendString(param)
            }
        }
        return urlString
    }
}

class BaseRequest: NSObject {
    var task:NSURLSessionDataTask?
    var page = 1;

    func request(block:(result:BaseResponse) -> Void){
        self.task = API.request(self, responseClass: self.responseClass(), block:block)
    }
    
    func urlRequest() -> NSURLRequest? {
        return nil
    }
    
    func responseClass() -> AnyClass {
        return BaseResponse.self
    }
}

@objc class BaseResponse: NSObject {
    
    var request:BaseRequest?
    var response:NSURLResponse?
    var error:NSError?
    var data:AnyObject?
    
    required init(request:BaseRequest!, response:NSURLResponse?, responseError:NSError?, data:NSData?) {
        super.init()
        
        self.request = request
        self.response = response
        self.error = responseError
        self.data = data
        
        if(responseError != nil) {
            // If there is an error in the web request, print it to the console
            println(responseError!.localizedDescription)
        } else if data != nil {
            var err: NSError?
            
            var jsonResult:AnyObject? = NSJSONSerialization.JSONObjectWithData(data!,options:nil,error: &err)
            
            if jsonResult != nil {
                self.createModelsWithJSON(jsonResult!)
            } else if err != nil {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error: \(err!.localizedDescription)")
                self.error = err
                self.createModelsWithData(data!)
            }
        }
    }
    
    func createModelsWithData(data:NSData) {
        
    }
    
    func createModelsWithJSON(JSON:AnyObject) {
        println(JSON)
    }
}
