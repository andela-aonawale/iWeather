//
//  EventWeatherPopoverViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/12/15.
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
import CoreLocation

class EventWeatherPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventWeatherTemperature: UILabel!
    @IBOutlet weak var eventWeatherDescription: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var degreeSymbol: UILabel!
    
    weak var event: Event? {
        didSet {
            createLocation()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        listenForEventLocationWeather()
    }
    
    func listenForEventLocationWeather(){
        let queue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(Notification.LocationDataUpdated, object: nil, queue: queue) { [weak self] notification in
            self?.updateUI()
            self?.collectionView.reloadData()
        }
    }
    
    private func updateUI() {
        if let weather = event?.location?.currentWeather {
            eventWeatherTemperature.text = weather.temperatureString
            eventWeatherDescription.text = weather.summary
            eventTime.text = weather.time
            degreeSymbol.hidden = false
            view.backgroundColor = weatherColorFromImageName(weather.imageName!, frame: view.frame)
            activityIndicator.stopAnimating()
        }
    }
    
    func createLocation() {
        guard let event = self.event where event.location == nil else {
            return
        }
        if let coordinate = event.eventLocationCoordinate {
            let coordinate = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
            event.location = Location(name: event.eventLocationName!, coordinate: coordinate)
        } else {
            getEventPlacemarkFromLocationName(event.eventLocationName!) {
                if let coordinate = $0.location?.coordinate {
                    let coordinate = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    event.location = Location(name: $0.name!, coordinate: coordinate)
                }
            }
        }
    }
    
    private func getEventPlacemarkFromLocationName(location: String, completed: (placemark: CLPlacemark) -> Void) {
        let locationManager = LocationManager.sharedInstance
        locationManager.geocodeAddressFromString(location) { [weak self] placemarks, error in
            if error != nil {
                print(error.localizedDescription)
                self?.activityIndicator.stopAnimating()
            } else if let placemark = placemarks?.first as? CLPlacemark {
                completed(placemark: placemark)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        eventName.text = event?.title
        collectionView.backgroundColor = .clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if let superView = view.superview {
            let radius: CGFloat = 0
            superView.layer.cornerRadius = radius
            let shadowPath = UIBezierPath(roundedRect: superView.bounds, cornerRadius: radius)
            superView.layer.masksToBounds = false
            superView.layer.shadowColor = UIColor.blackColor().CGColor
            superView.layer.shadowOffset = CGSize(width: 0, height: 0)
            superView.layer.shadowOpacity = 0.5
            superView.layer.shadowPath = shadowPath.CGPath
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredContentSize: CGSize {
        get {
            if presentingViewController != nil {
                var width: CGFloat {
                    let pvcWidth = presentingViewController!.view.bounds.width
                    return (pvcWidth - pvcWidth/10)
                }
                var height: CGFloat {
                    return presentingViewController!.view.bounds.height / 2
                }
                return CGSize(width: width, height: height)
            } else {
                return super.preferredContentSize
            }
        }
        set { super.preferredContentSize = newValue }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}

extension EventWeatherPopoverViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.CollectionViewCell, forIndexPath: indexPath) as! WeatherCollectionViewCell
        if let hourWeather = event?.location?.hourlyWeather?[indexPath.row] as Weather? {
            cell.hourWeather = hourWeather
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return event?.location?.hourlyWeather?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 6 , height: collectionView.frame.size.height)
    }
    
}
