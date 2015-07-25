//
//  HomeViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

enum Storyboard {
    
}

class HomeViewController: UIViewController, CLLocationManagerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, APIControllerDelegate {
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CVCell", forIndexPath: indexPath) as! WeatherCollectionViewCell
        cell.hourWeather = dataModel.currentLocation?.hourlyWeather[indexPath.row]
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = dataModel.currentLocation?.hourlyWeather.count {
            return count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.size.width / 6 , collectionView.frame.size.height)
    }
    
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var weatherDesc: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    private let locationManager: CLLocationManager
    private var dataModel = DataModel()
    private let api: APIController
    
    func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func didReceiveWeatherResult(weatherObject: NSDictionary) {
        dataModel.currentLocation?.weatherObject = weatherObject
        collectionView.reloadData()
        locationName.text = dataModel.currentLocation.name
        weatherDesc.text = dataModel.currentLocation.currentWeather.summary
        temp.text = dataModel.currentLocation.currentWeather.temperature?.description
    }
    
    func openLocationSettings(alert: UIAlertAction!) {
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func enableLocationAccess() {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "In order get your location, please open this app's settings and enable location access.",
            preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let openAction = UIAlertAction(title: "Open Settings", style: .Default, handler: openLocationSettings)
        alertController.addAction(cancelAction)
        alertController.addAction(openAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func informUserThatGPSWillNotWork() {
        let alertController = UIAlertController(
            title: "Location Access Denied",
            message: "iWeather will be unable to get your current location.",
            preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        let openAction = UIAlertAction(title: "Enable", style: .Default, handler: openLocationSettings)
        alertController.addAction(cancelAction)
        alertController.addAction(openAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case CLAuthorizationStatus.Denied:
            informUserThatGPSWillNotWork()
        default:
            break
        }
    }
    
    func instantiateCurrentLocation(placemark: CLPlacemark) {
        let coordinate = (latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
        dataModel.currentLocation = Location(placemark: placemark)
        api.getWeatherData(dataModel.currentLocation!.getCoordinate())
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
        CLGeocoder().reverseGeocodeLocation(manager.location) { (placemarks, error) in
            if error != nil {
                println(error.localizedDescription)
            } else if let placemark = placemarks?.first as? CLPlacemark {
                self.instantiateCurrentLocation(placemark)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if error.domain == kCLErrorDomain {
            switch error.code {
            case CLError.LocationUnknown.rawValue:
                println("The location manager was unable to obtain a location value right now.")
            case CLError.Denied.rawValue:
                enableLocationAccess()
            case CLError.Network.rawValue:
                println("The network was unavailable or a network error occurred")
            default:
                break
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        api = APIController()
//        dataModel = DataModel()
        locationManager = CLLocationManager()
        super.init(coder: aDecoder)
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        initLocationManager()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Weather {
    var weatherImage: UIImage? {
        if let image = UIImage(named: imageName!) {
            return image
        } else {
            return nil
        }
    }
}
