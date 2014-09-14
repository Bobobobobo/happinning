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
    
    var delegate: APIControllerProtocol
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    
    func getPins(latitude: Double, longitude: Double) {
        
        //Parse Latitude & Longitude of center map or map location and fetch pins around it
        var url = "http://54.179.16.196:3000/getPins?latitude=13.8353822&longitude=100.5701188&maxdistance=100000"
        get(url);
    }
    
    func getPin(pinId: String!) {
        
        //Parse ID to get specific pin
        //With Pin Detail information
        
    }
    
    func getTest() ->[Pin] {
        
        var pins :[Pin] = []
        
        /*var pin1 = Pin(pinId: "Test1", title: "Test1", owner: "KanB", content: "Test1 Content", timestamp: "2014-07-31", pinLat: 100.0, pinLong: 100.0, imgGalleryURL: "Test.happening.com/image", videoGalleryURL: "Test.happneing.com/video")
        pins.append(pin1)
        
        var pin2 = Pin(pinId: "Test2", title: "Test2", owner: "KanB", content: "Test2 Content", timestamp: "2014-07-31", pinLat: 100.0, pinLong: 100.0, imgGalleryURL: "Test.happening.com/image", videoGalleryURL: "Test.happneing.com/video")
        pins.append(pin2)
        
        var pin3 = Pin(pinId: "Test3", title: "Test3", owner: "KanB", content: "Test3 Content", timestamp: "2014-07-31", pinLat: 100.0, pinLong: 100.0, imgGalleryURL: "Test.happening.com/image", videoGalleryURL: "Test.happneing.com/video")
        pins.append(pin3)
        
        var pin4 = Pin(pinId: "Test4", title: "Test4", owner: "KanB", content: "Test4 Content", timestamp: "2014-07-31", pinLat: 100.0, pinLong: 100.0, imgGalleryURL: "Test.happening.com/image", videoGalleryURL: "Test.happneing.com/video")
        pins.append(pin4)*/
        
        return pins
        
    }
    
    func get(path: String) {
        let url = NSURL(string: path)
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
                    self.delegate.didReceiveAPIResults(myDict)
                }
                else if jsonResult is NSArray {
                    var myArray: NSArray = jsonResult as NSArray
                    println("myArray:\(myArray)")
                    
                }
            }
            
            if err != nil {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //var results = jsonResult["results"] as NSArray
            // Now send the JSON result to our delegate object
            //self.delegate?.didReceiveAPIResults(jsonResult)
            })
        task.resume()
    }
        
}
