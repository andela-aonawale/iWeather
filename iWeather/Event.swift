//
//  Events.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/3/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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