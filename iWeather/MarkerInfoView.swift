//
//  MarkerInfoView.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/24/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class MarkerInfoView: UIView {
    
    let radius: CGFloat = 2
    
    override func layoutSubviews() {
        layer.cornerRadius = radius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 3);
        layer.shadowOpacity = 0.5
        layer.shadowPath = shadowPath.CGPath
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("touchesEnded")
    }
    
}
