//
//  Location.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class Location {
    
    var name: String?
    var coordinate: (latitude: Double, longitude: Double)?
    var dayWeatherSummary: String?
    var weekWeatherSummary: String?
    var currentWeather: CurrentWeather!
    var hourlyWeather: [HourlyWeather]
    var dailyWeather: [DailyWeathear]
    
    var weatherObject: NSDictionary! {
        didSet {
            instantiateCurrentWeather()
            instantiateHourlyWeather()
            instantiateDailyWeather()
        }
    }
    
    struct WeatherType {
        private static let Current = "currently"
        private static let Hourly = "hourly"
        private static let Daily = "daily"
        private static let Summary = "summary"
        private static let Data = "data"
    }
    
    func getCoordinate() -> String{
        return "\(coordinate!.latitude),\(coordinate!.longitude)"
    }
    
    func instantiateCurrentWeather() {
        if let currently = weatherObject.valueForKey(WeatherType.Current) as? NSDictionary {
            currentWeather = CurrentWeather(weatherDictionary: currently)
        }
    }
    
    func instantiateHourlyWeather() {
        if let hourly = weatherObject.valueForKey(WeatherType.Hourly) as? NSDictionary {
            dayWeatherSummary = hourly.valueForKey(WeatherType.Summary) as? String
            let hourlyData = hourly.valueForKey(WeatherType.Data) as! NSArray
            for hour in hourlyData {
                let hourWeather = HourlyWeather(weatherDictionary: hour as! NSDictionary)
                hourlyWeather.append(hourWeather)
            }
        }
    }
    
    func instantiateDailyWeather() {
        if let daily = weatherObject.valueForKey(WeatherType.Daily) as? NSDictionary {
            weekWeatherSummary = daily.valueForKey(WeatherType.Summary) as? String
            let dailyData = daily.valueForKey(WeatherType.Data) as! NSArray
            for day in dailyData {
                let dayWeather = DailyWeathear(weatherDictionary: day as! NSDictionary)
                dailyWeather.append(dayWeather)
            }
        }
    }
    
    init(name: String, coordinate: (latitude: Double, longitude: Double)) {
        hourlyWeather = [HourlyWeather]()
        dailyWeather = [DailyWeathear]()
        self.name = name
        self.coordinate = coordinate
    }
    
}
