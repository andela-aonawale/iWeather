//
//  DataModel.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import UIKit

class DataModel: NSObject {
    
    var events: [Event]
    var locations: [Location]
    
    func convertUnitsToCelcius() {
        print("touch convetUnitsToCelcius")
    }
    
    func convetUnitsToFarenheit() {
        print("touch convetUnitsToFarenheit")
    }
    
    private func documentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    private func dataFilePath() -> String {
        return documentsDirectory().stringByAppendingPathComponent(Path.Location)
    }
    
    func saveLocations() {
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(locations, forKey: Key.Locations)
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    private func loadLocations() {
        let path = dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            if let data = NSData(contentsOfFile: path) {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                locations = unarchiver.decodeObjectForKey(Key.Locations) as! Array<Location>
                unarchiver.finishDecoding()
            }
        }
    }
    
    private func requestNotificationPermission() {
        let notificationSettings = UIUserNotificationSettings( forTypes: [.Alert, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    private func listenForNewLocation(){
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        center.addObserverForName(Notification.UserCurrentLocation, object: nil, queue: queue) { [unowned self] notification in
            if let userLocation = notification.userInfo?[Notification.UserLocation] as? Location {
                if let _ = self.locations[safe: 0] {
                    self.locations[0] = userLocation
                } else {
                    self.locations.insert(userLocation, atIndex: 0)
                }
                UIApplication.sharedApplication().cancelAllLocalNotifications()
                self.requestNotificationPermission()
                //self.getSignificantWeatherChangeTime()
            }
        }
    }
    
    private func getSignificantWeatherChangeTime() {
        if let hourlyWeather = locations.first?.hourlyWeather {
            for index in 2..<hourlyWeather.count {
                let next = hourlyWeather[index], previous = hourlyWeather[index-1]
                if next.imageName! != previous.imageName! {
                    let message = ("\(getAlertMessageFrom(next.imageName!)!) \(next.hour)")
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
    
    private func scheduleNotification(unixTime: Int, alertBody: String) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSince1970: NSTimeInterval(unixTime))
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = alertBody
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
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
    
    override init() {
        events = [Event]()
        locations = [Location]()
        super.init()
        loadLocations()
        listenForNewLocation()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}