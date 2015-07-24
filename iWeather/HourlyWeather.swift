//
//  HourlyWeather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class HourlyWeather: Weather {
    
    var unixTime: Int
    
    override init(weatherDictionary: NSDictionary) {
        unixTime = weatherDictionary.valueForKey("time") as! Int
        super.init(weatherDictionary: weatherDictionary)
    }
}