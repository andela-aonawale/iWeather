//
//  TravelToLocationViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/22/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import MapKit

class TravelToLocationViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate, MKMapViewDelegate, SearchResultViewControllerDelegate, APIControllerDelegate {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            configureMapView()
        }
    }
    
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
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3.0
        return renderer
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
    
    private var formattedAddress: String?
    private let api: APIController
    private var travelLocation: Location? {
        didSet {
            api.getWeatherData(travelLocation!.getCoordinate())
            getDirections(travelLocation!.placemark)
            addAnnotation(travelLocation!.placemark)
        }
    }
    private var searchController: UISearchController!
    private let searchResultViewController: SearchResultViewController
    typealias address = (name: String, coordinate: (latitude: Double, longitude: Double))
    
    required init(coder aDecoder: NSCoder) {
        api = APIController()
        searchResultViewController = SearchResultViewController()
        searchController = UISearchController(searchResultsController: searchResultViewController)
        super.init(coder: aDecoder)
    }
    
    private func configureSearchController() {
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
        travelLocation?.weatherObject = weatherObject
    }
    
    func didSelectLocationFromSearchResult(placemark: CLPlacemark, selectedAddress: String) {
        self.formattedAddress = selectedAddress
        self.travelLocation = Location(placemark: placemark)
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
    
    override func viewDidAppear(animated: Bool) {
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
    
    private func openLocationSettings(alert: UIAlertAction!) {
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func enableLocationAccess() {
        let alertController = UIAlertController(
            title: "Location Access Disabled",
            message: "In order get your location, please open this app's settings and enable location access.",
            preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let openAction = UIAlertAction(title: "Open Settings", style: .Default, handler: openLocationSettings)
        alertController.addAction(cancelAction)
        alertController.addAction(openAction)
        presentViewController(alertController, animated: true, completion: nil)
    }

}
