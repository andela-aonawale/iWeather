//
//  AddLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, UITableViewDataSource, SearchResultViewControllerDelegate, APIControllerDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationTableViewCell
        cell.location = dataModel.locations[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private let api: APIController
    private var newLocation: Location? {
        didSet {
            api.getWeatherData(newLocation!.getCoordinate())
        }
    }
    private var dataModel: DataModel
    private var searchController: UISearchController!
    private let searchResultViewController: SearchResultViewController
    typealias address = (name: String, coordinate: (latitude: Double, longitude: Double))
    
    required init(coder aDecoder: NSCoder) {
        api = APIController()
        dataModel = DataModel.sharedInstance
        searchResultViewController = SearchResultViewController()
        searchController = UISearchController(searchResultsController: searchResultViewController)
        super.init(coder: aDecoder)
    }
    
    func didReceiveWeatherResult(weatherObject: NSDictionary) {
        newLocation?.weatherObject = weatherObject
        dataModel.locations.append(newLocation!)
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    func didSelectLocationFromSearchResult(placemark: CLPlacemark, selectedAddress: String) {
        newLocation = Location(placemark: placemark)
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: - UISearchBar Delegate methods
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UISearchControllerDelegate Methods
    
    func willPresentSearchController(searchController: UISearchController) {
        let controller = searchController.searchResultsController as! SearchResultViewController
        controller.delegate = self
        dispatch_async(dispatch_get_main_queue()) {
            searchController.searchResultsController.view.hidden = false
        }
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchResultsController.view.hidden = false
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        searchController.searchBar.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        configureSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureSearchController() {
        searchController.delegate = self
        definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        navigationItem.titleView = searchController.searchBar
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = searchResultViewController
    }

}
