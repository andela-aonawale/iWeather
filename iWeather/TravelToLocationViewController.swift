//
//  TravelToLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/22/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import GoogleMaps

class TravelToLocationViewController: UIViewController, UISearchBarDelegate, GMSMapViewDelegate {
    
    let mapTask = MapTask()

    private var travelLocation: Location! {
        didSet {
            activityIndicator.startAnimating()
            getCurrentTravelLocationWeather()
            addLocationMarker(travelLocation.formattedAdrress!, coordinate: travelLocation.coordinate!)
            let origin = "\(mapView.myLocation.coordinate.latitude),\(mapView.myLocation.coordinate.longitude)"
            getDirections(origin)
        }
    }
    
    private func getDirections(origin: String) {
        mapTask.getDirections(origin, destination: travelLocation.getCoordinate(), waypoints: nil, travelMode: nil) { status, success in
            switch status {
                case .OK:
                    self.getTravelLocationWeatherOnArrival()
                    self.drawRoute()
                    self.setDistanceAndETALabel()
                default:
                    break
            }
        }
    }
    
    private func setDistanceAndETALabel() {
        distance.text = String(format: "%.1f km", mapTask.distance )
        espectedTimeTravel.text = formatTimeFromSeconds(mapTask.expectedTravelTime)
    }
    
    private func getTravelLocationWeatherOnArrival() {
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(mapTask.expectedTravelTime))
        api.getWeatherForDate(date, coordinate: travelLocation.getCoordinate()) { weatherObject in
            self.activityIndicator.stopAnimating()
            if let currently = weatherObject.valueForKey("currently") as? NSDictionary {
                let currentWeather = CurrentWeather(weatherDictionary: currently)
                self.updateArrivalWeatherViewUI(currentWeather)
            }
        }
    }
    
    func updateArrivalWeatherViewUI(currentWeather: CurrentWeather) {
        if let weather = currentWeather as CurrentWeather? {
            arrivalTemperature.text = weather.temperature
            arrivalWeatherImage.image = weather.weatherImage
            arrivalSummary.text = weather.summary
            arrivalTime.text = weather.date
        }
    }
    
    private func drawRoute() {
        mapTask.createRoute().map = mapView
    }
    
    private func addLocationMarker(name: String, coordinate: CLLocationCoordinate2D) {
        mapTask.createMarker(name, coordinate: coordinate).map = mapView
    }
    
    private func configureMapView() {
        mapView.delegate = self
        mapView.myLocationEnabled = true
        mapView.addObserver(self, forKeyPath: "myLocation", options: .New, context: nil)
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
    
    // MARK: - IB Outlets
    
//    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var espectedTimeTravel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var currentWeatherView: UIView!
    @IBOutlet weak var arrivalWeatherView: UIView!
    
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var currentSummary: UILabel!
    
    @IBOutlet weak var arrivalTemperature: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var arrivalWeatherImage: UIImageView!
    @IBOutlet weak var arrivalSummary: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBAction func showArrivalWeatherView(sender: UIButton) {
        UIView.transitionFromView(currentWeatherView, toView: arrivalWeatherView, duration: 0.3, options: [.TransitionFlipFromRight, .ShowHideTransitionViews, .AllowAnimatedContent], completion: nil)
    }
    
    @IBAction func showCurrentWeatherView(sender: UIButton) {
        UIView.transitionFromView(arrivalWeatherView, toView: currentWeatherView, duration: 0.3, options: [.TransitionFlipFromLeft, .ShowHideTransitionViews, .AllowAnimatedContent], completion: nil)
    }
    
    func updateCurrentWeatherViewUI() {
        if let weather = travelLocation?.currentWeather {
            currentTemperature.text = weather.temperature
            currentWeatherImage.image = weather.weatherImage
            currentSummary.text = weather.summary
            currentTime.text = weather.date
        }
    }
    
    // MARK: - Variables
    
    private var formattedAddress: String?
    private let api: APIController
    private var searchController: UISearchController!
    private let searchResultViewController: SearchResultViewController
    typealias address = (name: String, coordinate: (latitude: Double, longitude: Double))
    
    private func getCurrentTravelLocationWeather() {
        api.getWeatherData(travelLocation!.getCoordinate()) { [unowned self] weatherObject in
            self.travelLocation?.weatherObject = weatherObject
            self.updateCurrentWeatherViewUI()
        }
    }
    
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
    
    @IBOutlet weak var searchButton: UIBarButtonItem!

    var hiddenSearchBarButtonItem: UIBarButtonItem?

    @IBAction func searchBarButtonPressed(sender: UIBarButtonItem) {
        showSearchBar()
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
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        api = APIController.sharedInstance
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
