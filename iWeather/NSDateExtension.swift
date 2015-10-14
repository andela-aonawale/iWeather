//
//  Extension.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/29/15.
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