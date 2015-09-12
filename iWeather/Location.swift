//
//  Location.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

typealias Coordinate = (latitude: Double, longitude: Double)

class Location: NSObject, NSCoding {

    var name: String!
    var coordinate: Coordinate!
    var timeZone: String!
    var dayWeatherSummary: String?
    var currentWeather: CurrentWeather!
    var currentDayWeather: DailyWeathear!
    var dailyWeather: Array<DailyWeathear>!
    var hourlyWeather: Array<HourlyWeather>!
    
    var coordinateString: String! {
        return "\(self.coordinate.latitude),\(self.coordinate.longitude)"
    }
    
    private struct Key {
        private static let Name = "name"
        private static let Latitude = "latitude"
        private static let Longitude = "longitude"
        private static let TimeZone = "timeZone"
        private static let DayWeatherSummary = "dayWeatherSummary"
        private static let CurrentWeather = "currentWeather"
        private static let CurrentDayWeather = "currentDayWeather"
        private static let DailyWeather = "dailyWeather"
        private static let HourlyWeather = "hourlyWeather"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: Key.Name)
        aCoder.encodeDouble(coordinate.latitude, forKey: Key.Latitude)
        aCoder.encodeDouble(coordinate.longitude, forKey: Key.Longitude)
        aCoder.encodeObject(timeZone, forKey: Key.TimeZone)
        aCoder.encodeObject(dayWeatherSummary, forKey: Key.DayWeatherSummary)
        aCoder.encodeObject(currentWeather, forKey: Key.CurrentWeather)
        aCoder.encodeObject(currentDayWeather, forKey: Key.CurrentDayWeather)
        aCoder.encodeObject(dailyWeather, forKey: Key.DailyWeather)
        aCoder.encodeObject(hourlyWeather, forKey: Key.HourlyWeather)
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(Key.Name) as! String
        let latitude = aDecoder.decodeDoubleForKey(Key.Latitude)
        let longitude = aDecoder.decodeDoubleForKey(Key.Longitude)
        coordinate = Coordinate(latitude: latitude, longitude: longitude)
        timeZone = aDecoder.decodeObjectForKey(Key.TimeZone) as! String
        dayWeatherSummary = aDecoder.decodeObjectForKey(Key.DayWeatherSummary) as? String
        currentWeather = aDecoder.decodeObjectForKey(Key.CurrentWeather) as! CurrentWeather
        currentDayWeather = aDecoder.decodeObjectForKey(Key.CurrentDayWeather) as! DailyWeathear
        dailyWeather = aDecoder.decodeObjectForKey(Key.DailyWeather) as! Array<DailyWeathear>
        hourlyWeather = aDecoder.decodeObjectForKey(Key.HourlyWeather) as! Array<HourlyWeather>
        super.init()
    }
    
    var weatherObject: NSDictionary! {
        didSet {
            self.setTimeZone()
            self.setCurrentWeather()
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
    
    private func setCurrentWeather() {
        if let currently = weatherObject.valueForKey(WeatherType.Current) as? NSDictionary {
            self.currentWeather = CurrentWeather(weatherDictionary: currently)
        }
    }
    
    private func populateHourlyWeather() {
        hourlyWeather.removeAll()
        if let hourly = weatherObject[WeatherType.Hourly] as? NSDictionary {
            self.dayWeatherSummary = hourly[WeatherType.Summary] as? String
            let hourlyData = hourly[WeatherType.Data] as! Array<AnyObject>
            for hour in hourlyData {
                let hourWeather = HourlyWeather(weatherDictionary: hour as! NSDictionary)
                self.hourlyWeather.append(hourWeather)
            }
        }
    }
    
    private func populateDailyWeather() {
        dailyWeather.removeAll()
        if let daily = weatherObject[WeatherType.Daily] as? NSDictionary {
            var dailyData = daily[WeatherType.Data] as! Array<AnyObject>
            if let currentDay = dailyData.removeAtIndex(0) as? NSDictionary {
                self.currentDayWeather = DailyWeathear(weatherDictionary: currentDay, timeZone: self.timeZone!)
            }
            for day in dailyData {
                let dayWeather = DailyWeathear(weatherDictionary: day as! NSDictionary, timeZone: self.timeZone!)
                self.dailyWeather.append(dayWeather)
            }
        }
    }
    
    init(name: String, coordinate: Coordinate) {
        self.name = name
        self.coordinate = coordinate
        self.dailyWeather = Array<DailyWeathear>()
        self.hourlyWeather = Array<HourlyWeather>()
    }
    
}
