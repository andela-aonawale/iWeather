//
//  Extension.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/29/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

extension NSDate {
    func hourFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "Ka"
        return dateFormatter.stringFromDate(weatherDate)
    }
    
    func dateStringFromUnixTime(unixTime: Int) -> String {
        let timeInSeconds = NSTimeInterval(unixTime)
        let weatherDate = NSDate(timeIntervalSince1970: timeInSeconds)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter.stringFromDate(weatherDate)
    }
    
    func convertNSRangeToSwiftRange(range: Range<Int>, string: String) -> Range<String.Index> {
        return Range<String.Index>(start: advance(string.startIndex, range.startIndex), end: advance(string.startIndex, range.endIndex))
    }
    
    func localTimeForLocationFromAddressString(description: String) -> String {
        var regex: NSRegularExpression = NSRegularExpression(pattern: "\"[a-z]*\\/[a-z]*_*[a-z]*\"", options: NSRegularExpressionOptions.CaseInsensitive, error: nil)!
        var newSearchString: NSTextCheckingResult = regex.firstMatchInString(description, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(description)))!
        var timeZone: String = description.substringWithRange(convertNSRangeToSwiftRange(newSearchString.range.toRange()!, string: description))
        timeZone = dropFirst(timeZone.substringToIndex(timeZone.endIndex.predecessor()))
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone(name: timeZone)
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(NSDate())
    }
}