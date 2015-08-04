//
//  HomeViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import Foundation

class LocationViewController: UIViewController {
    
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
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.reloadData()
        }
    }
    
    var location: Location?
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
            center.addObserverForName("Received New Location", object: nil, queue: queue) { [unowned self] notification in
                if let newLocation = notification?.userInfo?["newLocation"] as? Location {
                    self.location = newLocation
                    self.locationName.text = newLocation.name
                    self.weatherDesc.text = newLocation.currentWeather.summary
                    self.temp.text = newLocation.currentWeather.temperature
                    self.collectionView.reloadData()
                    self.tableView.reloadData()
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


extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = location?.dailyWeather.count {
            return count + 2
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell") as! UITableViewCell
            if let daySummary = location?.dayWeatherSummary {
                var label = cell.viewWithTag(10) as! UILabel
                label.text = daySummary
            }
            return cell
        } else if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CurrentDayCell") as! CurrentDayWeatherTableViewCell
            if let currentDay = location?.dailyWeather.first {
                cell.dayWeather = currentDay
            }
            return cell
        } else if indexPath.row < 7 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DaysCell") as! DailyWeatherTableViewCell
            if let dayWeather = location?.dailyWeather[indexPath.row] {
                cell.dayWeather = dayWeather
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 7 {
           return 70
        }
        if indexPath.row == 8 {
            return 180
        }
        return tableView.frame.size.height / 7
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 7 && indexPath.row != 6 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.frame.size.width, bottom: 0, right: 0)
        }
    }
    
}


extension LocationViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Collection View Methods
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CVCell", forIndexPath: indexPath) as! WeatherCollectionViewCell
        
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
