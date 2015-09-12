//
//  APIController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class APIController {
    
    private struct API {
        private static let ForcastKEY = "e9f75045f39337c8df914eb723c4832b"
        private static let ForecastURL = "https://api.forecast.io/forecast/"
        private static let ForecastQuery = "units=auto&exclude=minutely,alerts,flags"
    }
    
    class var sharedInstance : APIController {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : APIController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = APIController()
        }
        return Static.instance!
    }
    
    private let session = NSURLSession.sharedSession()
    
    func getWeatherData(coordinate: String, completion: (weatherObject: NSDictionary) -> Void) {
        let forecastURL = NSURLComponents(string: "\(API.ForecastURL)\(API.ForcastKEY)/\(coordinate)?")
        forecastURL?.query = API.ForecastQuery
        let task = session.dataTaskWithURL(forecastURL!.URL!) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let HTTPresponse = response as? NSHTTPURLResponse {
                if HTTPresponse.statusCode == 200 {
                    do {
                        let weatherObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(weatherObject: weatherObject as! NSDictionary)
                        }
                    } catch {
                        print("JSON Error \(error)")
                    }
                }
            }
        }
        task.resume()
    }
    
    func getWeatherForDate(date: NSDate, coordinate: String, completion: (weatherObject: NSDictionary) -> Void) {
        let unixTime = Int(date.timeIntervalSince1970)
        let forecastURL = NSURLComponents(string: "\(API.ForecastURL)\(API.ForcastKEY)/\(coordinate),\(unixTime)?")
        forecastURL?.query = API.ForecastQuery
        let task = session.dataTaskWithURL(forecastURL!.URL!) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let HTTPresponse = response as? NSHTTPURLResponse {
                if HTTPresponse.statusCode == 200 {
                    do {
                        let weatherObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(weatherObject: weatherObject as! NSDictionary)
                        }
                    } catch {
                        print("JSON Error \(error)")
                    }
                } 
            }
            
        }
        task.resume()
    }
    
}
