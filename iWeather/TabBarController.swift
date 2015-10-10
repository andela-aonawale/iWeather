//
//  TabBarController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 9/1/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class Alert {
    
    class func createWithSettinsURL(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Cancel", style: .Default) { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .Default) { action in
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alert.addAction(settingsAction)
        alert.addAction(okAction)
        return alert
    }
    
    class func createWithCancelAction(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        return alert
    }
    
}

class TabBarController: UITabBarController, LocationManagerDelegate {
    
    func locationAccessDenied() {
        let title = "Background Location Access Disabled"
        let message = "In order to be able to automatically update your location, please press settings and set location access to 'Always'."
        let alert = Alert.createWithSettinsURL(title, message: message)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func networkUnavailable() {
        let title = "Network Unavailable"
        let message = "Cannot retrieve your location right now. The network was unavailable or a network error occurred, please check your internet connection."
        let alert = Alert.createWithCancelAction(title, message: message)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func locationAccessRestricted() {
        let title = "Location Services Resticted"
        let message = "Your device's location services have been restricted."
        let alert = Alert.createWithCancelAction(title, message: message)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    func locationUnknown() {
        let title = "Location Unknown"
        let message = "The location manager was unable to obtain a location value right now."
        let alert = Alert.createWithCancelAction(title, message: message)
        presentViewController(alert, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        LocationManager.sharedInstance.delegate = self
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationBackgroundRefreshStatusDidChangeNotification, object: UIApplication.sharedApplication(), queue: NSOperationQueue.mainQueue()) { notification in
            if UIApplication.sharedApplication().backgroundRefreshStatus == .Available {
                LocationManager.sharedInstance.startMonitoringSignificantLocationChanges()
            } else if UIApplication.sharedApplication().backgroundRefreshStatus == .Denied {
                let title = "Background App Refresh Disabled"
                let message = "In order to be able to update weather data in the background and automatically update your location, please press settings and enable 'Background App Refresh'."
                let alert = Alert.createWithSettinsURL(title, message: message)
                self.presentViewController(alert, animated: false, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !Reachability.reachabilityForInternetConnection().isReachable() {
            let title = "Cellular Data is Turned Off"
            let message = "Turn on cellular data or use Wi-Fi to access data."
            let alert = Alert.createWithCancelAction(title, message: message)
            presentViewController(alert, animated: false, completion: nil)
        }
    }
    
}