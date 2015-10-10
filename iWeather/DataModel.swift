//
//  DataModel.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class DataModel {
    
    var events = [Event]()
    var locations = [Location]()
    
    var unit: String {
        return NSUserDefaults.standardUserDefaults().stringForKey("unit")!
    }
    
    @objc func convertUnitsToCelcius() {
        if unit != "si" {
            for location in locations {
                location.convertWeatherUnitsToSI()
            }
            NSUserDefaults.standardUserDefaults().setObject("si", forKey: "unit")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    @objc func convetUnitsToFarenheit() {
        if unit != "us" {
            for location in locations {
                location.convertWeatherUnitsToUS()
            }
            NSUserDefaults.standardUserDefaults().setObject("us", forKey: "unit")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
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
            guard let data = NSData(contentsOfFile: path) else {
                return
            }
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            guard let locations = unarchiver.decodeObjectForKey(Key.Locations) as? [Location] else {
                return
            }
            self.locations = locations
            defer {
                unarchiver.finishDecoding()
            }
        }
    }
    
    private func registerDefaults() {
        NSUserDefaults.standardUserDefaults().registerDefaults(["unit": "si"])
    }
    
    class var sharedInstance : DataModel {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: DataModel? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = DataModel()
        }
        return Static.instance!
    }
    
    init() {
        registerDefaults()
        loadLocations()
    }

}