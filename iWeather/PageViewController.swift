//
//  PageContentViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/26/15.
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
import ChameleonFramework

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var dataModel = DataModel.sharedInstance
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as! LocationViewController)
        view.backgroundColor = vc.view.backgroundColor
        var index = vc.index
        index++
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = (viewController as! LocationViewController)
        view.backgroundColor = vc.view.backgroundColor
        var index = vc.index
        index--
        return viewControllerAtIndex(index)
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
        view.backgroundColor = FlatSkyBlue()
        dataSource = self
        if let currentLocationViewController = viewControllerAtIndex(0) {
            setViewControllers([currentLocationViewController], direction: .Forward, animated: false, completion: nil)
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
