//
//  APIController.swift
//  Happining_V2
//
//  Created by Kan Boonprakub on 7/11/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

class APIController: NSObject {

    override init() {
        super.init()
    }
    
    func getPins(latitude: Double, longitude: Double, distance: Int, callback: (result: NSDictionary) -> Void) {
        
        //Parse Latitude & Longitude of center map or map location and fetch pins around it
        var url = "http://54.179.16.196:3000/getPins?latitude=\(latitude)&longitude=\(longitude)&maxdistance=\(distance)"
        get(url, callback);
    }
    
    func getPin(pinId: String) {
        
        //Parse ID to get specific pin
        //With Pin Detail information
        
    }
    
    func login(email: String, username: String, password: String, postCompleted: (succeeded: Bool, msg: String, result: NSDictionary?) -> Void) {
        var url: String = "http://54.179.16.196:3000/login"
        var data: Dictionary<String, String> = Dictionary<String, String>()
        data["email"] = email
        data["username"] = username
        data["password"] = password
        post(data, url: url, postCompleted)
    }
    
    func get(path: String, callback: (result: NSDictionary) -> Void) {
        println("GET URL: \(path)")
        let url = NSURL(string: path)!
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if((error) != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            //var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if let jsonResult: AnyObject = NSJSONSerialization.JSONObjectWithData(data,options:nil,error: &err) {
                if jsonResult is NSDictionary {
                    var myDict: NSDictionary = jsonResult as NSDictionary
                    //println("myDict:\(myDict)")
                    callback(result: myDict)
                }
                else if jsonResult is NSArray {
                    var myArray: NSArray = jsonResult as NSArray
                    println("myArray:\(myArray)")
                    
                }
            }
            
            if err != nil {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error: \(err!.localizedDescription)")
            }
            //var results = jsonResult["results"] as NSArray
            // Now send the JSON result to our delegate object
            //self.delegate?.didReceiveAPIResults(jsonResult)
            })
        task.resume()
    }
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String, result: NSDictionary?) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error", result: nil)
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.", result: nil)
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error", result: nil)
                }
            }
        })
        
        task.resume()
    }
        
}
