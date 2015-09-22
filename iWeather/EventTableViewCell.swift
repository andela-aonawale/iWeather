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
        weatherSlideView.frame = CGRectMake(cellContentWidth, 0, cellContentWidth, cellContentHeight)
        deleteSlideView.frame = CGRectMake(-cellContentWidth, 0, cellContentWidth, cellContentHeight)
        weatherSlideView.backgroundColor = UIColor.blueColor()
        deleteSlideView.backgroundColor = UIColor.redColor()
        initialCenterPoint = self.center
        deleteImageView.frame = CGRectMake(cellContentWidth-50, cellContentHeight/3.5, 30, 30)
        weatherImageView.frame = CGRectMake(10, cellContentHeight/3.5, 40, 40)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
