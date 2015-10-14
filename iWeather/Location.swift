//
//  Location.swift
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
import UIKit

typealias Coordinate = (latitude: Double, longitude: Double)

enum LocationType: Int {
    case Current, Other
}

enum Icon: String {
    case ClearDay = "clear-day"
    case ClearNight = "clear-night"
    case Rain = "rain"
    case Snow = "snow"
    case Sleet = "sleet"
    case Wind = "wind"
    case Fog = "fog"
    case Cloudy = "cloudy"
    case PartlyCloudyDay = "partly-cloudy-day"
    case PartlyCloudyNight = "partly-cloudy-night"
}

final class Location: NSObject, NSCoding {

    var name: String!
    var coordinate: Coordinate!
    var timeZone: String!
    var dayWeatherSummary: String?
    var currentWeather: Weather?
    var currentDayWeather: DailyWeathear?
    var dailyWeather: [DailyWeathear]?
    var hourlyWeather: [Weather]?
    private var nextHourTimer: NSTimer!
    private var subsequentHourTimer: NSTimer!
    var hasWeatherData: Bool
    var type: LocationType
    
    func convertWeatherUnitsToSI() {
        if hasWeatherData {
            currentWeather?.convertUnitsToSI()
            currentDayWeather?.convertUnitsToSI()
            for weather in dailyWeather! {
                weather.convertUnitsToSI()
            }
            for weather in hourlyWeather! {
                weather.convertUnitsToSI()
            }
            postWeatherUpdateNotification()
        }
    }
    
    func convertWeatherUnitsToUS() {
        if hasWeatherData {
            currentWeather?.convertUnitsToUS()
            currentDayWeather?.convertUnitsToUS()
            for weather in dailyWeather! {
                weather.convertUnitsToUS()
            }
            for weather in hourlyWeather! {
                weather.convertUnitsToUS()
            }
            postWeatherUpdateNotification()
        }
    }
    
    func updateWeatherData(completionHandler: (success: Bool) -> ()) {
        clearWeatherData()
        APIController.sharedInstance.getWeatherData(coordinateString) { [weak self] result, error in
            if error != nil {
                self?.hasWeatherData = false
                completionHandler(success: false)
            } else if let result = result {
                self?.hasWeatherData = true
                self?.weatherDictionary = result
                self?.scheduleNotifications()
                completionHandler(success: true)
            }
        }
    }
    
    private func clearWeatherData() {
        hasWeatherData = false
        currentWeather = nil
        currentDayWeather = nil
        dayWeatherSummary = nil
        dailyWeather?.removeAll()
        hourlyWeather?.removeAll()
        invalidateTimers()
    }
    
    var currentTime: String? {
        return NSDate.dateStringFromTimezone(timeZone, dateStyle: .NoStyle, timeStyle: .ShortStyle)
    }
    
    var coordinateString: String! {
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
    
    private func secondsToNextHour() -> NSTimeInterval? {
        for (index, weather) in hourlyWeather!.enumerate() {
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
        hourlyWeather?.removeFirst()
        currentWeather = hourlyWeather?.first
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
        if hourlyWeather?.count > 0 {
            removeElapsedHourWeather()
            postWeatherUpdateNotification()
        } else {
            subsequentHourTimer?.invalidate()
        }
    }
    
    func postWeatherUpdateNotification() {
        let notification = NSNotification(name: Notification.LocationDataUpdated, object: self, userInfo: [Notification.Location : self])
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: Key.Name)
        aCoder.encodeDouble(coordinate.latitude, forKey: Key.Latitude)
        aCoder.encodeDouble(coordinate.longitude, forKey: Key.Longitude)
        aCoder.encodeInteger(type.rawValue, forKey: "type")
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
        type = LocationType(rawValue: aDecoder.decodeIntegerForKey("type"))!
        timeZone = aDecoder.decodeObjectForKey(Key.TimeZone) as? String
        dayWeatherSummary = aDecoder.decodeObjectForKey(Key.DayWeatherSummary) as? String
        currentWeather = aDecoder.decodeObjectForKey(Key.CurrentWeather) as? Weather
        currentDayWeather = aDecoder.decodeObjectForKey(Key.CurrentDayWeather) as? DailyWeathear
        dailyWeather = aDecoder.decodeObjectForKey(Key.DailyWeather) as? [DailyWeathear]
        hourlyWeather = aDecoder.decodeObjectForKey(Key.HourlyWeather) as? [Weather]
        hasWeatherData = aDecoder.decodeBoolForKey(Key.HasWeatherData)
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
                hourlyWeather?.append(hourWeather)
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
                dailyWeather?.append(dayWeather)
            }
        }
    }
    
    init(name: String, coordinate: Coordinate, type: LocationType) {
        self.name = name
        self.coordinate = coordinate
        self.dailyWeather = [DailyWeathear]()
        self.hourlyWeather = [Weather]()
        self.hasWeatherData = false
        self.type = type
        super.init()
        updateWeatherData { [weak self] success in
            if success {
                self?.postWeatherUpdateNotification()
            }
        }
    }
    
    convenience init(name: String, coordinate: Coordinate) {
        self.init(name: name, coordinate: coordinate, type: LocationType(rawValue: 1)!)
    }
    
    deinit {
        nextHourTimer?.invalidate()
        subsequentHourTimer?.invalidate()
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
    
}

extension Location {
    
    // MARK: - Notification methods
    
    private func scheduleNotifications() {
        if type == .Current {
            requestNotificationPermission()
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            getSignificantWeatherChangeTime(hourlyWeather)
        }
    }
    
    private func requestNotificationPermission() {
        let notificationSettings = UIUserNotificationSettings( forTypes: [.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    private func getSignificantWeatherChangeTime(hourlyWeather: [Weather]?) {
        guard let hourlyWeather = hourlyWeather where hourlyWeather.count > 2 else {
            return
        }
        for index in 2..<hourlyWeather.count {
            let next = hourlyWeather[index], previous = hourlyWeather[index-1]
            if next.imageName! != previous.imageName! {
                let message = ("\(getAlertMessageFrom(next.imageName!)!) \(next.hour)")
                scheduleNotification(previous.unixTime!, alertBody: message)
            }
        }
    }
    
    private func scheduleNotification(unixTime: Int, alertBody: String) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSince1970: NSTimeInterval(unixTime))
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = alertBody
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    private func getAlertMessageFrom(imageName: String) -> String? {
        guard let icon = Icon(rawValue: imageName) else {
            return nil
        }
        switch icon {
            case .ClearDay, .ClearNight:
                return Message.Clear
            case .Rain:
                return Message.Rain
            case .Snow:
                return Message.Snow
            case .Sleet:
                return Message.Sleet
            case .Wind:
                return Message.Wind
            case .Fog:
                return Message.Fog
            case .Cloudy, .PartlyCloudyDay, .PartlyCloudyNight:
                return Message.Cloudy
        }
    }
    
}
