//
//  CurrentDayWeatherTableViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/31/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class CurrentDayWeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sunriseTime: UILabel!
    @IBOutlet weak var sunsetTime: UILabel!
    @IBOutlet weak var chanceOfRain: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var wind: UILabel!
    @IBOutlet weak var feelsLike: UILabel!
    @IBOutlet weak var precipitation: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var visibility: UILabel!
    @IBOutlet weak var uvIndex: UILabel!
    
    var currentDayWeather: DailyWeathear? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let weather = currentDayWeather {
            sunriseTime.text = weather.sunriseTime
            sunsetTime.text = weather.sunsetTime
            chanceOfRain.text = weather.precipProbability
            humidity.text = weather.humidity
            wind.text = weather.windSpeedString
            pressure.text = weather.pressureString
            visibility.text = weather.visibilityString
            precipitation.text = weather.precipIntensityString
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
