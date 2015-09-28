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
    private var dataModel: DataModel
    private var searchController: UISearchController!
    private let searchResultViewController: SearchResultViewController
    
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
        UIView.animateWithDuration(0.5,
            animations: { [unowned self] in
                self.navigationItem.titleView = self.searchController.searchBar
            },
            completion: {[unowned self] finished in
                self.searchController.searchBar.becomeFirstResponder()
            }
        )
    }
    
    func hideSearchBar() {
        searchController.searchBar.resignFirstResponder()
        UIView.animateWithDuration(0.3,
            animations: { [unowned self] in
                self.navigationItem.titleView = nil
            },
            completion: { [unowned self] finished in
                self.navigationItem.setRightBarButtonItem(self.hiddenAddBarButtonItem, animated: true)
            }
        )
    }
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
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
    
    func didSelectPlace(place: String, coordinate: CLLocationCoordinate2D) {
        hideSearchBar()
        let coordinate = (latitude: coordinate.latitude, longitude: coordinate.longitude)
        let location = Location(name: place, coordinate: coordinate)
        dataModel.locations.append(location)
        tableView.reloadData()
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
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
        footerView.backgroundColor = UIColor.blueColor()
        
        let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        let celciusButton = UIButton(frame: frame)
        celciusButton.setTitle("\u{00B0}C", forState: .Normal)
        celciusButton.addTarget(dataModel, action: "convertUnitsToCelcius", forControlEvents: .TouchUpInside)
        
        let slashLabel = UILabel(frame: frame)
        slashLabel.text = "/"
        slashLabel.textColor = UIColor.whiteColor()
        
        let farenheitButton = UIButton(frame: frame)
        farenheitButton.setTitle("\u{00B0}F", forState: .Normal)
        farenheitButton.addTarget(dataModel, action: "convetUnitsToFarenheit", forControlEvents: .TouchUpInside)
        
        celciusButton.translatesAutoresizingMaskIntoConstraints = false
        slashLabel.translatesAutoresizingMaskIntoConstraints = false
        farenheitButton.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(celciusButton)
        footerView.addSubview(slashLabel)
        footerView.addSubview(farenheitButton)
        
        footerView.addConstraint(NSLayoutConstraint(item: celciusButton, attribute: .CenterY, relatedBy: .Equal, toItem: footerView, attribute: .CenterY, multiplier: 1, constant: 0))
        footerView.addConstraint(NSLayoutConstraint(item: celciusButton, attribute: .Trailing, relatedBy: .Equal, toItem: footerView, attribute: .Trailing, multiplier: 1, constant: -8))
        
        footerView.addConstraint(NSLayoutConstraint(item: slashLabel, attribute: .CenterY, relatedBy: .Equal, toItem: footerView, attribute: .CenterY, multiplier: 1, constant: 0))
        footerView.addConstraint(NSLayoutConstraint(item: slashLabel, attribute: .Trailing, relatedBy: .Equal, toItem: celciusButton, attribute: .Leading, multiplier: 1, constant: 0))
        
        footerView.addConstraint(NSLayoutConstraint(item: farenheitButton, attribute: .CenterY, relatedBy: .Equal, toItem: footerView, attribute: .CenterY, multiplier: 1, constant: 0))
        footerView.addConstraint(NSLayoutConstraint(item: farenheitButton, attribute: .Trailing, relatedBy: .Equal, toItem: slashLabel, attribute: .Leading, multiplier: 1, constant: 0))
        
        return footerView
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.locations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.LocationCell, forIndexPath: indexPath) as! LocationTableViewCell
        if let location: Location? = dataModel.locations[indexPath.row] as Location? {
            cell.location = location
        }
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (indexPath.row != 0)
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
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if searchController.searchBar.isFirstResponder() {
            hideSearchBar()
        }
        tabBarController?.selectedIndex = 0
        if let pageViewController = tabBarController?.selectedViewController as? PageViewController {
            pageViewController.moveToPage(indexPath.row)
        }
    }
    
}
