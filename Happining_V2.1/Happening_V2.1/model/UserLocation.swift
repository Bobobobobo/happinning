//
//  UserLocation.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/26/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import CoreLocation
import Foundation

protocol LocationDelegate : NSObjectProtocol {
    func userLocationDidUpdateLocations(locations: [AnyObject]!)
    func userLocationDidUpdateGeoCoding(locality: [AnyObject]!)
}

class UserLocation : NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var delegate: LocationDelegate!
    var geoCoder: CLGeocoder!
    var locality:[AnyObject] = []
    var subLocality:[AnyObject] = []
    
    class var manager : UserLocation {
        struct Singleton {
            static let instance:UserLocation = UserLocation()
        }
        
        return Singleton.instance
    }
    
    func startUpdatingLocation() {
        self.geoCoder = CLGeocoder()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = CLLocationDistance(2000.0)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            if self.locationManager.respondsToSelector(Selector("requestWhenInUseAuthorization")) {
                self.locationManager.requestWhenInUseAuthorization()
            } else {
                self.locationManager.startUpdatingLocation()
            }
        } else {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        //locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            print(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    
    func addPlace(p:AnyObject?, toArray array:[AnyObject]) -> [AnyObject] {
        var ar = array

        if p != nil {
            ar.append(p!)
        }
        
        return ar
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        //locationManager.stopUpdatingLocation()
        self.geoCoder.reverseGeocodeLocation(locations.last as CLLocation, completionHandler: { (geoLocations, error) -> Void in
            if error == nil {
                for p in geoLocations {
                    var place = p as CLPlacemark
                    var placeArray:[AnyObject] = []
                    var subPlaceArray:[AnyObject] = []
                    placeArray = self.addPlace(place.locality, toArray: placeArray)
                    placeArray = self.addPlace(place.country, toArray: placeArray)
                    
                    subPlaceArray = self.addPlace(place.name, toArray: subPlaceArray)
                    subPlaceArray = self.addPlace(place.thoroughfare, toArray: subPlaceArray)
                    subPlaceArray = self.addPlace(place.subLocality, toArray: subPlaceArray)
                    //subPlaceArray = self.addPlace(place.administrativeArea, toArray: subPlaceArray)
                    //subPlaceArray = self.addPlace(place.subAdministrativeArea, toArray: subPlaceArray)
                    
                    self.locality = placeArray
                    
                    if self.delegate != nil && self.delegate.respondsToSelector("userLocationDidUpdateGeoCoding:") {
                        self.delegate.userLocationDidUpdateGeoCoding(subPlaceArray)
                    }
                }
            } else {
                println("geo coding error \(error)")
            }
        })

        if self.delegate != nil && self.delegate.respondsToSelector("userLocationDidUpdateLocations:") {
            self.delegate.userLocationDidUpdateLocations(locations)
        }
    }
}