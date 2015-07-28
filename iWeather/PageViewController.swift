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
        if index == NSNotFound || index < 0 || index > dataModel.locations.count {
            return nil
        }
        if let locationViewController = storyboard?.instantiateViewControllerWithIdentifier("LocationViewController") as? LocationViewController {
            if index != 0 {
                locationViewController.location = dataModel.locations[index-1]
            } else {
                locationViewController.location = dataModel.currentLocation
            }
            
            locationViewController.index = index
            return locationViewController
        }
        return nil
    }
    
    func moveToPage(index: Int) {
        if let nextViewController = self.viewControllerAtIndex(index + 1) {
            setViewControllers([nextViewController], direction: .Forward, animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        dataSource = self
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(true)
        dataSource = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        if let currentLocationViewController = self.viewControllerAtIndex(0) {
            setViewControllers([currentLocationViewController], direction: .Forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
