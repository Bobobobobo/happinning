//
//  APIController.swift
//  Happining_V2
//
//  Created by Kan Boonprakub on 7/11/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
}

import UIKit

class APIController: NSObject {
   
    
    var delegate: APIControllerProtocol?
    
    init(delegate: APIControllerProtocol?) {
        self.delegate = delegate
    }
    
    func getPins(lat: Double!, long: Double!) {
        
        //Parse Latitude & Longitude of center map or map location and fetch pins around it
        
    }
    
    func getPin(pinId: String!) {
        
        //Parse ID to get specific pin
        //With Pin Detail information
        
    }
    
    
    
    func get(path: String) {
        let url = NSURL(string: path)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if(error) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err?) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            var results = jsonResult["results"] as NSArray
            // Now send the JSON result to our delegate object
            self.delegate?.didReceiveAPIResults(jsonResult)
            })
        task.resume()
    }
    
    
    
    
}
