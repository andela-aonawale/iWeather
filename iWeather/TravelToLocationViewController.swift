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

    @IBOutlet weak var mapView: MKMapView!
    
    func configureMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    func getDirections() {
        let mapPlacemark = MKPlacemark(placemark: travelLocation?.placemark)
        let destination = MKMapItem(placemark: mapPlacemark)
        let request = MKDirectionsRequest()
        request.setSource(MKMapItem.mapItemForCurrentLocation())
        request.setDestination(destination!)
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        directions.calculateDirectionsWithCompletionHandler { (response, error) in
            if error != nil {
                println("map error: \(error.localizedDescription)")
            } else {
                self.showRoutes(response)
            }
        }
    }
    
    func showRoutes(response: MKDirectionsResponse!) {
        for route in (response.routes as! [MKRoute]) {
            mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            println("route name: \(route.name)")
            println("distance: \(route.distance)")
            println("eta: \(route.expectedTravelTime/60)")
            println("weather now: \(travelLocation?.currentWeather.summary)")
            println("weather for next 24 hours: \(travelLocation?.dayWeatherSummary)")
            for step in route.steps {
                println(step.instructions)
            }
        }
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.location.coordinate, 2000, 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        return renderer
    }
    
    private let api: APIController
    private var travelLocation: Location? {
        didSet {
            api.getWeatherData(travelLocation!.getCoordinate())
            getDirections()
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
    
    func didSelectLocation(placemark: CLPlacemark) {
        let coordinate = (latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
        travelLocation = Location(placemark: placemark)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getDistanceBetweenLocations(currentlocation: CLLocation, destination: CLLocation) -> Double{
        return currentlocation.distanceFromLocation(destination)
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
    
    override func viewWillAppear(animated: Bool) {
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
        configureMapView()
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
