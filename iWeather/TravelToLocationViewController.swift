//
//  TravelToLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/22/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import GoogleMaps

class TravelToLocationViewController: UIViewController {
    
    let mapTask = MapTask()
    var currentlyTappedMarker: GMSMarker!
    var displayedInfoWindow: MarkerInfoView!
    
    private var travelLocation: Location! {
        didSet {
            addLocationMarker(atCoordinate: travelLocation.coordinate!)
            let origin = "\(mapView.myLocation.coordinate.latitude),\(mapView.myLocation.coordinate.longitude)"
            getDirections(origin, destination: travelLocation.getCoordinate())
        }
    }
    
    private func setDistanceAndETALabel() {
        //        distance.text = String(format: "%.1f km", mapTask.distance )
        //        espectedTimeTravel.text = formatTimeFromSeconds(mapTask.expectedTravelTime)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureSearchController()
    }
    
    var onceToken : dispatch_once_t = 0
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        dispatch_once(&onceToken) {
            if keyPath == "myLocation" {
                if let coordinate = object?.myLocation?.coordinate {
                    self.mapView.camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 15, bearing: 30, viewingAngle: 40)
                    self.mapView.settings.myLocationButton = true
                }
            }
        }
    }
    
    private func formatTimeFromSeconds(seconds: Int) -> String {
        let minutes = (seconds / 60) % 60
        let hours = seconds / 3600
        let days = hours / 24
        if days > 0 {
            return "\(days) d \(hours) h \(minutes) min"
        } else if hours > 0 {
            return "\(hours) h \(minutes) min"
        } else {
            return "\(minutes) min"
        }
    }

//    @IBOutlet weak var distance: UILabel!
//    @IBOutlet weak var espectedTimeTravel: UILabel!
    
    @IBOutlet weak var mapView: GMSMapView!
    private var searchController: UISearchController!
    private let searchResultViewController: SearchResultViewController
    typealias address = (name: String, coordinate: (latitude: Double, longitude: Double))
    @IBOutlet weak var searchButton: UIBarButtonItem!
    var hiddenSearchBarButtonItem: UIBarButtonItem?

    @IBAction func searchBarButtonPressed(sender: UIBarButtonItem) {
        showSearchBar()
    }

    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        searchResultViewController = SearchResultViewController()
        searchController = UISearchController(searchResultsController: searchResultViewController)
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        searchController.searchBar.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        mapView.removeObserver(self, forKeyPath: "myLocation", context: nil)
    }
    
}

extension TravelToLocationViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBar Methods
    
    private func configureSearchController() {
        searchController.delegate = self
        definesPresentationContext = true
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = searchResultViewController
        hiddenSearchBarButtonItem = navigationItem.rightBarButtonItem
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
        hideSearchBar()
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
                self.navigationItem.setRightBarButtonItem(self.hiddenSearchBarButtonItem, animated: true)
        }
    }
    
}

extension TravelToLocationViewController: GMSMapViewDelegate {
    
    private func getDirections(origin: String, destination: String) {
        mapTask.getDirections(origin, destination: destination, waypoints: nil, travelMode: nil) { status, success in
            switch status {
            case .OK:
                let date = NSDate(timeIntervalSinceNow: NSTimeInterval(self.mapTask.expectedTravelTime))
                self.displayedInfoWindow.arrivalDate = date
                self.drawRoute()
            default:
                break
            }
        }
    }
    
    private func configureMapView() {
        mapView.delegate = self
        mapView.myLocationEnabled = true
        mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        currentlyTappedMarker = marker
        resetDisplayInfoWindow()
        showMarkerInfoView(marker)
        let origin = "\(mapView.myLocation.coordinate.latitude),\(mapView.myLocation.coordinate.longitude)"
        let destination = "\(marker.position.latitude),\(marker.position.longitude)"
        displayedInfoWindow.locationCoordinate = destination
        getDirections(origin, destination: destination)
        return true
    }
    
    private func showMarkerInfoView(marker: GMSMarker) {
        displayedInfoWindow = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView
        let markerPoint = mapView.projection.pointForCoordinate(marker.position)
        displayedInfoWindow.frame.origin.x = markerPoint.x - 80
        displayedInfoWindow.frame.origin.y = markerPoint.y - 130
        self.view.addSubview(displayedInfoWindow)
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if currentlyTappedMarker != nil && displayedInfoWindow != nil {
            let markerPoint = mapView.projection.pointForCoordinate(currentlyTappedMarker.position)
            displayedInfoWindow.frame.origin.x = markerPoint.x - 80
            displayedInfoWindow.frame.origin.y = markerPoint.y - 130
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapTask.removePolyline()
        resetDisplayInfoWindow()
        mapTask.createMarker(atCoordinate: coordinate).map = mapView
    }
    
    private func drawRoute() {
        mapTask.createRoute().map = mapView
    }
    
    private func addLocationMarker(atCoordinate coordinate: CLLocationCoordinate2D) {
        let marker = mapTask.createMarker(atCoordinate: coordinate)
        marker.map = mapView
        currentlyTappedMarker = marker
        resetDisplayInfoWindow()
        showMarkerInfoView(marker)
        displayedInfoWindow.locationCoordinate = travelLocation.getCoordinate()
    }
    
    private func resetDisplayInfoWindow() {
        if displayedInfoWindow != nil {
            if displayedInfoWindow.isDescendantOfView(self.view) {
                displayedInfoWindow.removeFromSuperview()
                displayedInfoWindow = nil
            }
        }
    }
    
}

extension TravelToLocationViewController: SearchResultViewControllerDelegate {
    
    // MARK: - Search ResultView Controller Delegate Methods
    
    func didSelectPlace(place: String, formattedAddress: String, coordinate: CLLocationCoordinate2D) {
        hideSearchBar()
        travelLocation = Location(name: place, formattedAdrress: formattedAddress, coordinate: coordinate)
    }
    
}

extension TravelToLocationViewController: UISearchControllerDelegate {
    
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
