//
//  UIViewExtension.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/9/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func addTopBorderWithColor(color: UIColor, lineWeight: CGFloat, lineWidth: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, 0, lineWidth, lineWeight)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(self.frame.size.width - width, 0, width, self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, lineWeight: CGFloat, lineWidth: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, self.frame.size.height - lineWeight, lineWidth, lineWeight)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, 0, width, self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    class func viewFromNibName(name: String) -> UIView? {
        let views = NSBundle.mainBundle().loadNibNamed(name, owner: nil, options: nil)
        return views.first as? MarkerInfoView
    }
}