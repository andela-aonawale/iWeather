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
    var location: Location? {
        didSet {
            updateUI()
        }
    }
    var timer: NSTimer!
    
    private func updateUI() {
        if let location = self.location {
            locationName.text = location.name
            locationTemperatureDegree.text = location.currentWeather?.temperature
            locationTime.text = location.currentTime
            timer?.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        }
    }
    
    func updateTime() {
        locationTime.text = location?.currentTime
        locationTemperatureDegree.text = location?.currentWeather?.temperature
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
