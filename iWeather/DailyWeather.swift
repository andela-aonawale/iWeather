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
    
    override init(weatherDictionary: NSDictionary, timeZone: String) {
        if let temperatureMin = weatherDictionary.valueForKey(WeatherConstant.TemperatureMin) as? Int {
            self.temperatureMin = temperatureMin.description
        }
        if let temperatureMax = weatherDictionary.valueForKey(WeatherConstant.TemperatureMax) as? Int {
            self.temperatureMax = temperatureMax.description
        }
        if let sunriseUnixTime = weatherDictionary.valueForKey(WeatherConstant.SunriseTime) as? Int {
            self.sunriseTime = NSDate.dateStringFromTimezone(timeZone, unixTime: sunriseUnixTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        }
        if let sunsetUnixTime = weatherDictionary.valueForKey(WeatherConstant.SunsetTime) as? Int {
            self.sunsetTime = NSDate.dateStringFromTimezone(timeZone, unixTime: sunsetUnixTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        }
        if let dayUnixTime = weatherDictionary[WeatherConstant.Time] as? Int {
            self.day = NSDate.dateFormatFromUnixTime(dayUnixTime, format: DateFormat.Day)
        }
        super.init(weatherDictionary: weatherDictionary, timeZone: timeZone)
    }

    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(sunriseTime, forKey: WeatherConstant.SunriseTime)
        aCoder.encodeObject(sunsetTime, forKey: WeatherConstant.SunsetTime)
        aCoder.encodeObject(temperatureMin, forKey: WeatherConstant.TemperatureMin)
        aCoder.encodeObject(temperatureMax, forKey: WeatherConstant.TemperatureMax)
        aCoder.encodeObject(day, forKey: WeatherConstant.Day)
        super.encodeWithCoder(aCoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        sunriseTime = aDecoder.decodeObjectForKey(WeatherConstant.SunriseTime) as? String
        sunsetTime = aDecoder.decodeObjectForKey(WeatherConstant.SunsetTime) as? String
        temperatureMin = aDecoder.decodeObjectForKey(WeatherConstant.TemperatureMin) as? String
        temperatureMax = aDecoder.decodeObjectForKey(WeatherConstant.TemperatureMax) as? String
        day = aDecoder.decodeObjectForKey(WeatherConstant.Day) as? String
        super.init(coder: aDecoder)
    }
    
}