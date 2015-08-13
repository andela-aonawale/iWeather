//
//  DataModel.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class DataModel: NSObject {
    
    private let api: APIController!
    private let center = NSNotificationCenter.defaultCenter()
    private let queue = NSOperationQueue.mainQueue()
    
    var locations = [Location]()
    var events = [Event]()
    
    var currentLocation: Location? {
        didSet {
            println("auto get currentLocation:  \(currentLocation)")
            api.getWeatherData(currentLocation!.getCoordinate()) { weatherObject in
                self.currentLocation?.weatherObject = weatherObject
                let notification = NSNotification(name: "Received New Location", object: nil, userInfo: ["newLocation" : self.currentLocation!])
                self.center.postNotification(notification)
            }
        }
    }
    
    func listenForNewLocation(){
        center.addObserverForName("Received Current Location", object: nil, queue: queue) { notification in
            if let location = notification?.userInfo?["currentLocation"] as? Location {
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
    
    override init() {
        api = APIController.sharedInstance
        super.init()
        listenForNewLocation()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}