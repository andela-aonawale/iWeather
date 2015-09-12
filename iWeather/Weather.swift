//
//  Weather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class Weather: NSObject, NSCoding {
    
    var temperature: String?
    var humidity: String?
    var precipProbability: String?
    var precipIntensity: String?
    var windSpeed: String?
    var pressure: String?
    var summary: String?
    var imageName: String?
    var visibility: String?
    
    struct Constant {
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
        private static let ImageName = "imageName"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(temperature, forKey: Constant.Temperature)
        aCoder.encodeObject(humidity, forKey: Constant.Humidity)
        aCoder.encodeObject(precipProbability, forKey: Constant.PrecipProbability)
        aCoder.encodeObject(precipIntensity, forKey: Constant.PrecipIntensity)
        aCoder.encodeObject(windSpeed, forKey: Constant.WindSpeed)
        aCoder.encodeObject(pressure, forKey: Constant.Pressure)
        aCoder.encodeObject(summary, forKey: Constant.Summary)
        aCoder.encodeObject(imageName, forKey: Constant.ImageName)
        aCoder.encodeObject(visibility, forKey: Constant.Visibility)
    }
    
    required init?(coder aDecoder: NSCoder) {
        temperature = aDecoder.decodeObjectForKey(Constant.Temperature) as? String
        humidity = aDecoder.decodeObjectForKey(Constant.Humidity) as? String
        precipProbability = aDecoder.decodeObjectForKey(Constant.PrecipProbability) as? String
        precipIntensity = aDecoder.decodeObjectForKey(Constant.PrecipIntensity) as? String
        windSpeed = aDecoder.decodeObjectForKey(Constant.WindSpeed) as? String
        pressure = aDecoder.decodeObjectForKey(Constant.Pressure) as? String
        summary = aDecoder.decodeObjectForKey(Constant.Summary) as? String
        imageName = aDecoder.decodeObjectForKey(Constant.ImageName) as? String
        visibility = aDecoder.decodeObjectForKey(Constant.Visibility) as? String
        super.init()
    }
    
    init(weatherDictionary: NSDictionary) {
        if let temperature = weatherDictionary[Constant.Temperature] as? Int {
            self.temperature = ("\(temperature.description)\u{00B0}")
        }
        if let humidity = weatherDictionary[Constant.Humidity] as? Double {
            self.humidity = String(format: "%d%%", Int(humidity * 100))
        }
        if let precipProbability = weatherDictionary[Constant.PrecipProbability] as? Double {
            self.precipProbability = String(format: "%d%%", Int(precipProbability * 100))
        }
        if let precipIntensity =  weatherDictionary[Constant.PrecipIntensity] as? Double {
            self.precipIntensity = precipIntensity.description
        }
        if let windSpeed =  weatherDictionary[Constant.WindSpeed] as? Double {
            self.windSpeed = String(format: "%d km/h", Int(windSpeed * 1.60934))
        }
        if let pressure =  weatherDictionary[Constant.Pressure] as? Double {
            let formattedPressure = NSNumberFormatter.localizedStringFromNumber(Int(pressure), numberStyle: .DecimalStyle)
            self.pressure = String(format: "%@ mb", formattedPressure)
        }
        if let iconName = weatherDictionary[Constant.Icon] as? String {
            self.imageName = iconName
        } else {
            self.imageName = "default"
        }
        if let visibility =  weatherDictionary[Constant.Visibility] as? Double {
            self.visibility = String(format: "%d km", Int(visibility * 1.60934))
        }
        if let summary = weatherDictionary[Constant.Summary] as? String {
            self.summary = summary
        }
    }

}
