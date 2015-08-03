//
//  DailyWeather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

final class DailyWeathear: Weather {
    
    var sunriseTime: String
    var sunsetTime: String
    var temperatureMin: Int
    var temperatureMax: Int
    
    struct DayWeather {
        private static let TemperatureMin = "temperatureMin"
        private static let TemperatureMax = "temperatureMax"
        private static let SunriseTime = "sunriseTime"
        private static let SunsetTime = "sunsetTime"
        private static let Temperature = "temperature"
    }
    
    override init(weatherDictionary: NSDictionary) {
        temperatureMin = weatherDictionary.valueForKey(DayWeather.TemperatureMin) as! Int
        temperatureMax = weatherDictionary.valueForKey(DayWeather.TemperatureMax) as! Int
        sunriseTime = NSDate.dateStringFromUnixTime(weatherDictionary.valueForKey(DayWeather.SunriseTime) as! Int)
        sunsetTime = NSDate.dateStringFromUnixTime(weatherDictionary.valueForKey(DayWeather.SunsetTime) as! Int)
        var mutableWeatherDictionary: NSMutableDictionary = weatherDictionary.mutableCopy() as! NSMutableDictionary
        mutableWeatherDictionary.removeObjectForKey(DayWeather.Temperature)
        super.init(weatherDictionary: mutableWeatherDictionary)
    }
}