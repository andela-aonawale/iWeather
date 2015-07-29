//
//  HomeViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import Foundation

class LocationViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Collection View Methods
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CVCell", forIndexPath: indexPath) as! WeatherCollectionViewCell
        cell.hourWeather = location!.hourlyWeather[indexPath.row]
        if let hourWeather: HourlyWeather? = location!.hourlyWeather[indexPath.row] as HourlyWeather? {
            cell.hourWeather = hourWeather
            if indexPath.row == 0 {
                cell.time?.text = "Now"
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = location?.hourlyWeather.count {
            return count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.size.width / 6 , collectionView.frame.size.height)
    }
    
    @IBOutlet weak var temp: UILabel! {
        didSet {
            temp.text = location?.currentWeather.temperature
        }
    }
    @IBOutlet weak var weatherDesc: UILabel! {
        didSet {
            weatherDesc.text = location?.currentWeather.summary
        }
    }
    @IBOutlet weak var locationName: UILabel! {
        didSet {
            locationName.text = location?.name
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var location: Location? {
        didSet {
            
        }
    }
    var index = 0
    
    func openLocationSettings(alert: UIAlertAction!) {
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.index == 0 {
            let center = NSNotificationCenter.defaultCenter()
            let queue = NSOperationQueue.mainQueue()
            center.addObserverForName("Received New Location", object: nil, queue: queue) { notification in
                if let newLocation = notification?.userInfo?["newLocation"] as? Location {
                    self.location = newLocation
                    self.locationName.text = newLocation.name
                    self.weatherDesc.text = newLocation.currentWeather.summary
                    self.temp.text = newLocation.currentWeather.temperature
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
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
