//
//  CurrentDayWeatherTableViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/31/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class CurrentDayWeatherTableViewCell: UITableViewCell {
    
    var sunSet: UILabel?
    var sunRise: UILabel?
    var chanceOfRain: UILabel?
    var humidity: UILabel?
    var wind: UILabel?
    var feelsLike: UILabel?
    var precepitation: UILabel?
    var pressure: UILabel?
    var visibility: UILabel?
    
    var dayWeather: DailyWeathear? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let weather = dayWeather {
            sunSet?.text = dayWeather?.sunsetTime
            sunRise?.text = dayWeather?.sunriseTime
            chanceOfRain?.text = dayWeather?.precipProbability
            humidity?.text = dayWeather?.humidity
            wind?.text = dayWeather?.windSpeed
            precepitation?.text = dayWeather?.precipIntensity
            pressure?.text = dayWeather?.pressure
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
