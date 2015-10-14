//
//  DailyWeather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
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