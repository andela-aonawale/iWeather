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
    var location: Location?
    var eventLocationCoordinate: (latitude: Double, longitude: Double)?
    var eventLocationName: String?
    var startDate: NSDate?
    var endDate: NSDate?
    var startTimeZone: String?
    var event: EKEvent?
    
    func getStartDate() -> Int {
        return Int(startDate!.timeIntervalSince1970)
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