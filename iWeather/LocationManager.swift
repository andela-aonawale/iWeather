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
    optional func locationAccessDenied()
    optional func locationAccessRestricted()
    optional func networkUnavailable()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    private let geocoder = CLGeocoder()
    
    func geocodeAddressFromString(address: String, completed: (placemarks: [AnyObject]!, error: NSError!) -> Void) {
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            completed(placemarks: placemarks, error: error)
        }
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    class func locationAccessEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            case .NotDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .Denied:
                delegate?.locationAccessDenied!()
            case .Restricted:
                delegate?.locationAccessRestricted!()
            default:
                break
        }
    }
    
    func postNewLocation(location: Location) {
        let notification = NSNotification(name: "Received Current Location", object: nil, userInfo: ["currentLocation" : location])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func createCurrentLocationWithPlacemark(placemark: CLPlacemark) {
        let coord = (placemark.location?.coordinate)!
        let coordinate = Coordinate(latitude: coord.latitude, longitude: coord.longitude)
        let location = Location(name: placemark.name!, coordinate: coordinate)
        postNewLocation(location)
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if let location = manager.location {
            geocoder.reverseGeocodeLocation(location) { [unowned self] (placemarks, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else if let placemark = placemarks?.first {
                    self.createCurrentLocationWithPlacemark(placemark)
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        switch error {
            case CLError.LocationUnknown.rawValue:
                print("The location manager was unable to obtain a location value right now.")
            case CLError.Denied.rawValue:
                locationManager.stopUpdatingLocation()
                delegate?.locationAccessDenied!()
            case CLError.Network.rawValue:
                delegate?.networkUnavailable!()
                print("The network was unavailable or a network error occurred")
            default:
                break
        }
    }
    
}