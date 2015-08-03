//
//  Weather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class Weather {
    
    var time: String?
    var temperature: String?
    var humidity: String?
    var precipProbability: String?
    var precipIntensity: String?
    var windSpeed: String?
    var pressure: String?
    var summary: String?
    var imageName: String?
    
    struct WeatherType {
        private static let Temperature = "temperature"
        private static let Humidity = "humidity"
        private static let PrecipProbability = "precipProbability"
        private static let PrecipIntensity = "precipIntensity"
        private static let Summary = "summary"
        private static let WindSpeed = "windSpeed"
        private static let Time = "time"
        private static let Icon = "icon"
        private static let Pressure = "pressure"
    }
    
    init(weatherDictionary: NSDictionary) {
        if let temperature = weatherDictionary.valueForKey(WeatherType.Temperature) as? Int {
            self.temperature = ("\(temperature.description)\u{00B0}")
        }
        if let humidity = weatherDictionary.valueForKey(WeatherType.Humidity) as? Double {
            self.humidity = humidity.description
        }
        if let precipProbability = weatherDictionary.valueForKey(WeatherType.PrecipProbability) as? Double {
            self.precipProbability = precipProbability.description
        }
        if let precipIntensity =  weatherDictionary.valueForKey(WeatherType.PrecipIntensity) as? Double {
            self.precipIntensity = precipIntensity.description
        }
        if let windSpeed =  weatherDictionary.valueForKey(WeatherType.WindSpeed) as? Double {
            self.windSpeed = windSpeed.description
        }
        if let pressure =  weatherDictionary.valueForKey(WeatherType.Pressure) as? Double {
            self.pressure = pressure.description
        }
        
        let currentTimeIntValue = weatherDictionary.valueForKey(WeatherType.Time) as! Int
        time = NSDate.dateStringFromUnixTime(currentTimeIntValue)
        
        summary = weatherDictionary.valueForKey(WeatherType.Summary) as? String
        imageName = weatherDictionary[WeatherType.Icon] as? String
    }
    
    func weatherIconFromString(stringIcon: String) -> String {
        
        enum IconName: String {
            case ClearDay = "clear-day"
            case ClearNight = "clear-night"
            case Rain = "rain"
            case Snow = "snow"
            case Sleet = "sleet"
            case Wind = "wind"
            case Fog = "fog"
            case Clody = "cloudy"
            case PartlyCloudyDay = "partly-cloudy-day"
            case PartlyCloudyNight = "partly-cloudy-night"
            case Default = "default"
        }
        
        return IconName(rawValue: stringIcon)?.rawValue as String!
    }

}
