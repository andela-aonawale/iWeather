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
    
    // MARK: - Variables and Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
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
    }
    
    private func getDirections(placemark: CLPlacemark) {
        let mapPlacemark = MKPlacemark(placemark: placemark)
        let destination = MKMapItem(placemark: mapPlacemark)
        let request = MKDirectionsRequest()
        request.setSource(MKMapItem.mapItemForCurrentLocation())
        request.setDestination(destination!)
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        if directions.calculating { directions.cancel() }
        directions.calculateDirectionsWithCompletionHandler { (response, error) in
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
            println("route name: \(route.name)")
            println("distance: \(route.distance)")
            println("eta: \(route.expectedTravelTime/60)")
            println("transport type: \(route.transportType.rawValue)")
            var eta = NSDate().dateByAddingTimeInterval(route.expectedTravelTime)
            
            var etaWeather = getWeatherOnArrival(eta)
            println(etaWeather?.summary)
            println(etaWeather?.unixTime)
            
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
        UIView.animateWithDuration(0.5, animations: {
            self.navigationItem.titleView = self.searchController.searchBar }) {finished in
                self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    func hideSearchBar() {
        searchController.searchBar.resignFirstResponder()
        UIView.animateWithDuration(0.3, animations: { self.navigationItem.titleView = nil }) { finished in
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
