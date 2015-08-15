//
//  EventWeatherPopoverViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/12/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreLocation

class EventWeatherPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var eventName: UILabel! {
        didSet { eventName.text = event?.title }
    }
    @IBOutlet weak var eventWeatherImage: UIImageView!
    @IBOutlet weak var eventWeatherTemperature: UILabel!
    @IBOutlet weak var eventWeatherDescription: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let locationManager = LocationManager.sharedInstance
    
    weak var event: Event? { didSet { createLocation() } }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        listenForEventLocationWeather()
    }
    
    func listenForEventLocationWeather(){
        let queue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName("Received Event Location Weather", object: nil, queue: queue) { [weak self] notification in
            dispatch_async(dispatch_get_main_queue()) {
                if let this = self {
                    this.updateUI()
                    this.collectionView.reloadData()
                }
            }
        }
    }
    
    private func updateUI() {
        if let weather = event?.location?.currentWeather {
            eventWeatherImage.image = weather.weatherImage
            eventWeatherTemperature.text = weather.temperature
            eventWeatherDescription.text = weather.summary
            eventTime.text = weather.time
            activityIndicator.stopAnimating()
        }
    }
    
    func createLocation() {
        if let event = event {
            if event.location == nil {
                if let coordinate = event.eventLocationCoordinate {
                    event.location = Location(name: event.eventLocationName!, coordinate: event.eventLocationCoordinate!)
                } else {
                    getEventPlacemarkFromLocationName(event.eventLocationName!) {
                        event.location = Location(placemark: $0)
                    }
                }
            }
        }
    }
    
    private func getEventPlacemarkFromLocationName(location: String, completed: (placemark: CLPlacemark) -> Void) {
        locationManager.geocodeAddressFromString(location) { [unowned self] placemarks, error in
            if error != nil {
                println(error.localizedDescription)
                self.activityIndicator.stopAnimating()
            } else if let placemark = placemarks?.first as? CLPlacemark {
                completed(placemark: placemark)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        collectionView.backgroundColor = .clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if let superView = view.superview {
            superView.layer.cornerRadius = 0
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
                return CGSizeMake(width, height)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Collection View Cell", forIndexPath: indexPath) as! WeatherCollectionViewCell
        if let hourWeather = event?.location?.hourlyWeather[indexPath.row] as HourlyWeather? {
            cell.hourWeather = hourWeather
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return event?.location?.hourlyWeather?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.size.width / 6 , collectionView.frame.size.height)
    }
    
}
