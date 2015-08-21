//
//  DailyWeather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

final class DailyWeathear: Weather {
    
    var sunriseTime: String?
    var sunsetTime: String?
    var temperatureMin: String?
    var temperatureMax: String?
    var day: String?
    
    struct DayWeather {
        private static let TemperatureMin = "temperatureMin"
        private static let TemperatureMax = "temperatureMax"
        private static let SunriseTime = "sunriseTime"
        private static let SunsetTime = "sunsetTime"
        private static let Temperature = "temperature"
    }
    
    init(weatherDictionary: NSDictionary, timeZone: String) {
        if let temperatureMin = weatherDictionary.valueForKey(DayWeather.TemperatureMin) as? Int {
            self.temperatureMin = temperatureMin.description
        }
        if let temperatureMax = weatherDictionary.valueForKey(DayWeather.TemperatureMax) as? Int {
            self.temperatureMax = temperatureMax.description
        }
        if let sunriseUnixTime = weatherDictionary.valueForKey(DayWeather.SunriseTime) as? Int {
            self.sunriseTime = NSDate.dateStringFromTimezone(timeZone, unixTime: sunriseUnixTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        }
        if let sunsetUnixTime = weatherDictionary.valueForKey(DayWeather.SunsetTime) as? Int {
            self.sunsetTime = NSDate.dateStringFromTimezone(timeZone, unixTime: sunsetUnixTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        }
        if let dayUnixTime = weatherDictionary.valueForKey("time") as? Int {
            self.day = NSDate.dateFormatFromUnixTime(dayUnixTime, format: "EEEE")
        }
        super.init(weatherDictionary: weatherDictionary)
    }
    
}