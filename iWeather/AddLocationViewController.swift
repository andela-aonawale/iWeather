//
//  AddLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UITableViewController, UISearchResultsUpdating {
    
    var suggestedLocations = [String]()
    var dataModel = DataModel()
    var searchController: UISearchController!
    let geocoder = CLGeocoder()
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        geocoder.cancelGeocode()
        let searchText = searchController.searchBar.text
        getLocation(searchText)
//        
//        suggestedLocations = searchText.isEmpty ? suggestedLocations : suggestedLocations.filter({(dataString: String) -> Bool in
//            return dataString.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
//        })
//        tableView.reloadData()
    }
    
    let session = NSURLSession.sharedSession()
    let baseURL = NSURL(string: "https://maps.googleapis.com/maps/api/geocode/json?address=")
    
    func getLocation(text: String) {
        let forecastURL = NSURL(string: text, relativeToURL: baseURL)
        let task = session.dataTaskWithURL(forecastURL!) { data, response, error in
            if error != nil {
                println(error.localizedDescription)
            }
            var err: NSError?
            if let locationObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                if err != nil {
                    println("JSON Error \(err!.localizedDescription)")
                } else {
                   println(locationObject["results"])
                }
            }
        }
        task.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
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
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return suggestedLocations.count
    }

}
