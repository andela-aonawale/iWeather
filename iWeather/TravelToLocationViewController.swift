//
//  TravelToLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/22/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import MapKit

class TravelToLocationViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var currentWeatherView: UIView!
    @IBOutlet weak var arrivalWeatherView: UIView!
    
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var currentSummary: UILabel!
    @IBOutlet weak var currentETA: UILabel!
    @IBOutlet weak var currentDistance: UILabel!
    
    @IBOutlet weak var arrivalTemperature: UILabel!
    @IBOutlet weak var arrivalTime: UILabel!
    @IBOutlet weak var arrivalWeatherImage: UIImageView!
    @IBOutlet weak var arrivalSummary: UILabel!
    @IBOutlet weak var arrivalETA: UILabel!
    @IBOutlet weak var arrivalDistance: UILabel!
    
    
    @IBAction func showArrivalWeatherView(sender: UIButton) {
        UIView.transitionFromView(currentWeatherView, toView: arrivalWeatherView, duration: 0.3, options: .TransitionFlipFromRight | .ShowHideTransitionViews | .AllowAnimatedContent, completion: nil)
    }
    
    @IBAction func showCurrentWeatherView(sender: UIButton) {
        UIView.transitionFromView(arrivalWeatherView, toView: currentWeatherView, duration: 0.3, options: .TransitionFlipFromLeft | .ShowHideTransitionViews | .AllowAnimatedContent, completion: nil)
    }
    
    func updateCurrentWeatherViewUI() {
        if let weather = travelLocation?.currentWeather {
            currentTemperature.text = weather.temperature
            currentWeatherImage.image = weather.weatherImage
            currentSummary.text = weather.summary
            currentTime.text = travelLocation?.localDateTime
        }
    }
    
    func updateArrivalWeatherViewUI(weather: HourlyWeather) {
        arrivalTemperature?.text = weather.temperature
        arrivalWeatherImage?.image = weather.weatherImage
        arrivalSummary?.text = weather.summary
        arrivalETA?.text = currentETA.text
        arrivalDistance?.text = currentDistance.text
//        arrivalTime?.text = NSDate.dateStringFromUnixTime(weather.unixTime)
    }
    
    // MARK: - Variables
    
    private var formattedAddress: String?
    private let api: APIController
    private var searchController: UISearchController!
    private let searchResultViewController: SearchResultViewController
    typealias address = (name: String, coordinate: (latitude: Double, longitude: Double))
    
    private var travelLocation: Location? {
        didSet {
            api.getWeatherData(travelLocation!.getCoordinate())
            getDirections(travelLocation!.placemark)
            addAnnotation(travelLocation!.placemark)
        }
    }
    
    // MARK: - MapView Methods
    
    private func configureMapView() {
        mapView.delegate = self
        mapView.pitchEnabled = true
        mapView.mapType = .Standard
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
        mapView.userTrackingMode = .Follow
    }
    
    private func getDirections(placemark: CLPlacemark) {
        let mapPlacemark = MKPlacemark(placemark: placemark)
        let destination = MKMapItem(placemark: mapPlacemark)
        let request = MKDirectionsRequest()
        request.setSource(MKMapItem.mapItemForCurrentLocation())
        request.setDestination(destination!)
        request.transportType = .Automobile
        
        let directions = MKDirections(request: request)
        if directions.calculating { directions.cancel() }
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            if error != nil {
                println("map error: \(error.localizedDescription)")
            } else {
                self.showRoutes(response)
            }
        }
    }
    
    private func clearRoutes() {
        if mapView?.annotations != nil { mapView.removeAnnotations(mapView.annotations as? [MKAnnotation]) }
        if mapView?.annotations != nil { mapView.removeOverlays(mapView.overlays as? [MKOverlay]) }
    }
    
    private func showRoutes(response: MKDirectionsResponse!) {
        if let route = response.routes.first as? MKRoute {
            mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            let eta = NSDate().dateByAddingTimeInterval(route.expectedTravelTime)
            let etaWeather = getWeatherOnArrival(eta)
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.currentETA.text = self.formatTimeInSec(Int(route.expectedTravelTime))
                self.currentDistance.text = String(format: "%.1f km", (route.distance / 1000) )
                if let etaWeather = self.getWeatherOnArrival(eta) {
                    self.updateArrivalWeatherViewUI(etaWeather)
                }
            }
            
        }
    }
    
    private func formatTimeInSec(totalSeconds: Int) -> String {
        let minutes = (totalSeconds / 60) % 60
        let hours = totalSeconds / 3600
        let strHours = hours > 9 ? String(hours) : String(format: "0%d", hours)
        let strMinutes = minutes > 9 ? String(minutes) : String(format: "0%d", minutes)
        if hours > 0 {
            return "\(strHours) h \(strMinutes) min"
        } else {
            return "\(strMinutes) min"
        }
    }
    
    private func getWeatherOnArrival(eta: NSDate) -> HourlyWeather? {
        if let hourlyWeather = travelLocation?.hourlyWeather {
            for weather in hourlyWeather {
                let weatherDate = NSDate(timeIntervalSince1970: NSTimeInterval(weather.unixTime))
                if eta.compare(weatherDate) == .OrderedAscending {
                    return weather
                }
            }
        }
        return nil
    }
    
    private func addAnnotation(placemark: CLPlacemark) {
        clearRoutes()
        let point = MKPointAnnotation()
        point.coordinate = placemark.location.coordinate
        point.title = placemark.name
        point.subtitle = formattedAddress
        mapView.addAnnotation(point)
        zoomOut()
        zoomIn(point.coordinate)
    }
    
    private func zoomIn(coordinate : CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        mapView.setRegion(region, animated: true)
    }
    
    private func zoomOut() {
        var region = mapView.region
        var span = mapView.region.span
        span.latitudeDelta *= 15
        span.longitudeDelta *= 15
        region.span = span
        mapView.setRegion(region, animated: true)
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
    
    required init(coder aDecoder: NSCoder) {
        api = APIController()
        searchResultViewController = SearchResultViewController()
        searchController = UISearchController(searchResultsController: searchResultViewController)
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        searchController.searchBar.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        api.delegate = self
        configureMapView()
        configureSearchController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension TravelToLocationViewController: SearchResultViewControllerDelegate, APIControllerDelegate {
    
    // MARK: - API Controller & Search ResultView Controller Delegate Methods
    
    func didReceiveWeatherResult(weatherObject: NSDictionary) {
        travelLocation?.weatherObject = weatherObject
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.updateCurrentWeatherViewUI()
        }
    }
    
    func didSelectLocationFromSearchResult(placemark: CLPlacemark, selectedAddress: String) {
        self.formattedAddress = selectedAddress
        self.travelLocation = Location(placemark: placemark)
    }
    
}

extension TravelToLocationViewController: UISearchControllerDelegate {
    
    // MARK: - UISearch Controller Delegate Methods
    
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
    
}

extension TravelToLocationViewController: MKMapViewDelegate {
    
    // MARK: - MKMapView Delegate Methods
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        if annotation.isKindOfClass(MKPointAnnotation) {
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
                pinView.canShowCallout = true
            } else {
                pinView.annotation = annotation
                
            }
            pinView.leftCalloutAccessoryView = UIImageView(frame: Constants.LeftCalloutFrame)
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let weatherIcon = view.leftCalloutAccessoryView as? UIImageView {
            weatherIcon.image = travelLocation?.currentWeather.weatherImage
        }
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 2000, 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        
    }
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "CustomPinAnnotationView"
    }
    
}
