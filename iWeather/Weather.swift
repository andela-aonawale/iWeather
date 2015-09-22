//
//  Weather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation



class Weather: NSObject, NSCoding {
    
    var unixTime: Int!
    var temperature: String?
    var humidity: String?
    var precipProbability: String?
    var precipIntensity: String?
    var windSpeed: String?
    var pressure: String?
    var summary: String?
    var imageName: String?
    var visibility: String?
    var timeZone: String?
    
    var hour: String! {
        return NSDate.dateFormatFromUnixTime(unixTime, format: DateFormat.Hour, timeZone: timeZone!)
    }
    
    var date: String! {
        return NSDate.dateFormatFromUnixTime(unixTime, format: DateFormat.Date)
    }
    
    var time: String! {
        return NSDate.dateStringFromUnixTime(unixTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(unixTime, forKey: WeatherConstant.Time)
        aCoder.encodeObject(temperature, forKey: WeatherConstant.Temperature)
        aCoder.encodeObject(humidity, forKey: WeatherConstant.Humidity)
        aCoder.encodeObject(precipProbability, forKey: WeatherConstant.PrecipProbability)
        aCoder.encodeObject(precipIntensity, forKey: WeatherConstant.PrecipIntensity)
        aCoder.encodeObject(windSpeed, forKey: WeatherConstant.WindSpeed)
        aCoder.encodeObject(pressure, forKey: WeatherConstant.Pressure)
        aCoder.encodeObject(summary, forKey: WeatherConstant.Summary)
        aCoder.encodeObject(imageName, forKey: WeatherConstant.ImageName)
        aCoder.encodeObject(visibility, forKey: WeatherConstant.Visibility)
        aCoder.encodeObject(timeZone, forKey: WeatherConstant.TimeZone)
    }
    
    required init?(coder aDecoder: NSCoder) {
        unixTime = aDecoder.decodeIntegerForKey(WeatherConstant.Time)
        temperature = aDecoder.decodeObjectForKey(WeatherConstant.Temperature) as? String
        humidity = aDecoder.decodeObjectForKey(WeatherConstant.Humidity) as? String
        precipProbability = aDecoder.decodeObjectForKey(WeatherConstant.PrecipProbability) as? String
        precipIntensity = aDecoder.decodeObjectForKey(WeatherConstant.PrecipIntensity) as? String
        windSpeed = aDecoder.decodeObjectForKey(WeatherConstant.WindSpeed) as? String
        pressure = aDecoder.decodeObjectForKey(WeatherConstant.Pressure) as? String
        summary = aDecoder.decodeObjectForKey(WeatherConstant.Summary) as? String
        imageName = aDecoder.decodeObjectForKey(WeatherConstant.ImageName) as? String
        visibility = aDecoder.decodeObjectForKey(WeatherConstant.Visibility) as? String
        timeZone = aDecoder.decodeObjectForKey(WeatherConstant.TimeZone) as? String
        super.init()
    }
    
    init(weatherDictionary: NSDictionary, timeZone: String) {
        
        self.timeZone = timeZone
        
        if let unixTime = weatherDictionary[WeatherConstant.Time] as? Int {
            self.unixTime = unixTime
        }
        if let temperature = weatherDictionary[WeatherConstant.Temperature] as? Int {
            self.temperature = ("\(temperature.description)\u{00B0}")
        }
        if let humidity = weatherDictionary[WeatherConstant.Humidity] as? Double {
            self.humidity = String(format: "%d%%", Int(humidity * 100))
        }
        if let precipProbability = weatherDictionary[WeatherConstant.PrecipProbability] as? Double {
            self.precipProbability = String(format: "%d%%", Int(precipProbability * 100))
        }
        if let precipIntensity =  weatherDictionary[WeatherConstant.PrecipIntensity] as? Double {
            self.precipIntensity = precipIntensity.description
        }
        if let windSpeed =  weatherDictionary[WeatherConstant.WindSpeed] as? Double {
            self.windSpeed = String(format: "%d km/h", Int(windSpeed * 1.60934))
        }
        if let pressure =  weatherDictionary[WeatherConstant.Pressure] as? Double {
            let formattedPressure = NSNumberFormatter.localizedStringFromNumber(Int(pressure), numberStyle: .DecimalStyle)
            self.pressure = String(format: "%@ mb", formattedPressure)
        }
        if let iconName = weatherDictionary[WeatherConstant.Icon] as? String {
            self.imageName = iconName
        }
        if let visibility =  weatherDictionary[WeatherConstant.Visibility] as? Double {
            self.visibility = String(format: "%d km", Int(visibility * 1.60934))
        }
        if let summary = weatherDictionary[WeatherConstant.Summary] as? String {
            self.summary = summary
        }
    }

}
