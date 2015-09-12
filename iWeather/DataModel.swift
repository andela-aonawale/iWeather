//
//  DataModel.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import UIKit

class DataModel {
    
    private let api: APIController!
    private let center = NSNotificationCenter.defaultCenter()
    private let queue = NSOperationQueue.mainQueue()
    
    private func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    private func dataFilePath() -> String {
        return documentsDirectory().stringByAppendingPathComponent("Location.plist")
    }
    
    private struct Key {
        static let Locations = "locations"
        static let CurrentLocation = "currentLocation"
    }
    
    func saveLocations() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(locations, forKey: Key.Locations)
        archiver.encodeObject(currentLocation, forKey: Key.CurrentLocation)
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    private func loadLocations() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                locations = unarchiver.decodeObjectForKey(Key.Locations) as! Array<Location>
                currentLocation = unarchiver.decodeObjectForKey(Key.CurrentLocation) as? Location
                unarchiver.finishDecoding()
            }
        }
    }
    
    var locations = Array<Location>()
    var events = Array<Event>()
    
    var currentLocation: Location? {
        didSet {
            requestNotificationPermission()
            getCurrentLocationWeather()
        }
    }
    
    private func requestNotificationPermission() {
        let notificationSettings = UIUserNotificationSettings( forTypes: [.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    private func getCurrentLocationWeather() {
        api.getWeatherData(currentLocation!.coordinateString) { [unowned self] weatherObject in
            self.currentLocation!.weatherObject = weatherObject
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            self.postLocationNotification()
            self.getSignificantWeatherChangeTime()
        }
    }
    
    private func postLocationNotification() {
        let notification = NSNotification(name: "Received New Location", object: nil, userInfo: ["newLocation" : self.currentLocation!])
        self.center.postNotification(notification)
    }
    
    func getSignificantWeatherChangeTime() {
        if let hourlyWeatherArray = currentLocation!.hourlyWeather {
            for var i = 2; i < hourlyWeatherArray.count; i++ {
                let next = hourlyWeatherArray[i], previous = hourlyWeatherArray[i-1]
                if next.imageName! != previous.imageName! {
                    let message = ("\(getAlertMessageFrom(next.imageName!)!) \(next.hour!)")
                    scheduleNotification(previous.unixTime!, alertBody: message)
                }
            }
        }
    }
    
    private func getAlertMessageFrom(imageName: String) -> String? {
        if let icon = Icon(rawValue: imageName) {
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
        return nil
    }
    
    private enum Icon: String {
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
    
    private struct Message {
        static let Clear = "Sky will be clear by"
        static let Rain = "Its likely to rain by"
        static let Snow = "It will probably snow by"
        static let Sleet = "It will probably sleet by"
        static let Wind = "Get cover wind is approaching by"
        static let Fog = "Weather will be foggy by"
        static let Cloudy = "It will be cloudy by"
    }
    
    func scheduleNotification(unixTime: Int, alertBody: String) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSince1970: NSTimeInterval(unixTime))
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = alertBody
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    
    
    func listenForNewLocation(){
        center.addObserverForName("Received Current Location", object: nil, queue: queue) { notification in
            if let location = notification.userInfo?["currentLocation"] as? Location {
                self.currentLocation = location
            }
        }
    }
    
    class var sharedInstance : DataModel {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : DataModel? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DataModel()
        }
        return Static.instance!
    }
    
    init() {
        api = APIController.sharedInstance
        loadLocations()
        listenForNewLocation()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}