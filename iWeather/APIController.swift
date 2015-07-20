//
//  APIController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

struct API {
    private static let KEY = "e9f75045f39337c8df914eb723c4832b"
    private static let URL = "https://api.forecast.io/forecast/"
}

protocol APIControllerDelegate: class {
    func didReceiveWeatherResult(weatherObject: NSDictionary)
}

class APIController {
    
    weak var delegate: APIControllerDelegate?
    private let baseURL = NSURL(string: "\(API.URL)\(API.KEY)/")
    
    func getWeatherData(coordinate: String) {
        let forecastURL = NSURL(string: coordinate, relativeToURL: baseURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(forecastURL!) { data, response, error in
            if error != nil {
                println(error.localizedDescription)
            }
            var err: NSError?
            if let weatherObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                if err != nil {
                    println("JSON Error \(err!.localizedDescription)")
                } else {
                    self.delegate?.didReceiveWeatherResult(weatherObject as NSDictionary)
                }
            }
        }
        task.resume()
    }
    
}
