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
    
    @IBOutlet weak var tableView: UITableView!

    private let eventStore: EKEventStore
    private var dataModel = DataModel.sharedInstance
    
    private func requestAccessToCalendar() {
        eventStore.requestAccessToEntityType(EKEntityTypeEvent) { [unowned self] in
            ($0 == true && $1 == nil) ? self.fetchCalendars() : self.showNeedPermissionView()
        }
    }
    
    private func showNeedPermissionView() {
        
    }
    
    private func showRestrictedView() {
        
    }
    
    private func fetchCalendars() {
        if let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent) as? [EKCalendar] {
            fetchEventsFromCalendars(calendars) { [unowned self] Events in
                for event in Events {
                    self.createEvent(event)
                }
            }
        }
    }
    
    private func fetchEventsFromCalendars(calendars: [EKCalendar], completed: ([EKEvent]) -> Void) {
        let startDate = NSDate()
        let endDate = NSDate(timeIntervalSinceNow: 604800*10)
        let predicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: calendars)
        if let eventsArray = eventStore.eventsMatchingPredicate(predicate) as? [EKEvent] {
            completed(eventsArray)
        }
    }
    
    private func createEvent(event: EKEvent) {
        if let location = event.valueForKey("structuredLocation") as? EKStructuredLocation {
            if let coordinate = location.geoLocation?.coordinate {
                createEvent(event, withCoordinate: coordinate)
            } else {
                createEvent(event: event)
            }
        }
    }
    
    private func createEvent(event: EKEvent, withCoordinate: CLLocationCoordinate2D) {
        let event = Event(title: event.title, startDate: event.startDate, endDate: event.endDate, location: event.location, coordinate: withCoordinate)
        dataModel.events.append(event)
    }
    
    private func createEvent(#event: EKEvent) {
        let event = Event(title: event.title, startDate: event.startDate, endDate: event.endDate, location: event.location)
        dataModel.events.append(event)
    }
    
    private func enableCalendarAccess() {
        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(openSettingsUrl!)
    }
    
    private func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent)
        switch status {
            case .NotDetermined:
                requestAccessToCalendar()
            case .Authorized:
                fetchCalendars()
            case .Denied:
                showNeedPermissionView()
            case .Restricted:
                showRestrictedView()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        checkCalendarAuthorizationStatus()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.contentInset = UIEdgeInsets(top: -65, left: 0, bottom: 0, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    required init(coder aDecoder: NSCoder) {
        eventStore = EKEventStore()
        super.init(coder: aDecoder)
    }

    var selectedCell: EventTableViewCell?

}

extension CalendarEventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
        cell.delegate = self
        if let event = dataModel.events[indexPath.row] as Event? {
            cell.event = event
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
}

extension CalendarEventsViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        if let ppc = popoverPresentationController as UIPopoverPresentationController? {
            ppc.permittedArrowDirections = UIPopoverArrowDirection.allZeros
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
                case Segue.ShowEventWeather:
                    if let vc = segue.destinationViewController as? EventWeatherPopoverViewController {
                        if let indexPath = tableView.indexPathForCell(selectedCell!) {
                            vc.event = dataModel.events[indexPath.row]
                        }
                        if let ppc = vc.popoverPresentationController {
                            ppc.delegate = self
                        }
                    }
                default:
                    break
            }
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        repositionCell()
    }
    
    private func repositionCell() {
        if let cell = selectedCell {
            UIView.animateWithDuration(0.15, animations: {
                cell.center = cell.initialCenterPoint
            })
        }
    }
    
    @IBAction func closePopover(segue:UIStoryboardSegue) {
        if !segue.sourceViewController.isBeingDismissed() {
            if let popover = segue.sourceViewController as? EventWeatherPopoverViewController {
                popover.dismissViewControllerAnimated(true) { [unowned self] in
                    self.repositionCell()
                }
            }
        }
    }
    
}

private struct Segue {
    static let ShowEventWeather = "Show Event Weather"
}

extension CalendarEventsViewController: EventTableViewCellDelegate {
    
    func tableViewCell(didSwipeCellForDeletion cell: EventTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
            dataModel.events.removeAtIndex(indexPath.row)
            tableView.endUpdates()
        }
    }
    
    func tableViewCell(didSwipeCellForWeather cell: EventTableViewCell) {
        selectedCell = cell
        performSegueWithIdentifier(Segue.ShowEventWeather, sender: self)
    }
    
}
