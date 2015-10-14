//
//  SearchResultViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/22/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import GoogleMaps

protocol SearchResultViewControllerDelegate: class {
    func didSelectPlace(place: String, coordinate: CLLocationCoordinate2D)
}

class SearchResultViewController: UITableViewController, UISearchResultsUpdating {
    
    typealias place = (name: String, id: String)
    private var predictions = Array<place>()
    weak var delegate: SearchResultViewControllerDelegate?
    var placesClient: GMSPlacesClient?
    
    private func configureTableView() {
        tableView.rowHeight = 35
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    // MARK: - UISearchResultsUpdating Delegate methods
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text where !searchText.isEmpty {
            if Reachability.reachabilityForInternetConnection().isReachable() {
                suggestPlaces(searchText)
            } else {
                predictions.removeAll()
                predictions.append((name: "Network unavailable.", id: ""))
            }
        } else {
            predictions.removeAll()
        }
        tableView.reloadData()
    }
    
    private func suggestPlaces(searchText: String) {
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.Geocode
        placesClient?.autocompleteQuery(searchText, bounds: nil, filter: filter) { [unowned self] results, error in
            self.predictions.removeAll()
            if let error = error {
                self.predictions.append((name: "No results found.", id: ""))
                print("Autocomplete error \(error.localizedDescription)")
            } else if let results = results {
                for result in results {
                    if let result = result as? GMSAutocompletePrediction {
                        let place = (name: result.attributedFullText.string, id: result.placeID!)
                        self.predictions.append(place)
                    }
                }
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        placesClient = GMSPlacesClient()
    }
    
    override func viewWillAppear(animated: Bool) {
        predictions.removeAll()
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
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if !Reachability.reachabilityForInternetConnection().isReachable() || predictions[indexPath.row].id.isEmpty {
            return nil
        }
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true) { [unowned self] in
            let placeID = self.predictions[indexPath.row].id
            self.placesClient?.lookUpPlaceID(placeID) { place, error in
                if let place = place {
                    self.delegate?.didSelectPlace(place.name, coordinate: place.coordinate)
                }
                if let error = error {
                    print("error \(error.localizedDescription)")
                }
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.AddressCell) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier.AddressCell)
        }
        if let place = predictions[indexPath.row] as place? {
            cell.textLabel?.text = place.name
        }
        return cell
    }

}
