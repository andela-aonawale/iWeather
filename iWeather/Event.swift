//
//  Events.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/3/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreLocation

class Event {
    
    var title: String?
    var location: Location? {
        didSet {
            api.getWeatherDataForTime(self.startDate!, coordinate: location!.getCoordinate())
        }
    }
    var startDate: Int?
    var endDate: NSDate?
    var startTimeZone: String?
    
    let api = APIController.sharedInstance
    
    convenience init(title: String, startDate: NSDate, endDate: NSDate, placemark: CLPlacemark) {
        let start = Int(startDate.timeIntervalSince1970)
        self.init(title: title, startDate: start, endDate: endDate, placemark: placemark)
    }
    
    init(title: String, startDate: Int, endDate: NSDate, placemark: CLPlacemark) {
        api.delegate = self
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        ({Void in self.location = Location(placemark: placemark)})()
    }
    
    convenience init(title: String, startDate: NSDate, endDate: NSDate, coordinate: CLLocationCoordinate2D) {
        let start = Int(startDate.timeIntervalSince1970)
        self.init(title: title, startDate: start, endDate: endDate, coordinate: coordinate)
    }
    
    init(title: String, startDate: Int, endDate: NSDate, coordinate: CLLocationCoordinate2D) {
        api.delegate = self
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        ({Void in self.location = Location(name: title, coordinate: coordinate)})()
    }
    
}


extension Event: APIControllerDelegate {
    
    dynamic func didReceiveWeatherResultForTime(weatherObject: NSDictionary) {
        self.location?.weatherObject = weatherObject
    }
    
}