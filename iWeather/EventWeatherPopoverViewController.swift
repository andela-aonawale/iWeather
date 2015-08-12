//
//  EventWeatherPopoverViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 8/12/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit

class EventWeatherPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if let superView = view.superview {
            superView.layer.cornerRadius = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredContentSize: CGSize {
        get {
            if presentingViewController != nil {
                var width: CGFloat {
                    let pvcWidth = presentingViewController!.view.bounds.width
                    return (pvcWidth - pvcWidth/10)
                }
                var height: CGFloat {
                    return presentingViewController!.view.bounds.height / 2
                }
                return CGSizeMake(width, height)
            } else {
                return super.preferredContentSize
            }
        }
        set { super.preferredContentSize = newValue }
    }

}
