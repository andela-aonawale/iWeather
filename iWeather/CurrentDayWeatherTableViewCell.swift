//
//  CurrentDayWeatherTableViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/31/15.
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
