//
//  DailyWeatherTableViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/31/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class DailyWeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureMax: UILabel!
    @IBOutlet weak var temperatureMin: UILabel!
    @IBOutlet weak var day: UILabel!
    var dayWeather: DailyWeathear? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let weather = dayWeather {
            weatherImage.image = weather.weatherImage
            temperatureMax.text = weather.temperatureMax?.description
            temperatureMin.text = weather.temperatureMin?.description
            day.text = weather.day
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
