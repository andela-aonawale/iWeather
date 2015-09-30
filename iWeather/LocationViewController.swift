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
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var temperatureMax: UILabel!
    @IBOutlet weak var temperatureMin: UILabel!
    @IBOutlet weak var collectionViewSuperView: UIView!
    @IBOutlet weak var degreeSymbol: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    
    var index = 0
    var location: Location?
    
    private func isTheSameDay(unixTime: Int) -> Bool {
        let dayInLocation = NSDate(timeIntervalSince1970: NSTimeInterval(unixTime))
        let order = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: dayInLocation, toUnitGranularity: .Day)
        switch order {
            case .OrderedSame:
                return false
            default:
                return true
        }
    }
    
    private func updateUI() {
        locationName.text = location?.name ?? WeatherConstant.LocalWeather
        if let location = self.location, weather = location.currentDayWeather {
            todayLabel.hidden = isTheSameDay(weather.unixTime)
            day.text = location.currentDayWeather?.day
            temperatureMax.text = weather.temperatureMaxString
            temperatureMin.text = weather.temperatureMinString
            temperature.text = location.currentWeather?.temperatureString
            weatherDescripion.text = location.currentWeather?.summary
            degreeSymbol.hidden = false
            collectionView.reloadData()
            tableView.reloadData()
        }
    }
    
    private func listenForHourWeatherRemoval(){
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        center.addObserverForName(Notification.LocationDataUpdated, object: location, queue: queue) { [weak self] notification in
            if self?.index == 0 {
                if let pageViewController = self?.tabBarController?.selectedViewController as? PageViewController {
                    pageViewController.moveToPage((self?.index)!)
                }
            }
            self?.updateUI()
        }
    }
    
    // MARK: - VC life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.allowsSelection = false
        collectionView.backgroundColor = .clearColor()
        updateUI()
        listenForHourWeatherRemoval()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewSuperView.addTopBorderWithColor(.whiteColor(), lineWeight: 0.5, lineWidth: view.frame.width)
        collectionViewSuperView.addBottomBorderWithColor(.whiteColor(), lineWeight: 0.5, lineWidth: view.frame.width)
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
        if let count = location?.dailyWeather?.count {
            return count + 2
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 7 {
            if let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.SummaryCell) {
                if let daySummary = location?.dayWeatherSummary {
                    let label = cell.viewWithTag(10) as! UILabel
                    label.text = "Today: \(daySummary)"
                }
                return cell
            }
        }
        if indexPath.row == 8 {
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.CurrentDayCell) as! CurrentDayWeatherTableViewCell
            if let currentDay = location?.currentDayWeather {
                cell.currentDayWeather = currentDay
                cell.feelsLike.text = location?.currentWeather?.apparentTemperatureString
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.DaysCell) as! DailyWeatherTableViewCell
        if let dayWeather = location?.dailyWeather[safe: indexPath.row] {
            cell.dayWeather = dayWeather
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tableHeight = tableView.frame.size.height
        switch indexPath.row {
            case 7:
                return tableHeight / 2.5
            case 8:
                return tableHeight * 1.6
            default:
                return tableHeight / 7
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        if indexPath.row == 7 {
            cell.contentView.addTopBorderWithColor(.whiteColor(), lineWeight: 0.5, lineWidth: self.view.frame.width)
            cell.contentView.addBottomBorderWithColor(.whiteColor(), lineWeight: 0.5, lineWidth: self.view.frame.width)
        }
    }
    
}

extension LocationViewController: UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    // MARK: - Collection View Methods
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier.CollectionViewCell, forIndexPath: indexPath) as! WeatherCollectionViewCell
        if let hourWeather = location?.hourlyWeather[indexPath.row] as Weather? {
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
