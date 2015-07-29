//
//  AddLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, UITableViewDelegate, UITableViewDataSource, SearchResultViewControllerDelegate, APIControllerDelegate, UITabBarControllerDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationTableViewCell
        if let location: Location? = dataModel.locations[indexPath.row] as Location? {
            cell.location = location
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            dataModel.locations.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            if let pageViewController = tabBarController?.viewControllers?.first as? PageViewController {
                pageViewController.moveToPage(indexPath.row - 1)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tabBarController?.selectedIndex = 0
        if let pageViewController = tabBarController?.selectedViewController as? PageViewController {
            pageViewController.moveToPage(indexPath.row)
        }
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
        hideSearchBar()
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        searchController.searchBar.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView(frame: CGRectZero)
        api.delegate = self
        configureSearchController()
        tableView.contentInset = UIEdgeInsets(top: -140, left: 0, bottom: 0, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureSearchController() {
        searchController.delegate = self
        definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = searchResultViewController
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        hiddenAddBarButtonItem = navigationItem.rightBarButtonItem
    }
    
    var hiddenAddBarButtonItem: UIBarButtonItem?
    
    @IBAction func addLocationBarButtonPressed(sender: AnyObject) {
        showSearchBar()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
        hideSearchBar()
    }
    
    func showSearchBar() {
        navigationItem.setRightBarButtonItem(nil, animated: true)
        UIView.animateWithDuration(0.5, animations: {
            self.navigationItem.titleView = self.searchController.searchBar }) {Void in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func hideSearchBar() {
        navigationItem.setRightBarButtonItem(hiddenAddBarButtonItem, animated: true)
        UIView.animateWithDuration(0.3, animations: { self.navigationItem.titleView = nil
            self.navigationItem.title = "Places" }) { Void in
            self.searchController.searchBar.resignFirstResponder()
        }
    }

}
