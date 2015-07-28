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
    
    private func updateUI() {
        if let location = self.location {
            locationName?.text = location.name
            locationTime?.text = location.currentWeather.time
            locationTemperatureDegree?.text = location.currentWeather.temperature?.description
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
