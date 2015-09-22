//
//  Extension.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/29/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

extension NSDate {
    class func dateFormatFromUnixTime(unixTime: Int, format: String) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(weatherDate)
    }
    
    class func dateStringFromUnixTime(unixTime: Int, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        return dateFormatter.stringFromDate(weatherDate)
    }
    
    class func dateStringFromTimezone(timeZone: String?, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String? {
        if let timeZone = timeZone {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: timeZone)
            dateFormatter.timeStyle = timeStyle
            dateFormatter.dateStyle = dateStyle
            return dateFormatter.stringFromDate(NSDate())
        }
        return nil
    }
    
    class func dateStringFromTimezone(timeZone: String, unixTime: Int, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String{
        let dateFormatter = NSDateFormatter()
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(unixTime))
        dateFormatter.timeZone = NSTimeZone(name: timeZone)
        dateFormatter.timeStyle = timeStyle
        dateFormatter.dateStyle = dateStyle
        return dateFormatter.stringFromDate(date)
    }
    
    class func dateFormatFromUnixTime(unixTime: Int, format: String, timeZone: String) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: timeZone)
        return dateFormatter.stringFromDate(weatherDate)
    }
}