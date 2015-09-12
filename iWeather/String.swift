//
//  String.swift
//  iWeather
//
//  Created by Ahmed Onawale on 9/12/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

extension String {
    
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.stringByAppendingPathComponent(path)
    }
    
}