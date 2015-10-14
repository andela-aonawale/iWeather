//
//  LocationTableViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/26/15.
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
