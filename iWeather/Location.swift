//
//  Location.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import CoreLocation

class Location {
    
    var name: String?
    var coordinate: (latitude: Double, longitude: Double)?
    var dayWeatherSummary: String?
    var weekWeatherSummary: String?
    var currentWeather: CurrentWeather!
    var hourlyWeather: [HourlyWeather]!
    var dailyWeather: [DailyWeathear]!
    var placemark: CLPlacemark!
    var timeZone: String?
    var currentDay: DailyWeathear!
    
    var weatherObject: NSDictionary! {
        didSet {
            self.setTimeZone()
            self.createCurrentWeather()
            self.populateHourlyWeather()
            self.populateDailyWeather()
        }
    }
    
    private func setTimeZone() {
        if let timeZone = weatherObject.valueForKey("timezone") as? String {
            self.timeZone = timeZone
        }
    }
    
     private struct WeatherType {
        private static let Current = "currently"
        private static let Hourly = "hourly"
        private static let Daily = "daily"
        private static let Summary = "summary"
        private static let Data = "data"
    }
    
    func getCoordinate() -> String{
        return "\(self.coordinate!.latitude),\(self.coordinate!.longitude)"
    }
    
    private func createCurrentWeather() {
        if let currently = weatherObject.valueForKey(WeatherType.Current) as? NSDictionary {
            self.currentWeather = CurrentWeather(weatherDictionary: currently)
        }
    }
    
    private func populateHourlyWeather() {
        if let hourly = weatherObject.valueForKey(WeatherType.Hourly) as? NSDictionary {
            self.dayWeatherSummary = hourly.valueForKey(WeatherType.Summary) as? String
            let hourlyData = hourly.valueForKey(WeatherType.Data) as! Array<AnyObject>
            for hour in hourlyData {
                let hourWeather = HourlyWeather(weatherDictionary: hour as! NSDictionary)
                self.hourlyWeather.append(hourWeather)
            }
        }
    }
    
    private func populateDailyWeather() {
        if let daily = weatherObject.valueForKey(WeatherType.Daily) as? NSDictionary {
            self.weekWeatherSummary = daily.valueForKey(WeatherType.Summary) as? String
            var dailyData = daily.valueForKey(WeatherType.Data) as! Array<AnyObject>
            if let currentDay = dailyData.removeAtIndex(0) as? NSDictionary {
                self.currentDay = DailyWeathear(weatherDictionary: currentDay, timeZone: self.timeZone!)
            }
            for day in dailyData {
                let dayWeather = DailyWeathear(weatherDictionary: day as! NSDictionary, timeZone: self.timeZone!)
                self.dailyWeather.append(dayWeather)
            }
        }
    }
    
    convenience init(placemark: CLPlacemark) {
        let coordinate = (latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
        self.init(placemark: placemark, coordinate: coordinate)
    }
    
    init(placemark: CLPlacemark, coordinate: (latitude: Double, longitude: Double)) {
        self.name = placemark.name
        self.placemark = placemark
        self.coordinate = coordinate
        self.hourlyWeather = [HourlyWeather]()
        self.dailyWeather = [DailyWeathear]()
    }
    
    convenience init(name: String, coordinate: CLLocationCoordinate2D) {
        let coordinate = (latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.init(name: name, coordinate: coordinate)
    }
    
    init(name: String, coordinate: (latitude: Double, longitude: Double)) {
        self.name = name
        self.coordinate = coordinate
        self.hourlyWeather = [HourlyWeather]()
        self.dailyWeather = [DailyWeathear]()
    }
    
}
