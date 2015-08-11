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
    
    class func localTimeForLocationFromAddressString(description: String, dateStyle: NSDateFormatterStyle, timeStyle: NSDateFormatterStyle) -> String {
        var regex: NSRegularExpression = NSRegularExpression(pattern: "\"[a-z]*\\/[a-z]*_*[a-z]*\"", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        var newSearchString: NSTextCheckingResult = regex.firstMatchInString(description, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(description)))!
        var timeZone: String = description.substringWithRange(convertNSRangeToSwiftRange(newSearchString.range.toRange()!, string: description))
        timeZone = dropFirst(timeZone.substringToIndex(timeZone.endIndex.predecessor()))
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: timeZone)
        dateFormatter.timeStyle = timeStyle
        dateFormatter.dateStyle = dateStyle
        return dateFormatter.stringFromDate(NSDate())
    }
}