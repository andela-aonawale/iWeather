//
//  AddLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/20/15.
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
import CoreLocation
import ChameleonFramework

class AddLocationViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Variables and Outlets
    
    @IBOutlet weak var tableView: UITableView!
    private var hiddenAddBarButtonItem: UIBarButtonItem?
    private var dataModel: DataModel
    private var searchController: UISearchController!
    private let searchResultViewController: SearchResultViewController
    private var celciusButton: UIButton!
    private var fahrenheitButton: UIButton!
    
    // MARK: - UISearchBar Methods
    
    private func configureSearchController() {
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
    
    private func showSearchBar() {
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
    
    private func hideSearchBar() {
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
    
    private func listenForNewLocation() {
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        center.addObserverForName(Notification.UserCurrentLocation, object: nil, queue: queue) { [unowned self] notification in
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Button Configuration
    
    var unit: String {
        return NSUserDefaults.standardUserDefaults().stringForKey("unit")!
    }
    
    private func configureCelciusButton() {
        celciusButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        celciusButton.selected = (unit == "si")
        celciusButton.setTitle("\u{00B0}C", forState: .Normal)
        celciusButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        celciusButton.setTitleColor(navigationController?.navigationBar.tintColor, forState: .Selected)
        celciusButton.addTarget(dataModel, action: "convertUnitsToCelcius", forControlEvents: .TouchUpInside)
        celciusButton.addTarget(self, action: "changeCelciusButtonSelectedState:", forControlEvents: .TouchUpInside)
    }
    
    private func configurefahrenheitButton() {
        fahrenheitButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        fahrenheitButton.selected = (unit == "us")
        fahrenheitButton.setTitle("\u{00B0}F", forState: .Normal)
        fahrenheitButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        fahrenheitButton.setTitleColor(navigationController?.navigationBar.tintColor, forState: .Selected)
        fahrenheitButton.addTarget(dataModel, action: "convetUnitsToFarenheit", forControlEvents: .TouchUpInside)
        fahrenheitButton.addTarget(self, action: "changefahrenheitButtonSelectedState:", forControlEvents: .TouchUpInside)
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
        configureCelciusButton()
        configurefahrenheitButton()
        configureSearchController()
        listenForNewLocation()
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
        footerView.backgroundColor = FlatWhite()

        let slashLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        slashLabel.text = "/"
        slashLabel.textColor = UIColor.darkGrayColor()

        celciusButton.translatesAutoresizingMaskIntoConstraints = false
        slashLabel.translatesAutoresizingMaskIntoConstraints = false
        fahrenheitButton.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(celciusButton)
        footerView.addSubview(slashLabel)
        footerView.addSubview(fahrenheitButton)
        
        footerView.addConstraint(NSLayoutConstraint(item: celciusButton, attribute: .CenterY, relatedBy: .Equal, toItem: footerView, attribute: .CenterY, multiplier: 1, constant: 0))
        footerView.addConstraint(NSLayoutConstraint(item: celciusButton, attribute: .Trailing, relatedBy: .Equal, toItem: footerView, attribute: .Trailing, multiplier: 1, constant: -8))
        footerView.addConstraint(NSLayoutConstraint(item: slashLabel, attribute: .CenterY, relatedBy: .Equal, toItem: footerView, attribute: .CenterY, multiplier: 1, constant: 0))
        footerView.addConstraint(NSLayoutConstraint(item: slashLabel, attribute: .Trailing, relatedBy: .Equal, toItem: celciusButton, attribute: .Leading, multiplier: 1, constant: 0))
        footerView.addConstraint(NSLayoutConstraint(item: fahrenheitButton, attribute: .CenterY, relatedBy: .Equal, toItem: footerView, attribute: .CenterY, multiplier: 1, constant: 0))
        footerView.addConstraint(NSLayoutConstraint(item: fahrenheitButton, attribute: .Trailing, relatedBy: .Equal, toItem: slashLabel, attribute: .Leading, multiplier: 1, constant: 0))
        
        return footerView
    }
    
    func changeCelciusButtonSelectedState(sender: UIButton) {
        if fahrenheitButton.selected {
            fahrenheitButton.selected = false
        }
        sender.selected = true
        tableView.reloadData()
    }
    
    func changefahrenheitButtonSelectedState(sender: UIButton) {
        if celciusButton.selected {
            celciusButton.selected = false
        }
        sender.selected = true
        tableView.reloadData()
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
            CATransaction.begin()
            CATransaction.setCompletionBlock({ Void in
                tableView.reloadData()
            })
            dataModel.locations.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            CATransaction.commit()
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
