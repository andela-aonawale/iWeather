//
//  MarkerInfoView.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/24/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
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

import UIKit

class MarkerInfoView: UIView {
    
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!

    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var currentSummary: UILabel!
    @IBOutlet weak var currentETA: UILabel!
    @IBOutlet weak var currentDistance: UILabel!
    @IBOutlet weak var currentDegreeSymbol: UILabel!

    @IBOutlet weak var arrivalTemperature: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var arrivalSummary: UILabel!
    @IBOutlet weak var arrivalETA: UILabel!
    @IBOutlet weak var arrivalDistance: UILabel!
    @IBOutlet weak var arrivalDegreeSymbol: UILabel!

    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.startAnimating()
        }
    }
    
    let radius: CGFloat = 2
    var fliped = false
    var expectedTravelTime: Int! {
        didSet {
            currentETA.text = formatTimeFromSeconds(expectedTravelTime)
            arrivalETA.text = currentETA.text
        }
    }
    var distance: Double! {
        didSet {
            currentDistance.text = String(format: "%.1f km", distance )
            arrivalDistance.text = currentDistance.text
        }
    }
    var locationCoordinate: String! {
        didSet {
            getCurrentTravelLocationWeather()
        }
    }
    var arrivalDate: NSDate! {
        didSet {
            getTravelLocationWeatherOnArrival()
        }
    }
    
    private func formatTimeFromSeconds(seconds: Int) -> String {
        let minutes = (seconds / 60) % 60
        let hours = seconds / 3600
        if hours > 0 {
            return "\(hours) h \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }
    
    private func getCurrentTravelLocationWeather() {
        APIController.sharedInstance.getWeatherData(locationCoordinate) { [weak self] result, error in
            if let result = result, currently = result[WeatherConstant.Currently] as? NSDictionary {
                let timeZone = result[WeatherConstant.TimeZone] as! String
                let currentWeather = Weather(weatherDictionary: currently, timeZone: timeZone)
                self?.updateFrontViewUI(currentWeather)
            }
        }
    }
    
    private func getTravelLocationWeatherOnArrival() {
        APIController.sharedInstance.getWeatherForDate(arrivalDate, coordinate: locationCoordinate) { [weak self] result, error in
            if let result = result, currently = result[WeatherConstant.Currently] as? NSDictionary {
                let timeZone = result[WeatherConstant.TimeZone] as! String
                let currentWeather = Weather(weatherDictionary: currently, timeZone: timeZone)
                self?.updateBackViewUI(currentWeather)
            }
        }
    }
    
    func updateBackViewUI(currentWeather: Weather) {
        if let weather = currentWeather as Weather? {
            arrivalTemperature.text = weather.temperatureString
            arrivalSummary.text = weather.summary
            arrivalTime.text = weather.date
            arrivalDegreeSymbol.hidden = false
            frontView.backgroundColor = weatherColorFromImageName(weather.imageName!, frame: frame)
        }
    }
    
    func updateFrontViewUI(currentWeather: Weather) {
        if let weather = currentWeather as Weather? {
            activityIndicator.stopAnimating()
            currentTemperature.text = weather.temperatureString
            currentSummary.text = weather.summary
            currentTime.text = weather.date
            currentDegreeSymbol.hidden = false
            backView.backgroundColor = weatherColorFromImageName(weather.imageName!, frame: frame)
        }
    }
    
    func flipToFrontView() {
        UIView.transitionFromView(backView, toView: frontView, duration: 0.3, options: [.TransitionFlipFromRight, .ShowHideTransitionViews, .AllowAnimatedContent], completion: nil)
    }
    
    func flipToBackView() {
        UIView.transitionFromView(frontView, toView: backView, duration: 0.3, options: [.TransitionFlipFromLeft, .ShowHideTransitionViews, .AllowAnimatedContent], completion: nil)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        switch fliped {
            case true:
                flipToFrontView()
                fliped = !fliped
            case false:
                flipToBackView()
                fliped = !fliped
        }
    }
    
    override func drawRect(rect: CGRect) {
        layer.cornerRadius = radius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.5
        layer.shadowPath = shadowPath.CGPath
    }

}
