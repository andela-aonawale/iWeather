//
//  AddLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, SearchResultViewControllerDelegate, APIControllerDelegate {
    
    private let api: APIController
    private var newLocation: Location? {
        didSet {
            api.getWeatherData(newLocation!.getCoordinate())
            dataModel.locations.append(newLocation!)
        }
    }
    private var dataModel: DataModel
    private var searchController: UISearchController!
    private let searchResultViewController: SearchResultViewController
    typealias address = (name: String, coordinate: (latitude: Double, longitude: Double))
    
    required init(coder aDecoder: NSCoder) {
        api = APIController()
        dataModel = DataModel()
        searchResultViewController = SearchResultViewController()
        searchController = UISearchController(searchResultsController: searchResultViewController)
        super.init(coder: aDecoder)
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
    
    func didReceiveWeatherResult(weatherObject: NSDictionary) {
        newLocation?.weatherObject = weatherObject
    }
    
    func didSelectLocationFromSearchResult(placemark: CLPlacemark, selectedAddress: String) {
        newLocation = Location(placemark: placemark)
        dismissViewControllerAnimated(true, completion: nil)
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
        searchController.searchBar.becomeFirstResponder()
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

}
