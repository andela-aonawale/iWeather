//
//  TabBarController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 9/1/15.
//  Copyright © 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

func noInternetNetworkAlert() -> UIAlertController {
    let title = "Cellular Data is Turned Off"
    let message = "Turn on cellular data or use Wi-Fi to access data."
    let alert = UIAlertController(title: title, message: message , preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default) { action in
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

class TabBarController: UITabBarController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !Reachability.reachabilityForInternetConnection().isReachable() {
            presentViewController(noInternetNetworkAlert(), animated: false, completion: nil)
        }
    }
    
}