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

class SearchResultViewController: UITableViewController, UISearchResultsUpdating {
    
    private let api = APIController.sharedInstance
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
        if !searchText.isEmpty {
            api.suggestLocation(searchText) { [unowned self] locationObject in
                self.predictions.removeAll(keepCapacity: false)
                if let places = locationObject.valueForKey(Places.Predictions) as? NSArray {
                    for place in places {
                        self.predictions.append((place.valueForKey(Places.Description) as? String)!)
                    }
                    if self.predictions.isEmpty {
                        self.predictions.append(Places.Empty)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view DataSource and Delegate methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let location = predictions[indexPath.row]
        dismissViewControllerAnimated(true, completion: nil)
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) in
            if error != nil {
                println(error.localizedDescription)
            } else if let placemark = placemarks?.first as? CLPlacemark {
                let formattedAddress = self.predictions[indexPath.row]
                self.delegate?.didSelectLocationFromSearchResult(placemark, selectedAddress: formattedAddress)
            }
        }
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

}
