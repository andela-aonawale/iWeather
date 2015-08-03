//
//  CalendarEventsViewController.swift
//  iWeather
//
//  Created by Ahmed Onawale on 7/31/15.
//  Copyright (c) 2015 Ahmed Onawale. All rights reserved.
//

import UIKit
import EventKit

class CalendarEventsViewController: UIViewController {
    
    private let eventStore = EKEventStore()
    private var calendars: [EKCalendar]?
    @IBOutlet weak var tableView: UITableView!
    
    private func requestAccessToCalendar() {
        eventStore.requestAccessToEntityType(EKEntityTypeEvent) { (accessGranted, error) in
            if accessGranted {
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadCalendars()
                    self.refreshTableView()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    //needPermissionView.fadeIn()
                }
            }
        }
    }
    
    private func refreshTableView() {
        tableView.reloadData()
    }
    
    private func loadCalendars() {
        calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent) as? [EKCalendar]
    }
    
    private func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent)
        
        switch status {
            case .NotDetermined:
                requestAccessToCalendar()
            case .Authorized:
                loadCalendars()
                refreshTableView()
            case .Restricted, .Denied:
                println("")
                //needPermissionView.fadeIn()
            default:
                let alert = UIAlertController(title: "Privacy Warning",
                    message: "You have not granted permission for this app to access your Calendar", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        checkCalendarAuthorizationStatus()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func goToSettingsButtonTapped(sender: UIButton) {
        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(openSettingsUrl!)
    }

}


extension CalendarEventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let calendars = self.calendars {
            return calendars.count
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! UITableViewCell
        
        if let calendars = self.calendars {
            let calendarName = calendars[indexPath.row].title
            println(calendarName)
            cell.textLabel?.text = calendarName
        } else {
            cell.textLabel?.text = "Unknown Calendar Name"
        }
        
        return cell
    }
    
}
