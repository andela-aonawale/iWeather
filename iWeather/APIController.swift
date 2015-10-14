//
//  APIController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
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

class APIController {
    
    private struct API {
        private static let ForcastKEY = "e9f75045f39337c8df914eb723c4832b"
        private static let ForecastURL = "https://api.forecast.io/forecast/"
        private static var ForecastQuery: String! {
            let unit = NSUserDefaults.standardUserDefaults().stringForKey("unit")!
            return "units=\(unit)&exclude=minutely,alerts,flags"
        }
    }
    
    class var sharedInstance : APIController {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: APIController? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = APIController()
        }
        return Static.instance!
    }
    
    func getWeatherData(coordinate: String, completionHandler: (weatherObject: NSDictionary?, error: NSError?) -> Void) {
        let forecastURL = NSURLComponents(string: "\(API.ForecastURL)\(API.ForcastKEY)/\(coordinate)?")
        forecastURL?.query = API.ForecastQuery
        let task = NSURLSession.sharedSession().dataTaskWithURL(forecastURL!.URL!) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(weatherObject: nil, error: error)
                }
            }
            guard let HTTPresponse = response as? NSHTTPURLResponse where HTTPresponse.statusCode == 200 else {
                return
            }
            do {
                let weatherObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(weatherObject: weatherObject as? NSDictionary, error: nil)
                }
            } catch {
                print("JSON Error \(error)")
            }
        }
        task.resume()
    }
    
    func getWeatherForDate(date: NSDate, coordinate: String, completionHandler: (weatherObject: NSDictionary?, error: NSError?) -> Void) {
        let unixTime = Int(date.timeIntervalSince1970)
        let forecastURL = NSURLComponents(string: "\(API.ForecastURL)\(API.ForcastKEY)/\(coordinate),\(unixTime)?")
        forecastURL?.query = API.ForecastQuery
        let task = NSURLSession.sharedSession().dataTaskWithURL(forecastURL!.URL!) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(weatherObject: nil, error: error)
                }
            }
            guard let HTTPresponse = response as? NSHTTPURLResponse where HTTPresponse.statusCode == 200 else {
                return
            }
            do {
                let weatherObject = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(weatherObject: weatherObject as? NSDictionary, error: nil)
                }
            } catch {
                print("JSON Error \(error)")
            }
        }
        task.resume()
    }
    
}
