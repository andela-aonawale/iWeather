//
//  Events.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/3/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import EventKit

class Event {
    
    var title: String?
    var location: Location? {
        didSet {
            api.getWeatherForDate(self.startDate!, coordinate: location!.coordinateString) { weatherObject in
                self.location?.weatherObject = weatherObject
                let notification = NSNotification(name: "Received Event Location Weather", object: nil, userInfo: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            }
        }
    }
    var eventLocationCoordinate: (latitude: Double, longitude: Double)?
    var eventLocationName: String?
    var startDate: NSDate?
    var endDate: NSDate?
    var startTimeZone: String?
    var event: EKEvent?
    
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
    
    init(event: EKEvent) {
        self.event = event
        self.title = event.title
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.eventLocationName = event.location
    }
    
    init(event: EKEvent, coordinate: (latitude: Double, longitude: Double)) {
        self.event = event
        self.title = event.title
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.eventLocationName = event.location
        self.eventLocationCoordinate = coordinate
    }
    
}