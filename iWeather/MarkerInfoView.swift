//
//  MarkerInfoView.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/24/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class MarkerInfoView: UIView {
    
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!

    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var currentSummary: UILabel!

    @IBOutlet weak var arrivalTemperature: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var arrivalSummary: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let radius: CGFloat = 2
    var fliped = false
    let api = APIController.sharedInstance
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
    
    private func getCurrentTravelLocationWeather() {
        api.getWeatherData(locationCoordinate) { weatherObject in
            if let currently = weatherObject.valueForKey("currently") as? NSDictionary {
                let currentWeather = CurrentWeather(weatherDictionary: currently)
                self.updateFrontViewUI(currentWeather)
            }
        }
    }
    
    private func getTravelLocationWeatherOnArrival() {
        api.getWeatherForDate(arrivalDate, coordinate: locationCoordinate) { weatherObject in
            if let currently = weatherObject.valueForKey("currently") as? NSDictionary {
                let currentWeather = CurrentWeather(weatherDictionary: currently)
                self.updateBackViewUI(currentWeather)
            }
        }
    }
    
    func updateBackViewUI(currentWeather: CurrentWeather) {
        if let weather = currentWeather as CurrentWeather? {
            arrivalTemperature.text = weather.temperature
            arrivalSummary.text = weather.summary
            arrivalTime.text = weather.date
        }
    }
    
    func updateFrontViewUI(currentWeather: CurrentWeather) {
        if let weather = currentWeather as CurrentWeather? {
            currentTemperature.text = weather.temperature
            currentSummary.text = weather.summary
            currentTime.text = weather.date
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
