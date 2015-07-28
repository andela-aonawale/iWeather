//
//  LocationManager.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/27/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreLocation

@objc protocol LocationManagerDelegate: class {
    optional func informUserThatGPSWillNotWork()
    optional func enableLocationAccess()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    private var location: Location?
    
    func geocodeAddressString(address: String) {
        CLGeocoder().geocodeAddressString(address) { (placemarks, error) in
            if error != nil {
                println(error.localizedDescription)
            } else if let placemark = placemarks?.first as? CLPlacemark {

            }
        }
    }
    
    func start() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func sharedManager() -> LocationManager {
        var pred = dispatch_once_t()
        var sharedManager: LocationManager!
        dispatch_once(&pred) {
            sharedManager = LocationManager()
        }
        return sharedManager
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case CLAuthorizationStatus.Denied:
            println()
            delegate?.informUserThatGPSWillNotWork!()
        default:
            break
        }
    }
    
    func postNotification(location: Location) {
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: "Received Current Location", object: nil, userInfo: ["currentLocation" : location])
        center.postNotification(notification)
    }
    
    func instantiateCurrentLocation(placemark: CLPlacemark) {
        let coordinate = (latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
        location = Location(placemark: placemark)
        postNotification(location!)
    }
    
    class var sharedInstance : LocationManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : LocationManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationManager()
        }
        return Static.instance!
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(manager.location) { (placemarks, error) in
            if error != nil {
                println(error.localizedDescription)
            } else if let placemark = placemarks?.first as? CLPlacemark {
                self.instantiateCurrentLocation(placemark)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if error.domain == kCLErrorDomain {
            switch error.code {
            case CLError.LocationUnknown.rawValue:
                println("The location manager was unable to obtain a location value right now.")
            case CLError.Denied.rawValue:
                println()
                //enableLocationAccess()
            case CLError.Network.rawValue:
                println("The network was unavailable or a network error occurred")
            default:
                break
            }
        }
    }
}