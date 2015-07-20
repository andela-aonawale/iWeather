//
//  DailyWeather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class DailyWeathear: Weather {
    
    var sunriseTime: String
    var sunsetTime: String
    var temperatureMin: Int
    var temperatureMax: Int
    
    override init(weatherDictionary: NSDictionary) {
        temperatureMin = weatherDictionary.valueForKey("temperatureMin") as! Int
        temperatureMax = weatherDictionary.valueForKey("temperatureMax") as! Int
        sunriseTime = Weather.dateStringFromUnixTime(weatherDictionary.valueForKey("sunriseTime") as! Int)
        sunsetTime = Weather.dateStringFromUnixTime(weatherDictionary.valueForKey("sunsetTime") as! Int)
        var mutableWeatherDictionary: NSMutableDictionary = weatherDictionary.mutableCopy() as! NSMutableDictionary
        mutableWeatherDictionary.removeObjectForKey("temperature")
        super.init(weatherDictionary: mutableWeatherDictionary)
    }
}