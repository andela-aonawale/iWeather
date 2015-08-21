//
//  Weather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class Weather {
    
    var temperature: String?
    var humidity: String?
    var precipProbability: String?
    var precipIntensity: String?
    var windSpeed: String?
    var pressure: String?
    var summary: String?
    var imageName: String?
    var visibility: String?
    
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
        private static let Visibility = "visibility"
    }
    
    init(weatherDictionary: NSDictionary) {
        if let temperature = weatherDictionary.valueForKey(WeatherType.Temperature) as? Int {
            self.temperature = ("\(temperature.description)\u{00B0}")
        }
        if let humidity = weatherDictionary.valueForKey(WeatherType.Humidity) as? Double {
            self.humidity = String(format: "%d%%", Int(humidity * 100))
        }
        if let precipProbability = weatherDictionary.valueForKey(WeatherType.PrecipProbability) as? Double {
            self.precipProbability = String(format: "%d%%", Int(precipProbability * 100))
        }
        if let precipIntensity =  weatherDictionary.valueForKey(WeatherType.PrecipIntensity) as? Double {
            self.precipIntensity = precipIntensity.description
        }
        if let windSpeed =  weatherDictionary.valueForKey(WeatherType.WindSpeed) as? Double {
            self.windSpeed = String(format: "%d km/h", Int(windSpeed * 1.60934))
        }
        if let pressure =  weatherDictionary.valueForKey(WeatherType.Pressure) as? Double {
            let formattedPressure = NSNumberFormatter.localizedStringFromNumber(Int(pressure), numberStyle: .DecimalStyle)
            self.pressure = String(format: "%@ mb", formattedPressure)
        }
        if let iconName = weatherDictionary[WeatherType.Icon] as? String {
            self.imageName = iconName
        } else {
            self.imageName = "default"
        }
        if let visibility =  weatherDictionary.valueForKey(WeatherType.Visibility) as? Double {
            self.visibility = String(format: "%d km", Int(visibility * 1.60934))
        }
        if let summary = weatherDictionary.valueForKey(WeatherType.Summary) as? String {
            self.summary = summary
        }
    }

}
