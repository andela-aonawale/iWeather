//
//  Weather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import UIKit

class Weather {
    var currentTime: String?
    var temperature: Int?
    var humidity: Double
    var precipProbability: Double
    var precipIntensity: Double?
    var windSpeed: Double?
    var pressure: Double?
    var summary: String
//    var icon: UIImage?
    
    init(weatherDictionary: NSDictionary) {
        temperature = weatherDictionary.valueForKey("temperature") as? Int
        humidity = weatherDictionary.valueForKey("humidity") as! Double
        precipProbability = weatherDictionary.valueForKey("precipProbability") as! Double
        summary = weatherDictionary.valueForKey("summary") as! String
        
        let currentTimeIntValue = weatherDictionary.valueForKey("time") as! Int
        currentTime = Weather.dateStringFromUnixTime(currentTimeIntValue)
        
        let iconString = weatherDictionary["icon"] as! String
//        icon = weatherIconFromString(iconString)
    }
    
    class func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        
        return dateFormatter.stringFromDate(weatherDate)
    }
    
    func weatherIconFromString(stringIcon: String) -> UIImage {
        var imageName: String
        
        switch stringIcon {
        case "clear-day":
            imageName = "clear-day"
        case "clear-night":
            imageName = "clear-night"
        case "rain":
            imageName = "rain"
        case "snow":
            imageName = "snow"
        case "sleet":
            imageName = "sleet"
        case "wind":
            imageName = "wind"
        case "fog":
            imageName = "fog"
        case "cloudy":
            imageName = "cloudy"
        case "partly-cloudy-day":
            imageName = "partly-cloudy"
        case "partly-cloudy-night":
            imageName = "cloudy-night"
        default:
            imageName = "default"
        }
        
        let iconName = UIImage(named: imageName)
        return iconName!
    }

}
