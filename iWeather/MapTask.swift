//
//  MapTask.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/22/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
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

import Foundation
import GoogleMaps

class MapTask {
    
    enum Status: String {
        case OK = "OK"
        case NOT_FOUND = "NOT_FOUND"
        case ZERO_RESULTS = "ZERO_RESULTS"
        case MAX_WAYPOINTS_EXCEEDED = "MAX_WAYPOINTS_EXCEEDED"
        case INVALID_REQUEST = "INVALID_REQUEST"
        case OVER_QUERY_LIMIT = "OVER_QUERY_LIMIT"
        case REQUEST_DENIED = "REQUEST_DENIED"
        case UNKNOWN_ERROR = "UNKNOWN_ERROR"
    }
    
    var distance: Double!
    private var marker: GMSMarker!
    var expectedTravelTime: Int!
    private var polyline: GMSPolyline!
    private var overviewPolyline: Dictionary<NSObject, AnyObject>!
    private let baseURLDirections = NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?")
    
    func getDirectionsFrom(origin: String, to destination: String, waypoints: Array<String>!, travelMode: AnyObject!, completion: ((status: Status, success: Bool) -> Void)) {
        if origin.isEmpty || destination.isEmpty {
            return
        }
        let directionsURL = NSURLComponents(URL: baseURLDirections!, resolvingAgainstBaseURL: true)
        directionsURL?.query = "origin=\(origin)&destination=\(destination)"
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            guard let directionsData = NSData(contentsOfURL: (directionsURL?.URL)!) else {
                return
            }
            do {
                let dictionary = try NSJSONSerialization.JSONObjectWithData(directionsData, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                if let statusString = dictionary["status"] as! String?, status = Status(rawValue: statusString) {
                    switch status {
                        case .OK:
                            guard let route = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>).first else {
                                return
                            }
                            self.overviewPolyline = route["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                            let legs = route["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                            self.calculateTotalDistanceAndDuration(legs)
                            dispatch_async(dispatch_get_main_queue()) {
                                completion(status: status, success: true)
                            }
                        default:
                            dispatch_async(dispatch_get_main_queue()) {
                                completion(status: status, success: false)
                            }
                    }
                }
            } catch {
                
            }
        }
    }
    
    func createRoute() -> GMSPolyline {
        polyline?.map = nil
        if let points = overviewPolyline["points"] as? String {
            let path = GMSPath(fromEncodedPath: points)
            polyline = GMSPolyline(path: path)
            polyline.strokeColor = UIColor.blueColor()
            polyline.strokeWidth = 3.0
        }
        return polyline
    }
    
    func removePolyline() {
        polyline?.map = nil
    }
    
    func createMarker(atCoordinate coordinate: CLLocationCoordinate2D) -> GMSMarker {
        marker?.map = nil
        marker = GMSMarker(position: coordinate)
        marker.draggable = true
        marker.appearAnimation = kGMSMarkerAnimationPop
        return marker
    }
    
    private func calculateTotalDistanceAndDuration(legs: Array<Dictionary<NSObject, AnyObject>>) {
        var totalDistanceInMeters = 0
        var totalDurationInSeconds = 0
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! Int
            totalDurationInSeconds += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! Int
        }
        distance = Double(totalDistanceInMeters) / 1000
        expectedTravelTime = totalDurationInSeconds
    }
    
}
