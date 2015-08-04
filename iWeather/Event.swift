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
    var location: Location?
    var startDate: NSDate?
    var endDate: NSDate?
    var startTimeZone: String?
    
    init(title: String, startDate: NSDate, endDate: NSDate, placemark: CLPlacemark) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = Location(placemark: placemark)
    }
    
    init(title: String, startDate: NSDate, endDate: NSDate, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = Location(name: title, coordinate: coordinate)
    }
    
}