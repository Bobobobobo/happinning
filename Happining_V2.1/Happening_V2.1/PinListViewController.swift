//
//  PinListViewController.swift
//  Happening_V2.1
//
//  Created by Kan Boonprakub on 8/12/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit
import CoreLocation

class PinListViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
                            
    @IBOutlet var pinsTableView : UITableView!
    @IBOutlet var sidebarButton : UIBarButtonItem!
    
    var pins:[Pin] = []
    
    var api : APIController!
    var locationManager: CLLocationManager!
    
    var imageCache = [String : UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        sidebarButton.target = self.revealViewController()
        sidebarButton.action = Selector("revealToggle:")

        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        //self.performSegueWithIdentifier("signin", sender: self)
        
        self.api = APIController()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestAlwaysAuthorization()
        //self.locationManager.startUpdatingLocation()
        
        //testing
        var latitude: Double = 13.8353822
        var longitude: Double = 100.5701188
        self.api.getPins(latitude, longitude: longitude, distance: 100000, loadPins)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        //locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        var locValue: CLLocationCoordinate2D = locationManager.location.coordinate
        println("location = \(locValue.latitude) \(locValue.longitude)")
        var latitude: Double = 13.8353822
        var longitude: Double = 100.5701188
        self.api.getPins(latitude, longitude: longitude, distance: 100000, loadPins)
    }
    
    func testTapped(sender: UIBarButtonItem!) {
        self.revealViewController().revealToggle(sender)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return number of row for pins
        return pins.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Process result cell in the tableView
        let kCellIdentifier = "PinCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as PinTableViewCell
        
        let pin = self.pins[indexPath.row]
        
        cell.pinTitle?.text = pin.text
        
        var urlString = "http://54.179.16.196:3000\(pin.imageURL)"
        
        var image = self.imageCache[urlString]

//        cell.pinImage?.image = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString)))
        
        if( image == nil ) {
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: urlString)
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView?.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    cellToUpdate.imageView?.image = image
                }
            })
        }
        
        cell.userName?.text = pin.userName
        
        return cell
    }

    func loadPins(results: NSDictionary) {
        //Process the jsonresult parse from API Controller
        var pinfromResult: NSArray = results["pins"] as NSArray
        //println(pinfromResult)
        var pinList: [Pin] = [];
        for pinDict in pinfromResult {
            //println(_stdlib_getTypeName(pinDict))
            if pinDict is NSDictionary {
                pinList.append(Pin(pinDict: pinDict as NSDictionary))
            }
        }
        pins = pinList
        self.pinsTableView.reloadData()
    }
    
//    func getPageIndex() -> Int {
//        return  self.pageIndex
//    }



}

