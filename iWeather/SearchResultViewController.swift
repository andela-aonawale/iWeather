//
//  SearchResultViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/22/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

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
    
    func configureTableView() {
        tableView.rowHeight = 35
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    // MARK: - UISearchResultsUpdating Delegate methods
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = searchController.searchBar.text
        if searchText!.isEmpty {
            predictions.removeAll()
            tableView.reloadData()
        } else {
            suggestPlaces(searchText)
        }
    }
    
    private func suggestPlaces(searchText: String?) {
        let filter = GMSAutocompleteFilter()
        filter.type = GMSPlacesAutocompleteTypeFilter.Geocode
        placesClient?.autocompleteQuery(searchText!, bounds: nil, filter: filter) { [unowned self] results, error in
            if let error = error {
                print("Autocomplete error \(error.localizedDescription)")
                self.predictions.removeAll()
                self.tableView.reloadData()
            }
            if let results = results {
                self.predictions.removeAll()
                for result in results {
                    if let result = result as? GMSAutocompletePrediction {
                        let place = (name: result.attributedFullText.string, id: result.placeID!)
                        self.predictions.append(place)
                    }
                }
                self.tableView.reloadData()
            }
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        dismissViewControllerAnimated(true) { [unowned self] in
            let placeID = self.predictions[indexPath.row].id
            self.placesClient?.lookUpPlaceID(placeID) { place, error in
                if let place = place {
                    self.delegate?.didSelectPlace(place.name, coordinate: place.coordinate)
                }
                if let error = error {
                    print("error \(error.localizedDescription)")
                }
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
