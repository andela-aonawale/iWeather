//
//  WeatherCollectionViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/25/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var time: UILabel?
    @IBOutlet weak var icon: UIImageView?
    @IBOutlet weak var degree: UILabel?
    
    var hourWeather: HourlyWeather? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI() {
        if let weather = hourWeather {
            time?.text = hourWeather?.time
            icon?.image = hourWeather?.weatherImage
            degree?.text = hourWeather?.temperature
        }
    }
    
}
