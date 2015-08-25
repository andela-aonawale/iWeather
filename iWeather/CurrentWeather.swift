//
//  CurrentWeather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

final class CurrentWeather: Weather {
    
    var date: String?
    var time: String?
    
    override init(weatherDictionary: NSDictionary) {
        if let unixTime = weatherDictionary.valueForKey("time") as? Int {
            self.date = NSDate.dateFormatFromUnixTime(unixTime, format: "LLL d, h:mm a")
            self.time = NSDate.dateStringFromUnixTime(unixTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        }
        super.init(weatherDictionary: weatherDictionary)
    }
}