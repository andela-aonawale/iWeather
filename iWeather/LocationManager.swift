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
        manager.delegate = self
        return manager
    }()
    weak var delegate: LocationManagerDelegate?
    private let geocoder = CLGeocoder()
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func startMonitoringSignificantLocationChanges() {
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopMonitoringSignificantLocationChanges() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    class func locationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        locationManager.stopUpdatingLocation()
        geocoder.reverseGeocodeLocation(location) { [unowned self] (placemarks, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else if let placemark = placemarks?.first {
                self.createLocationWithPlacemark(placemark)
            }
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            case .NotDetermined:
                locationManager.requestAlwaysAuthorization()
            case .Denied, .AuthorizedWhenInUse:
                locationManager.stopUpdatingLocation()
                locationManager.stopMonitoringSignificantLocationChanges()
                delegate?.locationAccessDenied()
            case .Restricted:
                locationManager.stopUpdatingLocation()
                locationManager.stopMonitoringSignificantLocationChanges()
                delegate?.locationAccessRestricted()
            case .AuthorizedAlways:
                locationManager.startUpdatingLocation()
        }
    }
    
    func geocodeAddressFromString(address: String, completed: (placemarks: [AnyObject]!, error: NSError!) -> Void) {
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            completed(placemarks: placemarks, error: error)
        }
    }
    
    private func postUserLocation() {
        let notification = NSNotification(name: Notification.UserCurrentLocation, object: nil, userInfo: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    private func createLocationWithPlacemark(placemark: CLPlacemark) {
        let coord = (placemark.location?.coordinate)!
        let coordinate = Coordinate(latitude: coord.latitude, longitude: coord.longitude)
        let userLocation = Location(name: placemark.name!, coordinate: coordinate, type: LocationType(rawValue: 0)!)
        saveUserLocationToDataModel(userLocation)
        postUserLocation()
    }
    
    private func saveUserLocationToDataModel(userLocation: Location) {
        let dataModel = DataModel.sharedInstance
        if let location = dataModel.locations.first {
            switch location.type {
                case .Current:
                    dataModel.locations[0] = userLocation
                case .Other:
                    dataModel.locations.insert(userLocation, atIndex: 0)
            }
        } else {
            dataModel.locations.append(userLocation)
        }
    }
    
    class var sharedInstance : LocationManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: LocationManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationManager()
        }
        return Static.instance!
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        switch error {
            case CLError.LocationUnknown.rawValue:
                locationManager.stopUpdatingLocation()
            case CLError.Denied.rawValue:
                locationManager.stopUpdatingLocation()
                locationManager.stopMonitoringSignificantLocationChanges()
                delegate?.locationAccessDenied()
            case CLError.Network.rawValue:
                locationManager.stopUpdatingLocation()
                delegate?.networkUnavailable()
            default:
                locationManager.stopUpdatingLocation()
                locationManager.stopMonitoringSignificantLocationChanges()
                break
        }
    }
    
}