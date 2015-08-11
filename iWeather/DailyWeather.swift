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
    var temperatureMin: Int?
    var temperatureMax: Int?
    var day: String?
    
    struct DayWeather {
        private static let TemperatureMin = "temperatureMin"
        private static let TemperatureMax = "temperatureMax"
        private static let SunriseTime = "sunriseTime"
        private static let SunsetTime = "sunsetTime"
        private static let Temperature = "temperature"
    }
    
    override init(weatherDictionary: NSDictionary) {
        self.temperatureMin = weatherDictionary.valueForKey(DayWeather.TemperatureMin) as? Int
        self.temperatureMax = weatherDictionary.valueForKey(DayWeather.TemperatureMax) as? Int
        
        let sunriseUnixTime = weatherDictionary.valueForKey(DayWeather.SunriseTime) as? Int
        self.sunriseTime = NSDate.dateStringFromUnixTime(sunriseUnixTime!, dateStyle: .NoStyle, timeStyle: .ShortStyle)
            
        let sunsetUnixTime = weatherDictionary.valueForKey(DayWeather.SunsetTime) as? Int
        self.sunsetTime = NSDate.dateStringFromUnixTime(sunsetUnixTime!, dateStyle: .NoStyle, timeStyle: .ShortStyle)
            
        let dayUnixTime = weatherDictionary.valueForKey("time") as? Int
        self.day = NSDate.dateFormatFromUnixTime(dayUnixTime!, format: "EEEE")
            
        super.init(weatherDictionary: weatherDictionary)
    }
}