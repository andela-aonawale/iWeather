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
    var currentWeather: Weather!
    var currentDayWeather: DailyWeathear!
    var dailyWeather: [DailyWeathear]!
    var hourlyWeather: [Weather]!
    private var nextHourTimer: NSTimer!
    private var subsequentHourTimer: NSTimer!
    var hasWeatherData: Bool
    
    func fetchWeatherData() {
        updateWeatherData { [weak self] success in
            self?.postWeatherUpdateNotification()
        }
    }
    
    func updateWeatherData(completionHandler: (success: Bool) -> ()) {
        clearWeatherData()
        APIController.sharedInstance.getWeatherData(self.coordinateString) { [weak self] result, error in
            if error != nil {
                self?.hasWeatherData = false
                completionHandler(success: false)
            } else if let result = result {
                self?.hasWeatherData = true
                self?.weatherDictionary = result
                completionHandler(success: true)
            }
        }
    }
    
    private func clearWeatherData() {
        hasWeatherData = false
        currentWeather = nil
        currentDayWeather = nil
        dayWeatherSummary = nil
        dailyWeather.removeAll()
        hourlyWeather.removeAll()
        invalidateTimers()
    }
    
    var currentTime: String? {
        return NSDate.dateStringFromTimezone(timeZone, dateStyle: .NoStyle, timeStyle: .ShortStyle)
    }
    
    var coordinateString: String! {
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
    
    private func secondsToNextHour() -> NSTimeInterval? {
        for (index, weather) in hourlyWeather.enumerate() {
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(weather.unixTime!))
            if date > NSDate() {
                return date.timeIntervalSinceDate(NSDate())
            } else {
                if ((index - 1) > -1) {
                    removeElapsedHourWeather()
                }
            }
        }
        return nil
    }
    
    private func scheduleNextHourRemovalTime() {
        invalidateTimers()
        if let interval = secondsToNextHour() {
            nextHourTimer = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "removeNextHourWeather", userInfo: nil, repeats: false)
        }
    }
    
    func invalidateTimers() {
        nextHourTimer?.invalidate()
        subsequentHourTimer?.invalidate()
    }
    
    func restartTimers() {
        scheduleNextHourRemovalTime()
        postWeatherUpdateNotification()
    }
    
    private func removeElapsedHourWeather() {
        hourlyWeather.removeFirst()
        currentWeather = hourlyWeather.first
    }
    
    func removeNextHourWeather() {
        removeElapsedHourWeather()
        postWeatherUpdateNotification()
        startMonitoringEveryHourPassed()
    }
    
    private func startMonitoringEveryHourPassed() {
        subsequentHourTimer = NSTimer.scheduledTimerWithTimeInterval(3600, target: self, selector: "removeSubsequentPastHourWeather", userInfo: nil, repeats: true)
    }
    
    func removeSubsequentPastHourWeather() {
        if hourlyWeather.count > 0 {
            removeElapsedHourWeather()
            postWeatherUpdateNotification()
        } else {
            subsequentHourTimer?.invalidate()
        }
    }
    
    private func postWeatherUpdateNotification() {
        let notification = NSNotification(name: Notification.LocationDataUpdated, object: self, userInfo: [Notification.Location : self])
        NSNotificationCenter.defaultCenter().postNotification(notification)
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
        aCoder.encodeBool(hasWeatherData, forKey: Key.HasWeatherData)
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(Key.Name) as! String
        let latitude = aDecoder.decodeDoubleForKey(Key.Latitude)
        let longitude = aDecoder.decodeDoubleForKey(Key.Longitude)
        coordinate = Coordinate(latitude: latitude, longitude: longitude)
        timeZone = aDecoder.decodeObjectForKey(Key.TimeZone) as? String
        dayWeatherSummary = aDecoder.decodeObjectForKey(Key.DayWeatherSummary) as? String
        currentWeather = aDecoder.decodeObjectForKey(Key.CurrentWeather) as! Weather
        currentDayWeather = aDecoder.decodeObjectForKey(Key.CurrentDayWeather) as! DailyWeathear
        dailyWeather = aDecoder.decodeObjectForKey(Key.DailyWeather) as! Array<DailyWeathear>
        hourlyWeather = aDecoder.decodeObjectForKey(Key.HourlyWeather) as! Array<Weather>
        hasWeatherData = aDecoder.decodeBoolForKey(Key.HasWeatherData)
        super.init()
        fetchWeatherData()
    }
    
    var weatherDictionary: NSDictionary! {
        didSet {
            setTimeZone()
            setCurrentWeather()
            populateHourlyWeather()
            populateDailyWeather()
        }
    }
    
    private func setTimeZone() {
        if let timeZone = weatherDictionary[WeatherConstant.TimeZone] as? String {
            self.timeZone = timeZone
        }
    }
    
    private func setCurrentWeather() {
        if let currently = weatherDictionary[WeatherConstant.Currently] as? NSDictionary {
            self.currentWeather = Weather(weatherDictionary: currently, timeZone: timeZone)
        }
    }
    
    private func populateHourlyWeather() {
        if let hourly = weatherDictionary[WeatherConstant.Hourly] as? NSDictionary {
            dayWeatherSummary = hourly[WeatherConstant.Summary] as? String
            let hourlyData = hourly[WeatherConstant.Data] as! Array<AnyObject>
            for hour in hourlyData {
                let hourWeather = Weather(weatherDictionary: hour as! NSDictionary, timeZone: timeZone)
                hourlyWeather.append(hourWeather)
            }
            scheduleNextHourRemovalTime()
        }
    }
    
    private func populateDailyWeather() {
        if let daily = weatherDictionary[WeatherConstant.Daily] as? NSDictionary {
            var dailyData = daily[WeatherConstant.Data] as! Array<AnyObject>
            if let currentDay = dailyData.removeAtIndex(0) as? NSDictionary {
                currentDayWeather = DailyWeathear(weatherDictionary: currentDay, timeZone: timeZone)
            }
            for day in dailyData {
                let dayWeather = DailyWeathear(weatherDictionary: day as! NSDictionary, timeZone: timeZone)
                dailyWeather.append(dayWeather)
            }
        }
    }
    
    init(name: String, coordinate: Coordinate) {
        self.name = name
        self.coordinate = coordinate
        self.dailyWeather = [DailyWeathear]()
        self.hourlyWeather = [Weather]()
        self.hasWeatherData = false
        super.init()
        self.fetchWeatherData()
    }
    
    deinit {
        nextHourTimer?.invalidate()
        subsequentHourTimer?.invalidate()
    }
    
}
