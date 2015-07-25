//
//  DataModel.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import Foundation

class DataModel {
    var locations = [Location]() {
        didSet { println(locations) }
    }
    
    var currentLocation: Location! {
        didSet { println("auto get currentLocation:  \(currentLocation)") }
    }
}