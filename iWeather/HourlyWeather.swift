//
//  HourlyWeather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

final class HourlyWeather: Weather {
    
    var hour: String?
    var unixTime: Int?
    
    override init(weatherDictionary: NSDictionary) {
        if let unixTime = weatherDictionary.valueForKey("time") as? Int {
            self.unixTime = unixTime
            self.hour = NSDate.dateFormatFromUnixTime(unixTime, format: "Ka")
        }
        super.init(weatherDictionary: weatherDictionary)
    }
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(hour, forKey: "hour")
        aCoder.encodeInteger(unixTime!, forKey: "unixTime")
        super.encodeWithCoder(aCoder)
    }
    
    required init?(coder aDecoder: NSCoder) {
        hour = aDecoder.decodeObjectForKey("hour") as? String
        unixTime = aDecoder.decodeIntegerForKey("unixTime")
        super.init(coder: aDecoder)
    }
}