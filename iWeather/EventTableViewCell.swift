//
//  EventTableViewCell.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/10/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

protocol EventTableViewCellDelegate: class {
    func tableViewCell(didSwipeCellForDeletion cell: EventTableViewCell)
    func tableViewCell(didSwipeCellForWeather cell:EventTableViewCell)
}

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventStartDate: UILabel!
    @IBOutlet weak var eventLocationName: UILabel!
    
    var event: Event? { didSet { updateUI() } }
    
    private func updateUI() {
        if let event = self.event {
            eventTitle.text = event.title
            eventStartDate.text = event.getEventDate()
            eventLocationName.text = event.eventLocationName
        }
    }
    
    private struct Swipe {
        var delete: Bool!
        var showWeather: Bool!
    }

    var initialCenterPoint: CGPoint!
    private var swipeFarEnough = Swipe()
    private var weatherSlideView = UIView()
    private var deleteSlideView = UIView()
    weak var delegate: EventTableViewCellDelegate?
    
    private let deleteImageView = UIImageView()
    private let weatherImageView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let recognizer = UIPanGestureRecognizer(target: self, action: "pan:")
        recognizer.delegate = self
        self.addGestureRecognizer(recognizer)
        self.addSubview(weatherSlideView)
        self.addSubview(deleteSlideView)
    
        deleteImageView.image = UIImage(named: "Trash-White")
        deleteSlideView.addSubview(deleteImageView)
        
        weatherImageView.image = UIImage(named: "Weather")
        weatherSlideView.addSubview(weatherImageView)
    }
    
    var divInitialCenter: CGPoint!
    
    var initx: CGFloat!
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            initialCenterPoint = self.center
        case .Changed:
            let translation = gesture.translationInView(self)
            let originX = self.frame.origin.x
            let cellWidth = self.frame.size.width
            swipeFarEnough.delete = (originX > cellWidth / 2)
            swipeFarEnough.showWeather = (originX < -cellWidth / 2)
            self.center = CGPointMake(initialCenterPoint.x + translation.x, initialCenterPoint.y)
        case .Ended:
            let cell = (width: self.frame.size.width, height: self.frame.size.height)
            let initialFrame = CGRectMake(0, self.frame.origin.y, cell.width, cell.height)
            if !swipeFarEnough.showWeather && !swipeFarEnough.delete {
                UIView.animateWithDuration(0.1) { self.frame = initialFrame }
            }
            if swipeFarEnough.showWeather == true {
                UIView.animateWithDuration(0.1, animations: {
                    self.center = CGPointMake(-cell.width/2, self.initialCenterPoint.y)
                    }) { finished in
                        if finished == true {
                            self.delegate?.tableViewCell(didSwipeCellForWeather: self)
                        }
                }
            }
            if swipeFarEnough.delete == true {
                UIView.animateWithDuration(0.1, animations: {
                    self.center = CGPointMake(cell.width * 1.5, self.initialCenterPoint.y)
                    }) { finished in
                        if finished == true {
                            self.delegate?.tableViewCell(didSwipeCellForDeletion: self)
                        }
                }
            }
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        let cellContentWidth = self.contentView.bounds.size.width
        let cellContentHeight = self.contentView.bounds.size.height
        weatherSlideView.frame = CGRectMake(cellContentWidth, 0, cellContentWidth, cellContentHeight)
        deleteSlideView.frame = CGRectMake(-cellContentWidth, 0, cellContentWidth, cellContentHeight)
        weatherSlideView.backgroundColor = UIColor.blueColor()
        deleteSlideView.backgroundColor = UIColor.redColor()
        
        deleteImageView.frame = CGRectMake(cellContentWidth-50, cellContentHeight/3.5, 30, 30)
        weatherImageView.frame = CGRectMake(10, cellContentHeight/3.5, 40, 40)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
