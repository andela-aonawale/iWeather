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
        private static let GeocodeURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
        private static let GeocodeKey = "AIzaSyDo3xtVe5TuRDZ8PFrdLeuu14VCvM9ZILg"
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
                        completion(weatherObject: weatherObject as! NSDictionary)
                    } catch {
//                        let error: NSError?
//                        print("JSON Error \(error!.localizedDescription)", appendNewline: true)
                    }
                }
            }
        }
        task.resume()
    }
    
    func suggestLocation(location: String, completion: (locationObject: NSDictionary) -> Void) {
        let geocodeURL = NSURLComponents(string: API.GeocodeURL)
        geocodeURL?.query = "input=\(location)&key=\(API.GeocodeKey)"
        let task = session.dataTaskWithURL(geocodeURL!.URL!) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
            }
            if let HTTPresponse = response as? NSHTTPURLResponse {
                if HTTPresponse.statusCode == 200 {
                    do {
                        let locationObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                        completion(locationObject: locationObject as! NSDictionary)
                    } catch {
//                        let error: NSError?
//                        print("JSON Error \(error!.localizedDescription)", appendNewline: true)
                    }
                }
            }
        }
        task.resume()
    }
    
    func getWeatherDataForTime(unixTime: Int, coordinate: String, completion: (weatherObject: NSDictionary) -> Void) {
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
                        completion(weatherObject: weatherObject as! NSDictionary)
                    } catch {
//                        let error: NSError?
//                        print("JSON Error \(error!.localizedDescription)", appendNewline: true)
                    }
                } 
            }
            
        }
        task.resume()
    }
    
}
