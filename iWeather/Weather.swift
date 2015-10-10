//
//  Weather.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class Weather: NSObject, NSCoding {
    
    var unixTime: Int!
    private var temperature: Double! = 0.0
    var humidity: String?
    var precipProbability: String?
    private var precipIntensity: Double!
    private var windSpeed: Double!
    private var pressure: Double!
    var summary: String?
    var imageName: String?
    private var visibility: Double! = 0.0
    private var apparentTemperature: Double! = 0.0
    var timeZone: String?
    
    var unit: String {
        return NSUserDefaults.standardUserDefaults().stringForKey("unit")!
    }
    
    var hour: String! {
        return NSDate.dateFormatFromUnixTime(unixTime, format: DateFormat.Hour, timeZone: timeZone!)
    }
    
    var date: String! {
        return NSDate.dateFormatFromUnixTime(unixTime, format: DateFormat.Date)
    }
    
    var time: String! {
        return NSDate.dateStringFromUnixTime(unixTime, dateStyle: .NoStyle, timeStyle: .ShortStyle)
    }
    
    var windSpeedString: String {
        if unit == "si" {
            return String(format: "%.0f km/h", windSpeed)
        } else {
            return String(format: "%.0f mph", windSpeed)
        }
    }
    
    var pressureString: String {
        if unit == "si" {
            let formattedPressure = NSNumberFormatter.localizedStringFromNumber(Int(pressure), numberStyle: .DecimalStyle)
            return String(format: "%@ mb", formattedPressure)
        } else {
            return String(format: "%.2f in", pressure)
        }
    }
    
    var precipIntensityString: String {
        if unit == "si" {
            return String(format: "%.1f mm", precipIntensity)
        } else {
            return String(format: "%.1f in", precipIntensity)
        }
    }
    
    var visibilityString: String {
        if unit == "si" {
            return String(format: "%.1f km", visibility)
        } else {
            return String(format: "%.1f mi", visibility)
        }
    }
    
    var temperatureString: String {
        return String(format: "%.0f", temperature)
    }
    
    var apparentTemperatureString: String {
        return String(format: "%.0f\u{00B0}", apparentTemperature)
    }
    
    func convertUnitsToSI() {
        fahrenheitToCelsius(&temperature!)
        milesToKilometers(&windSpeed!)
        inchesToMillibars(&pressure!)
        mmtoInches(&precipIntensity!)
        milesToKilometers(&visibility!)
        fahrenheitToCelsius(&apparentTemperature!)
    }
    
    func convertUnitsToUS() {
        celsiusToFahrenheit(&temperature!)
        kilometersToMiles(&windSpeed!)
        millibarsToInches(&pressure!)
        inchesToMM(&precipIntensity!)
        kilometersToMiles(&visibility!)
        celsiusToFahrenheit(&apparentTemperature!)
    }
    
    private func inchesToMM(inout precipIntenInInches: Double) {
        precipIntenInInches = precipIntenInInches * 25.4
    }
    
    private func mmtoInches(inout precipIntenInMM: Double) {
        precipIntenInMM = precipIntenInMM / 25.4
    }
    
    private func millibarsToInches(inout pressureInMB: Double) {
        pressureInMB = pressureInMB * 0.029529980164712
    }
    
    private func inchesToMillibars(inout pressureInInches: Double) {
        pressureInInches = pressureInInches * 33.86389
    }
    
    internal func fahrenheitToCelsius(inout tempInF: Double) {
        tempInF = (tempInF - 32) * (5/9)
    }
    
    internal func celsiusToFahrenheit(inout tempInC: Double) {
        tempInC = (tempInC * 9/5) + 32
    }
    
    private func milesToKilometers(inout speedInMPH: Double) {
        speedInMPH = speedInMPH * 1.60934
    }
    
    private func kilometersToMiles(inout speedInKPH: Double) {
        speedInKPH = speedInKPH / 1.60934
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(unixTime, forKey: WeatherConstant.Time)
        aCoder.encodeDouble(temperature, forKey: WeatherConstant.Temperature)
        aCoder.encodeObject(humidity, forKey: WeatherConstant.Humidity)
        aCoder.encodeObject(precipProbability, forKey: WeatherConstant.PrecipProbability)
        aCoder.encodeDouble(precipIntensity, forKey: WeatherConstant.PrecipIntensity)
        aCoder.encodeDouble(windSpeed, forKey: WeatherConstant.WindSpeed)
        aCoder.encodeDouble(pressure, forKey: WeatherConstant.Pressure)
        aCoder.encodeObject(summary, forKey: WeatherConstant.Summary)
        aCoder.encodeObject(imageName, forKey: WeatherConstant.ImageName)
        aCoder.encodeDouble(visibility, forKey: WeatherConstant.Visibility)
        aCoder.encodeDouble(apparentTemperature, forKey: WeatherConstant.ApparentTemperature)
        aCoder.encodeObject(timeZone, forKey: WeatherConstant.TimeZone)
    }
    
    required init?(coder aDecoder: NSCoder) {
        unixTime = aDecoder.decodeIntegerForKey(WeatherConstant.Time)
        temperature = aDecoder.decodeDoubleForKey(WeatherConstant.Temperature)
        humidity = aDecoder.decodeObjectForKey(WeatherConstant.Humidity) as? String
        precipProbability = aDecoder.decodeObjectForKey(WeatherConstant.PrecipProbability) as? String
        precipIntensity = aDecoder.decodeDoubleForKey(WeatherConstant.PrecipIntensity)
        windSpeed = aDecoder.decodeDoubleForKey(WeatherConstant.WindSpeed)
        pressure = aDecoder.decodeDoubleForKey(WeatherConstant.Pressure)
        summary = aDecoder.decodeObjectForKey(WeatherConstant.Summary) as? String
        imageName = aDecoder.decodeObjectForKey(WeatherConstant.ImageName) as? String
        visibility = aDecoder.decodeDoubleForKey(WeatherConstant.Visibility)
        apparentTemperature = aDecoder.decodeDoubleForKey(WeatherConstant.ApparentTemperature)
        timeZone = aDecoder.decodeObjectForKey(WeatherConstant.TimeZone) as? String
    }
    
    init(weatherDictionary: NSDictionary, timeZone: String) {
        
        self.timeZone = timeZone
        
        if let unixTime = weatherDictionary[WeatherConstant.Time] as? Int {
            self.unixTime = unixTime
        }
        if let temperature = weatherDictionary[WeatherConstant.Temperature] as? Double {
            self.temperature = temperature
        }
        if let humidity = weatherDictionary[WeatherConstant.Humidity] as? Double {
            self.humidity = String(format: "%d%%", Int(humidity * 100))
        }
        if let precipProbability = weatherDictionary[WeatherConstant.PrecipProbability] as? Double {
            self.precipProbability = String(format: "%.0f%%", precipProbability * 100)
        }
        if let precipIntensity =  weatherDictionary[WeatherConstant.PrecipIntensity] as? Double {
            self.precipIntensity = precipIntensity
        }
        if let windSpeed =  weatherDictionary[WeatherConstant.WindSpeed] as? Double {
            let inMPH = windSpeed * 2.23694
            if NSUserDefaults.standardUserDefaults().stringForKey("unit")! == "si" {
                self.windSpeed = inMPH * 1.60934
            } else {
                self.windSpeed = inMPH
            }
        }
        if let pressure =  weatherDictionary[WeatherConstant.Pressure] as? Double {
            self.pressure = pressure
        }
        if let iconName = weatherDictionary[WeatherConstant.Icon] as? String {
            self.imageName = iconName
        }
        if let visibility =  weatherDictionary[WeatherConstant.Visibility] as? Double {
            self.visibility = visibility
        }
        if let summary = weatherDictionary[WeatherConstant.Summary] as? String {
            self.summary = summary
        }
        if let apparentTemperature = weatherDictionary[WeatherConstant.ApparentTemperature] as? Double {
            self.apparentTemperature = apparentTemperature
        }
        super.init()
    }

}
