//
//  HourlyWeather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

final class HourlyWeather: Weather {
    
    var unixTime: Int
    var hour: String
    
    override init(weatherDictionary: NSDictionary) {
        unixTime = weatherDictionary.valueForKey("time") as! Int
        hour = NSDate.hourFromUnixTime(unixTime)
        super.init(weatherDictionary: weatherDictionary)
    }
}