//
//  String.swift
//  iWeather
//
//  Created by Ahmed Onawale on 9/12/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
    
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

extension UIFont {
    func bold() -> UIFont {
        let descriptor = self.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold)
        return UIFont(descriptor: descriptor, size: 0)
    }
}

public func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    let res = lhs.compare(rhs)
    return res == .OrderedAscending || res == .OrderedSame
}
public func >=(lhs: NSDate, rhs: NSDate) -> Bool {
    let res = lhs.compare(rhs)
    return res == .OrderedDescending || res == .OrderedSame
}
public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedDescending
}
public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}
public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedSame
}