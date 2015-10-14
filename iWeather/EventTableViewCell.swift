//
//  EventTableViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/10/15.
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

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventStartDate: UILabel!
    @IBOutlet weak var eventLocationName: UILabel!
    
    var event: Event? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let event = self.event {
            eventTitle.text = event.title
            eventStartDate.text = event.getEventDate()
            eventLocationName.text = event.eventLocationName
        }
    }

    var initialCenterPoint: CGPoint!

    private let weatherSlideView = UIView()
    private let deleteSlideView = UIView()
    private let deleteImageView = UIImageView()
    private let weatherImageView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addSubview(weatherSlideView)
        self.addSubview(deleteSlideView)
        weatherImageView.image = UIImage(named: "weather")
        deleteImageView.image = UIImage(named: "trash")
        deleteSlideView.addSubview(deleteImageView)
        weatherSlideView.addSubview(weatherImageView)
    }
    
    override func layoutSubviews() {
        let cellContentWidth = self.contentView.bounds.size.width
        let cellContentHeight = self.contentView.bounds.size.height
        weatherSlideView.frame = CGRect(x: cellContentWidth, y: 0, width: cellContentWidth, height: cellContentHeight)
        deleteSlideView.frame = CGRect(x: -cellContentWidth, y: 0, width: cellContentWidth, height: cellContentHeight)
        weatherSlideView.backgroundColor = UIColor.blueColor()
        deleteSlideView.backgroundColor = UIColor.redColor()
        initialCenterPoint = self.center
        deleteImageView.frame = CGRect(x: cellContentWidth-50, y: cellContentHeight/3.5, width: 30, height: 30)
        weatherImageView.frame = CGRect(x: 10, y: cellContentHeight/3.5, width: 40, height: 40)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
