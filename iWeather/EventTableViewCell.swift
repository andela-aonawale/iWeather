//
//  EventTableViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/10/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

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
