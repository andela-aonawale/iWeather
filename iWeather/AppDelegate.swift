//
//  AppDelegate.swift
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
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataModel = DataModel.sharedInstance
    let locationManager = LocationManager.sharedInstance
    var reachability: Reachability! = Reachability.reachabilityForInternetConnection()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyC4sIc6LDwrS1atwdN2FV98lDQbG32HMWo")
        if (launchOptions?[UIApplicationLaunchOptionsLocationKey] != nil) && reachability.isReachable() {
            locationManager.startMonitoringSignificantLocationChanges()
        } else if reachability.isReachable() {
            locationManager.startUpdatingLocation()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        reachability.startNotifier()
        application.setMinimumBackgroundFetchInterval(NSTimeInterval(3600 * 6))
        return true
    }
    
    func reachabilityChanged(notification: NSNotification) {
        if reachability.isReachable() {
            fetchForLocationsWithoutWeatherData()
        } else {
            if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
                let title = "Cellular Data is Turned Off"
                let message = "Turn on cellular data or use Wi-Fi to access data."
                let alert = Alert.createWithSettinsURL(title, message: message)
                window?.rootViewController?.presentViewController(alert, animated: false, completion: nil)
            }
        }
    }
    
    func fetchForLocationsWithoutWeatherData() {
        for location in dataModel.locations where !location.hasWeatherData {
            location.updateWeatherData() { success in
                if success && UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
                    location.postWeatherUpdateNotification()
                }
            }
        }
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let group = dispatch_group_create()
        var updated = false
        for location in dataModel.locations {
            if reachability.isReachable() {
                dispatch_group_enter(group)
                location.updateWeatherData() { success in
                    updated = success
                    dispatch_group_leave(group)
                }
            }
        }
        dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            updated ? completionHandler(.NewData) : completionHandler(.Failed)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        for location in dataModel.locations {
            location.invalidateTimers()
        }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        dataModel.saveLocations()
        locationManager.stopUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        fetchForLocationsWithoutWeatherData()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        for location in dataModel.locations {
            location.restartTimers()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        dataModel.saveLocations()
    }
    
}

