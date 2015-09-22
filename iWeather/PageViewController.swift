//
//  PageContentViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/26/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var dataModel = DataModel.sharedInstance
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! LocationViewController).index
        index++
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! LocationViewController).index
        index--
        return self.viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> LocationViewController? {
        if index == NSNotFound || index < 0 || (index >= dataModel.locations.count && index != 0) {
            return nil
        }
        if let locationViewController = storyboard?.instantiateViewControllerWithIdentifier(View.LocationViewController) as? LocationViewController {
            if let location = dataModel.locations[safe: index] {
                locationViewController.location = location
            }
            locationViewController.index = index
            return locationViewController
        }
        return nil
    }
    
    func moveToPage(index: Int) {
        if let nextViewController = viewControllerAtIndex(index) {
            setViewControllers([nextViewController], direction: .Forward, animated: false, completion: nil)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        if let currentLocationViewController = viewControllerAtIndex(0) {
            setViewControllers([currentLocationViewController], direction: .Forward, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        dataSource = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
