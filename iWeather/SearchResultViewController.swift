//
//  SearchResultViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/22/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreLocation

protocol SearchResultViewControllerDelegate: class {
    func didSelectLocationFromSearchResult(placemark: CLPlacemark, selectedAddress: String)
}

class SearchResultViewController: UITableViewController, UISearchResultsUpdating, APIControllerDelegate {
    
    private let api = APIController()
    private var predictions = [String]()
    weak var delegate: SearchResultViewControllerDelegate?
    
    func configureTableView() {
        tableView.rowHeight = 35
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    struct Cell {
        static let ReuseIdentifier = "AddressCell"
    }
    
    struct Places {
        static let Predictions = "predictions"
        static let Description = "description"
        static let Empty = "No results found."
    }
    
    // MARK: - UISearchResultsUpdating Delegate methods
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        count(searchText) > 0 ? api.suggestLocation(searchText) : println("")
    }
    
    // MARK: - API Controller Delegate Methods
    
    func didReceiveLocationResult(locationObject: NSDictionary) {
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
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        configureTableView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        predictions.removeAll(keepCapacity: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view DataSource and Delegate methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = predictions[indexPath.row]
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
            if error != nil {
                println(error.localizedDescription)
            } else if let placemark = placemarks?.first as? CLPlacemark {
                let formattedAddress = self.predictions[indexPath.row]
                self.delegate?.didSelectLocationFromSearchResult(placemark, selectedAddress: formattedAddress)
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
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.clearColor()
        cell.backgroundView?.backgroundColor = UIColor.clearColor()
    }

}
