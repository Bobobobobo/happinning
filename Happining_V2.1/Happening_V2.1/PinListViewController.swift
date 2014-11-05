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
    
    let kCellIdentifier = "PinCell"

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
        isLogin = User.isLogin()
    }
    
    var isLogin: Bool = false
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isLogin {
            self.performSegueWithIdentifier("signin", sender: self)
            isLogin = true
        } else {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
                self.locationManager.requestWhenInUseAuthorization()
            }
            
            //testing
            //var latitude: Double = 13.7324541
            //var longitude: Double = 100.5309073
            //self.loadPinsAt(latitude, longitude: longitude)
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

        var latitude: Double = locValue.latitude
        var longitude: Double = locValue.longitude
        var userId = User.currentUser.userID
        //self.api.getPins(latitude, longitude: longitude,distance: 100000, userId: userId, loadPins)
        self.loadPinsAt(latitude, longitude: longitude)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
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
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as PinTableViewCell
        
        var pin = self.pins[indexPath.row]
        
        cell.pinTitle?.text = pin.text
        
        var baseURL = BASE_URL
        var urlString = "\(baseURL)\(pin.thumbURL)"
        println("text \(pin.text) url \(pin.thumbURL)")
        if strlen(pin.thumbURL) == 0 {
            cell.imageHeight!.constant = 0.0
            cell.pinImage?.hidden = true
        } else {
            cell.imageHeight!.constant = 220.0
            cell.pinImage?.hidden = false
            cell.pinImage?.sd_setImageWithURL(NSURL(string: urlString))
        }
        
        //var image = self.imageCache[urlString]
        cell.profileImage?.sd_setImageWithURL(NSURL(string: pin.userImageURL))
        cell.userName?.text = pin.userName
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var pin = self.pins[indexPath.row]
        if countElements(pin.thumbURL) == 0 {
            return 170
        }
        
        return 390
    }
    
    // MARK: Load Pin

    func loadPinsAt(latitude:Double, longitude:Double) {
        var userId = User.currentUser.userID
        //self.api.getPins(latitude, longitude: longitude,distance: 100000, userId: userId, loadPins)
        var request = PinRequest()
        request.latitude = latitude
        request.longitude = longitude
        request.userID = userId!
        
        request.request({ (result) -> Void in
            var response = result as PinResponse
            self.pins = response.pins
            self.pinsTableView.reloadData()
        })
    }

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

    func loginViewDidFinishWithUser(user: User?) {
        if user != nil {
            println("Finish login with \(user!.userName)")
        } else {
            println("Login Error")
        }
    }
}

