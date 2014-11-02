//
//  PinListViewController.swift
//  Happening_V2.1
//
//  Created by Kan Boonprakub on 8/12/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit
import CoreLocation

class PinListViewController: BaseViewController , UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, LoginViewDelegate {
                            
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
        
        self.api = APIController()
        
        // Logged in
        isLogin = true
    }
    
    var isLogin: Bool = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if !isLogin {
            self.performSegueWithIdentifier("signin", sender: self)
            isLogin = true
        }
        else {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
            
            //testing
            var latitude: Double = 13.8353822
            var longitude: Double = 100.5701188
            var userId = "543e72b9e7bc519606823385"
            self.api.getPins(latitude, longitude: longitude,distance: 100000, userId: userId, loadPins)
        }
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
        var userId = "543e72b9e7bc519606823385"
        self.api.getPins(latitude, longitude: longitude,distance: 100000, userId: userId, loadPins)
    }
    
    func testTapped(sender: UIBarButtonItem!) {
        self.revealViewController().revealToggle(sender)
    }
    
    // MARK: Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return number of row for pins
        return self.pins.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Process result cell in the tableView
        let kCellIdentifier = "PinCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as PinTableViewCell
        
        var pin = self.pins[indexPath.row]
        
        cell.pinTitle?.text = pin.text
        
        var baseURL = "http://54.179.16.196:3000"
        var urlString = "\(baseURL)\(pin.thumbURL)"
        
        //var image = self.imageCache[urlString]
        cell.pinImage?.sd_setImageWithURL(NSURL(string: urlString))
        cell.profileImage?.sd_setImageWithURL(NSURL(string: pin.userImageURL))

//        cell.pinImage?.image = UIImage(data: NSData(contentsOfURL: NSURL(string: urlString)))
//        if( image == nil ) {
//            // If the image does not exist, we need to download it
//            var imgURL: NSURL = NSURL(string: urlString)!
//            
//            // Download an NSData representation of the image at the URL
//            let request: NSURLRequest = NSURLRequest(URL: imgURL)
//            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
//                if error == nil {
//                    image = UIImage(data: data)
//                    
//                    // Store the image in to our cache
//                    self.imageCache[urlString] = image
//                    dispatch_async(dispatch_get_main_queue(), {
//                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
//                            cellToUpdate.imageView.image = image
//                        }
//                    })
//                }
//                else {
//                    println("Error: \(error.localizedDescription)")
//                }
//            })
//            
//        }
//        else {
//            dispatch_async(dispatch_get_main_queue(), {
//                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
//                    cellToUpdate.imageView.image = image
//                }
//            })
//        }
        
        cell.userName?.text = pin.userName
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 450
    }
    
    // MARK: Load Pin

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
        self.pins = pinList
        self.pinsTableView.reloadData()
    }
    
//    func getPageIndex() -> Int {
//        return  self.pageIndex
//    }


    /**********************************
    *
    *   MARK: Navigation
    *
    ***********************************/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != nil) {
            var segueID = segue.identifier!
            if (segueID == "signin") {
                var navigationController:UINavigationController = segue.destinationViewController as UINavigationController
                var loginController:LoginViewController = navigationController.viewControllers[0] as LoginViewController
                loginController.delegate = self
            }
        }
    }
    
    /**********************************
    *
    *   MARK: Login Delegate
    *
    ***********************************/

    func loginViewDidFinishWithEmail(email: String, Password password: NSString, Username username: String) {
        
        // TODO: Finish login with these data
        // <#code here#>
        println("Login view did finish with email: \(email) password: \(password) username: \(username)")
    }
}

