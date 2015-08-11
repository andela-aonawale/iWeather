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
            api.getWeatherDataForTime(self.getStartDate(), coordinate: location!.getCoordinate())
        }
    }
    var eventLocationCoordinate: CLLocationCoordinate2D?
    var eventLocationName: String?
    var startDate: NSDate?
    var endDate: NSDate?
    var startTimeZone: String?
    
    let api = APIController.sharedInstance
    
    func getStartDate() -> Int {
        return Int(startDate!.timeIntervalSince1970)
    }
    
    func getEventDate() -> String {
        return NSDate.dateStringFromUnixTime(self.getStartDate(), dateStyle: .LongStyle, timeStyle: .ShortStyle)
    }
    
    init(title: String, startDate: NSDate, endDate: NSDate, location: String) {
        api.delegate = self
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.eventLocationName = location
    }
    
    init(title: String, startDate: NSDate, endDate: NSDate, location: String, coordinate: CLLocationCoordinate2D) {
        api.delegate = self
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.eventLocationCoordinate = coordinate
        self.eventLocationName = location
    }
    
}


extension Event: APIControllerDelegate {
    
    dynamic func didReceiveWeatherResultForTime(weatherObject: NSDictionary) {
        self.location?.weatherObject = weatherObject
    }
    
}