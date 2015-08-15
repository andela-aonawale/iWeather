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
    
    class func convertNSRangeToSwiftRange(range: Range<Int>, string: String) -> Range<String.Index> {
        return Range<String.Index>(start: advance(string.startIndex, range.startIndex), end: advance(string.startIndex, range.endIndex))
    }
    
    class func dateStringFromTimezone(timeZone: String, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: timeZone)
        dateFormatter.timeStyle = timeStyle
        dateFormatter.dateStyle = dateStyle
        return dateFormatter.stringFromDate(NSDate())
    }
    
    class func dateStringFromTimezone(timeZone: String, unixTime: Int, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String{
        let dateFormatter = NSDateFormatter()
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(unixTime))
        dateFormatter.timeZone = NSTimeZone(name: timeZone)
        dateFormatter.timeStyle = timeStyle
        dateFormatter.dateStyle = dateStyle
        return dateFormatter.stringFromDate(date)
    }
}