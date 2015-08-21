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

    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var weatherDescripion: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionViewParentView: UIView!
    
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var temperatureMax: UILabel!
    @IBOutlet weak var temperatureMin: UILabel!
    
    private func updateUIWithLocation(newLocation: Location?) {
        if let location = newLocation {
            self.day.text = location.currentDay.day
            self.temperatureMax.text = location.currentDay.temperatureMax
            self.temperatureMin.text = location.currentDay.temperatureMin
            self.temperature.text = location.currentWeather.temperature
            self.weatherDescripion.text = location.currentWeather.summary
            self.locationName.text = location.name
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }
    }
    
    var index = 0
    var location: Location?
    let whiteColor = UIColor.whiteColor()
    
    private func openLocationSettings(alert: UIAlertAction!) {
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    private func listenForLocationChange() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        center.addObserverForName("Received New Location", object: nil, queue: queue) { [weak self] notification in
            if let this = self {
                if let newLocation = notification.userInfo?["newLocation"] as? Location {
                    this.location = newLocation
                    this.updateUIWithLocation(newLocation)
                }
            }
            
        }
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.allowsSelection = false
        collectionView.backgroundColor = .clearColor()
        collectionViewParentView.addTopBorderWithColor(whiteColor, width: 0.5)
        collectionViewParentView.addBottomBorderWithColor(whiteColor, width: 0.5)
        updateUIWithLocation(self.location)
        if self.index == 0 {
            listenForLocationChange()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        if self.index == 0 {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
}


extension LocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = location?.dailyWeather?.count {
            return count + 2
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SummaryCell")
            if let daySummary = location?.dayWeatherSummary {
                let label = cell!.viewWithTag(10) as! UILabel
                label.text = "Today: \(daySummary)"
            }
            return cell!
        }
        if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CurrentDayCell") as! CurrentDayWeatherTableViewCell
            if let currentDay = location?.currentDay {
                cell.currentDayWeather = currentDay
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DaysCell") as! DailyWeatherTableViewCell
        if let dayWeather = location?.dailyWeather[indexPath.row] {
            cell.dayWeather = dayWeather
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tableHeight = tableView.frame.size.height
        if indexPath.row == 7 {
           return tableHeight / 3.5
        }
        if indexPath.row == 8 {
            return tableHeight * 1.3
        }
        return tableHeight / 7
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        if indexPath.row == 7 {
            cell.contentView.addTopBorderWithColor(whiteColor, width: 0.5)
            cell.contentView.addBottomBorderWithColor(whiteColor, width: 0.5)
        }
    }
    
}


extension LocationViewController: UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Collection View Methods
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Collection View Cell", forIndexPath: indexPath) as! WeatherCollectionViewCell
        
        if let hourWeather = location?.hourlyWeather[indexPath.row] as HourlyWeather? {
            cell.hourWeather = hourWeather
            if indexPath.row == 0 {
                cell.time?.text = "Now"
            }
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return location?.hourlyWeather?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.size.width / 6 , collectionView.frame.size.height)
    }
    
}


extension Weather {
    var weatherImage: UIImage? {
        return UIImage(named: imageName!)
    }
}
