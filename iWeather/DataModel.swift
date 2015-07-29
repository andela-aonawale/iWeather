//
//  DataModel.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class DataModel: NSObject, APIControllerDelegate {
    
    private let api: APIController!
    let center = NSNotificationCenter.defaultCenter()
    let queue = NSOperationQueue.mainQueue()
    
    var locations = [Location]() {
        didSet { println(locations) }
    }
    
    var currentLocation: Location? {
        didSet {
            println("auto get currentLocation:  \(currentLocation)")
            api.getWeatherData(currentLocation!.getCoordinate())
        }
    }

    func didReceiveWeatherResult(weatherObject: NSDictionary) {
        currentLocation?.weatherObject = weatherObject
        let center = NSNotificationCenter.defaultCenter()
        let notification = NSNotification(name: "Received New Location", object: nil, userInfo: ["newLocation" : currentLocation!])
        center.postNotification(notification)
    }
    
    func methodOfReceivedNotification(){
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
        api = APIController()
        super.init()
        api.delegate = self
        methodOfReceivedNotification()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}