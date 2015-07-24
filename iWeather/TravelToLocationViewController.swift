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
    
    func configureMapView() {
        mapView.delegate = self
        mapView.pitchEnabled = true
        mapView.mapType = .Standard
        mapView.showsUserLocation = true
        mapView.showsBuildings = true
    }
    
    func getDirections(placemark: CLPlacemark) {
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
    
    func showRoutes(response: MKDirectionsResponse!) {
        for route in (response.routes as! [MKRoute]) {
            mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            println("route name: \(route.name)")
            println("distance: \(route.distance)")
            println("eta: \(route.expectedTravelTime)")
            println("transport type: \(route.transportType.rawValue)")
        }
        
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3.0
        return renderer
    }
    
    func addAnnotation(placemark: CLPlacemark) {
        clearRoutes()
        let point = MKPointAnnotation()
        point.coordinate = placemark.location.coordinate
        point.title = placemark.name
        point.subtitle = formattedAddress
        mapView.addAnnotation(point)
        zoomOut()
    }
    
    func zoomOut() {
        var region = mapView.region
        var span = mapView.region.span
        span.latitudeDelta *= 10
        span.longitudeDelta *= 10
        region.span = span
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 2000, 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        if let point = mapView.annotations.first as? MKAnnotation {
            let region = MKCoordinateRegionMakeWithDistance(point.coordinate, 2000, 2000)
            if (mapView.region.center.latitude != region.center.latitude) && (mapView.region.center.longitude != region.center.longitude) {
                mapView.setRegion(region, animated: true)
            } else {
                mapView.setRegion(mapView.region, animated: true)
            }
            
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        if annotation.isKindOfClass(MKPointAnnotation) {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("CustomPinAnnotationView")
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "CustomPinAnnotationView")
                pinView.canShowCallout = true
            } else {
                pinView.annotation = annotation
                return pinView
            }
        }
        return nil
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
        travelLocation?.weatherObject = weatherObject
    }
    
    func didSelectLocationFromSearchResult(placemark: CLPlacemark, selectedAddress: String) {
        formattedAddress = selectedAddress
        travelLocation = Location(placemark: placemark)
        println(selectedAddress)
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
    
    func openLocationSettings(alert: UIAlertAction!) {
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
