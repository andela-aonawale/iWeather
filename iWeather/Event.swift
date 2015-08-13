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
            api.getWeatherDataForTime(self.getStartDate(), coordinate: location!.getCoordinate()) { weatherObject in
                self.location?.weatherObject = weatherObject
                let notification = NSNotification(name: "Received Event Location Weather", object: nil, userInfo: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            }
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
    
    func getEventTime() -> String {
        return NSDate.dateStringFromUnixTime(self.getStartDate(), dateStyle: .NoStyle, timeStyle: .ShortStyle)
    }
    
    func getEventDate() -> String {
        return NSDate.dateStringFromUnixTime(self.getStartDate(), dateStyle: .LongStyle, timeStyle: .ShortStyle)
    }
    
    init(title: String, startDate: NSDate, endDate: NSDate, location: String) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.eventLocationName = location
    }
    
    init(title: String, startDate: NSDate, endDate: NSDate, location: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.eventLocationCoordinate = coordinate
        self.eventLocationName = location
    }
    
}