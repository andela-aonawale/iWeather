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
    var temperatureMin: Double!
    var temperatureMax: Double!
    var day: String?
    
    var temperatureMaxString: String {
        return String(format: "%.0f", temperatureMax)
    }
    
    var temperatureMinString: String {
        return String(format: "%.0f", temperatureMin)
    }
    
    override func convertUnitsToSI() {
        fahrenheitToCelsius(&temperatureMax!)
        fahrenheitToCelsius(&temperatureMin!)
        super.convertUnitsToSI()
    }
    
    override func convertUnitsToUS() {
        celsiusToFahrenheit(&temperatureMax!)
        celsiusToFahrenheit(&temperatureMin!)
        super.convertUnitsToUS()
    }
    
    override init(weatherDictionary: NSDictionary, timeZone: String) {
        if let temperatureMin = weatherDictionary.valueForKey(WeatherConstant.TemperatureMin) as? Double {
            self.temperatureMin = temperatureMin
        }
        if let temperatureMax = weatherDictionary.valueForKey(WeatherConstant.TemperatureMax) as? Double {
            self.temperatureMax = temperatureMax
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
        aCoder.encodeDouble(temperatureMin, forKey: WeatherConstant.TemperatureMin)
        aCoder.encodeDouble(temperatureMax, forKey: WeatherConstant.TemperatureMax)
        aCoder.encodeObject(day, forKey: WeatherConstant.Day)
        super.encodeWithCoder(aCoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        sunriseTime = aDecoder.decodeObjectForKey(WeatherConstant.SunriseTime) as? String
        sunsetTime = aDecoder.decodeObjectForKey(WeatherConstant.SunsetTime) as? String
        temperatureMin = aDecoder.decodeDoubleForKey(WeatherConstant.TemperatureMin)
        temperatureMax = aDecoder.decodeDoubleForKey(WeatherConstant.TemperatureMax)
        day = aDecoder.decodeObjectForKey(WeatherConstant.Day) as? String
        super.init(coder: aDecoder)
    }
    
}