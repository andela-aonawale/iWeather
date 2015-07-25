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
    var temperature: Int?
    var humidity: Double
    var precipProbability: Double
    var precipIntensity: Double?
    var windSpeed: Double?
    var pressure: Double?
    var summary: String
    var imageName: String?
    
    struct WeatherType {
        private static let Temperature = "temperature"
        private static let Humidity = "humidity"
        private static let PrecipProbability = "precipProbability"
        private static let Summary = "summary"
        private static let Time = "time"
        private static let Icon = "icon"
    }
    
    init(weatherDictionary: NSDictionary) {
        temperature = weatherDictionary.valueForKey(WeatherType.Temperature) as? Int
        humidity = weatherDictionary.valueForKey(WeatherType.Humidity) as! Double
        precipProbability = weatherDictionary.valueForKey(WeatherType.PrecipProbability) as! Double
        summary = weatherDictionary.valueForKey(WeatherType.Summary) as! String
        
        let currentTimeIntValue = weatherDictionary.valueForKey(WeatherType.Time) as! Int
        time = Weather.dateStringFromUnixTime(currentTimeIntValue)
        
        imageName = weatherDictionary[WeatherType.Icon] as? String
    }
    
    class func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(weatherDate)
    }
    
    private struct IconName {
        private static let ClearDay = "clear-day"
        private static let ClearNight = "clear-night"
        private static let Rain = "rain"
        private static let Snow = "snow"
        private static let Sleet = "sleet"
        private static let Wind = "wind"
        private static let Fog = "fog"
        private static let Clody = "cloudy"
        private static let PartlyCloudyDay = "partly-cloudy-day"
        private static let PartlyCloudyNight = "partly-cloudy-night"
        private static let Default = "default"
    }
    
    func weatherIconFromString(stringIcon: String) -> String {
        var imageName: String!
        
        switch stringIcon {
        case "clear-day":
            imageName = "clear-day"
        case "clear-night":
            imageName = "clear-night"
        case "rain":
            imageName = "rain"
        case "snow":
            imageName = "snow"
        case "sleet":
            imageName = "sleet"
        case "wind":
            imageName = "wind"
        case "fog":
            imageName = "fog"
        case "cloudy":
            imageName = "cloudy"
        case "partly-cloudy-day":
            imageName = "partly-cloudy"
        case "partly-cloudy-night":
            imageName = "cloudy-night"
        default:
            imageName = "default"
        }
        
        return imageName
    }

}
