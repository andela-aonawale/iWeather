//
//  LocationManager.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/27/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate: class {
    func locationAccessDenied()
    func locationAccessRestricted()
    func networkUnavailable()
    func locationUnknown()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private lazy var locationManager: CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    weak var delegate: LocationManagerDelegate?
    private let geocoder = CLGeocoder()
    
    func geocodeAddressFromString(address: String, completed: (placemarks: [AnyObject]!, error: NSError!) -> Void) {
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            completed(placemarks: placemarks, error: error)
        }
    }
    
    func setAccuracyToHundredMeters() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func setAccuracyToBest() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startMonitoringLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    class func locationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            case .NotDetermined:
                locationManager.requestAlwaysAuthorization()
            case .Denied, .AuthorizedWhenInUse:
                locationManager.stopMonitoringSignificantLocationChanges()
                delegate?.locationAccessDenied()
            case .Restricted:
                locationManager.stopMonitoringSignificantLocationChanges()
                delegate?.locationAccessRestricted()
            case .AuthorizedAlways:
                locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    private func postUserLocation(location: Location) {
        let notification = NSNotification(name: Notification.UserCurrentLocation, object: nil, userInfo: [Notification.UserLocation : location])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    private func createLocationWithPlacemark(placemark: CLPlacemark) {
        let coord = (placemark.location?.coordinate)!
        let coordinate = Coordinate(latitude: coord.latitude, longitude: coord.longitude)
        let location = Location(name: placemark.name!, coordinate: coordinate)
        postUserLocation(location)
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
        if let location = manager.location {
            geocoder.reverseGeocodeLocation(location) { [unowned self] (placemarks, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else if let placemark = placemarks?.first {
                    self.createLocationWithPlacemark(placemark)
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        switch error {
            case CLError.LocationUnknown.rawValue:
                print("The location manager was unable to obtain a location value right now.")
            case CLError.Denied.rawValue:
                locationManager.stopMonitoringSignificantLocationChanges()
                delegate?.locationAccessDenied()
            case CLError.Network.rawValue:
                locationManager.stopMonitoringSignificantLocationChanges()
                delegate?.networkUnavailable()
                print("The network was unavailable or a network error occurred")
            default:
                locationManager.stopMonitoringSignificantLocationChanges()
                break
        }
    }
    
}