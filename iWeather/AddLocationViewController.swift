//
//  AddLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UITableViewController, UISearchResultsUpdating, APIControllerDelegate {
    
    private var dataModel = DataModel()
    private let api = APIController()
    typealias address = (name: String, coordinate: (latitude: Double, longitude: Double))
    private var suggestedLocations: [address]
    private var searchController: UISearchController!
    
    private var predictions = [String]()
    private var newLocation: Location?
    
    struct Cell {
        static let ReuseIdentifier = "AddressCell"
    }
    
    struct Places {
        static let Predictions = "predictions"
        static let Description = "description"
        static let Empty = "No results found."
    }
    
    required init!(coder aDecoder: NSCoder!) {
        suggestedLocations = []
        super.init(coder: aDecoder)
    }
    
    func configureTableView() {
        tableView.rowHeight = 35
        tableView.tableHeaderView = searchController.searchBar
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.backgroundView?.backgroundColor = UIColor.clearColor()
    }
    
    func didReceiveLocationResult(locationObject: NSDictionary) {
        suggestedLocations.removeAll(keepCapacity: false)
        predictions.removeAll(keepCapacity: false)
        if let places = locationObject.valueForKey(Places.Predictions) as? NSArray {
            for place in places {
                predictions.append((place.valueForKey(Places.Description) as? String)!)
            }
            if predictions.isEmpty {
                predictions.append(Places.Empty)
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        count(searchText) > 0 ? api.suggestLocation(searchText) : println("")
    }
    
    func instantiateNewLocation(placemark: CLPlacemark) {
        let coordinate = (latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
        newLocation = Location(name: placemark.name, coordinate: coordinate)
        api.getWeatherData(newLocation!.getCoordinate())
        dataModel.locations.append(newLocation!)
    }
    
    func didReceiveWeatherResult(weatherObject: NSDictionary) {
        newLocation?.weatherObject = weatherObject
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = predictions[indexPath.row]
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
            if error != nil {
                println(error.localizedDescription)
            }
            if let placemark = placemarks?.first as? CLPlacemark {
                self.instantiateNewLocation(placemark)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(Cell.ReuseIdentifier) as! UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: Cell.ReuseIdentifier)
        }
        if let place = predictions[indexPath.row] as String? {
            cell.textLabel?.text = place ?? ""
        }
        
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        configureSearchController()
        configureTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }

}
