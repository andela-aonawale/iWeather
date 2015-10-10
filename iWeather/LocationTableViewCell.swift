//
//  LocationTableViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/26/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationTime: UILabel!
    @IBOutlet weak var locationTemperatureDegree: UILabel!
    @IBOutlet weak var degreeSymbol: UILabel!
    
    var timer: NSTimer!
    var location: Location? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let location = self.location {
            locationName.text = location.name
            locationTemperatureDegree.text = location.currentWeather?.temperatureString
            locationTime.text = location.currentTime
            degreeSymbol.hidden = !location.hasWeatherData
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        }
    }
    
    func updateTime() {
        locationTime.text = location?.currentTime
        degreeSymbol.hidden = !(location?.hasWeatherData)!
        locationTemperatureDegree.text = location?.currentWeather?.temperatureString
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
