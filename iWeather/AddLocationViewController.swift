//
//  AddLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Variables and Outlets
    
    @IBOutlet weak var tableView: UITableView!
    private var hiddenAddBarButtonItem: UIBarButtonItem?
    
    private let api: APIController
    private var dataModel: DataModel
    private var searchController: UISearchController!
    private let searchResultViewController: SearchResultViewController
    typealias address = (name: String, coordinate: (latitude: Double, longitude: Double))
    
    private var newLocation: Location? {
        didSet {
            getLocationWeather()
        }
    }
    
    private func getLocationWeather() {
        api.getWeatherData(newLocation!.getCoordinate()) { [unowned self] weatherObject in
            self.newLocation?.weatherObject = weatherObject
            self.dataModel.locations.append(self.newLocation!)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - UISearchBar Methods
    
    func configureSearchController() {
        searchController.delegate = self
        definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = searchResultViewController
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        hiddenAddBarButtonItem = navigationItem.rightBarButtonItem
    }
    
    @IBAction func addLocationBarButtonPressed(sender: AnyObject) {
        showSearchBar()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true) { [unowned self] in
            self.hideSearchBar()
        }
    }
    
    func showSearchBar() {
        navigationItem.setRightBarButtonItem(nil, animated: true)
        UIView.animateWithDuration(0.5, animations: { [unowned self] in
            self.navigationItem.titleView = self.searchController.searchBar }) {[unowned self] finished in
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func hideSearchBar() {
        searchController.searchBar.resignFirstResponder()
        UIView.animateWithDuration(0.3, animations: { [unowned self] in
            self.navigationItem.titleView = nil }) { [unowned self] finished in
            self.navigationItem.setRightBarButtonItem(self.hiddenAddBarButtonItem, animated: true)
        }
    }
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        api = APIController.sharedInstance
        dataModel = DataModel.sharedInstance
        searchResultViewController = SearchResultViewController()
        searchController = UISearchController(searchResultsController: searchResultViewController)
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


extension AddLocationViewController: SearchResultViewControllerDelegate {
    
    // MARK: - Search ResultView Controller Delegate Methods
    
    func didSelectPlace(place: String, formattedAddress: String, coordinate: CLLocationCoordinate2D) {
        hideSearchBar()
        newLocation = Location(name: place, formattedAdrress: formattedAddress, coordinate: coordinate)
    }
    
}


extension AddLocationViewController: UISearchControllerDelegate {
    
    // MARK: - UISearch Controller Delegate Methods
    
    func willPresentSearchController(searchController: UISearchController) {
        let controller = searchController.searchResultsController as! SearchResultViewController
        controller.delegate = self
        dispatch_async(dispatch_get_main_queue()) {
            searchController.searchResultsController!.view.hidden = false
        }
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        searchController.searchResultsController!.view.hidden = false
    }
    
}


extension AddLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UITableView Delegate & UITableView DataSource Methods
    
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
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            dataModel.locations.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            if let pageViewController = tabBarController?.viewControllers?.first as? PageViewController {
                pageViewController.moveToPage(indexPath.row - 1)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchController.searchBar.isFirstResponder() {
            hideSearchBar()
        }
        tabBarController?.selectedIndex = 0
        if let pageViewController = tabBarController?.selectedViewController as? PageViewController {
            pageViewController.moveToPage(indexPath.row)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
}
