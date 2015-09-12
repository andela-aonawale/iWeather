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

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let recognizer = PanDirectionGestureRecognizer(direction: .Horizontal, target: self, action: "handlePan:")
            recognizer.maximumNumberOfTouches = 1
            tableView.addGestureRecognizer(recognizer)
        }
    }

    private let eventStore: EKEventStore
    private var dataModel = DataModel.sharedInstance
    
    private func requestAccessToCalendar() {
        eventStore.requestAccessToEntityType(EKEntityType.Event) { [unowned self] in
            ($0 && $1 == nil) ? self.fetchCalendars() : self.showNeedPermissionView()
        }
    }
    
    private func showNeedPermissionView() {
        
    }
    
    private func showRestrictedView() {
        
    }
    
    private func fetchCalendars() {
        let calendars = eventStore.calendarsForEntityType(EKEntityType.Event)
        fetchEventsFromCalendars(calendars) { [unowned self] Events in
            for event in Events {
                self.createEvent(event)
            }
        }
        tableView.reloadData()
    }
    
    private func fetchEventsFromCalendars(calendars: [EKCalendar], completed: ([EKEvent]) -> Void) {
        let startDate = NSDate()
        let endDate = NSDate(timeIntervalSinceNow: 604800*10)
        let predicate = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: calendars)
        let eventsArray = eventStore.eventsMatchingPredicate(predicate)
        completed(eventsArray)
    }
    
    private func createEvent(event: EKEvent) {
        if let location = event.valueForKey("structuredLocation") as? EKStructuredLocation {
            if let coordinate = location.geoLocation?.coordinate {
                createEvent(event, coordinate: coordinate)
            } else if !event.location!.isEmpty && (event.startDate != nil ?? false) {
                createEvent(event: event)
            }
        }
    }
    
    private func createEvent(event: EKEvent, coordinate: CLLocationCoordinate2D) {
        let coordinate = Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let event = Event(event: event, coordinate: coordinate)
        dataModel.events.append(event)
    }
    
    private func createEvent(event event: EKEvent) {
        let event = Event(event: event)
        dataModel.events.append(event)
    }
    
    private func enableCalendarAccess() {
        let openSettingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(openSettingsUrl!)
    }
    
    private func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        checkCalendarAuthorizationStatus()
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        eventStore = EKEventStore()
        super.init(coder: aDecoder)
    }
    
    private struct Swipe {
        var toDelete: Bool!
        var toShowWeather: Bool!
    }
    
    private var selectedCell: EventTableViewCell?
    private var swipeFarEnough = Swipe()

}

extension CalendarEventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EventCell") as! EventTableViewCell
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
            ppc.permittedArrowDirections = UIPopoverArrowDirection()
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

extension CalendarEventsViewController {
    
    private func moveCellToPoint(point: CGPoint) {
        let originX = selectedCell!.frame.origin.x
        let cellWidth = selectedCell!.frame.size.width
        swipeFarEnough.toDelete = (originX > cellWidth / 2)
        swipeFarEnough.toShowWeather = (originX < -cellWidth / 2)
        selectedCell!.center = CGPointMake(selectedCell!.initialCenterPoint.x + point.x, selectedCell!.initialCenterPoint.y)
    }
    
    private func setSelectedCellToCellAtPoint(point: CGPoint) {
        if let swipedIndexPath = tableView.indexPathForRowAtPoint(point) {
            if let swipedCell = tableView.cellForRowAtIndexPath(swipedIndexPath) {
                selectedCell = swipedCell as? EventTableViewCell
            }
        } else {
            selectedCell = nil
        }
    }
        
    private func animateCellToPoint(point: CGPoint, performAction: String) {
        UIView.animateWithDuration(0.1, animations: {
            self.selectedCell!.center = point }) { finished in
            if finished {
                switch performAction {
                    case "Delete":
                        self.deleteCellAtIndexPath()
                    case "Show Weather":
                        self.showEventWeather()
                    default:
                        break
                }
            }
        }
    }
    
    private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            case .Began:
                let point = gesture.locationInView(tableView)
                setSelectedCellToCellAtPoint(point)
            case .Changed:
                if selectedCell != nil {
                    let point = gesture.translationInView(tableView)
                    moveCellToPoint(point)
                }
            case .Ended:
                if selectedCell != nil {
                    let cell = (width: selectedCell!.frame.size.width, height: selectedCell!.frame.size.height)
                    let initialFrame = CGRectMake(0, selectedCell!.frame.origin.y, cell.width, cell.height)
                    if !swipeFarEnough.toShowWeather && !swipeFarEnough.toDelete {
                        UIView.animateWithDuration(0.1) { self.selectedCell!.frame = initialFrame }
                    } else if swipeFarEnough.toShowWeather == true {
                        let point = CGPointMake(-cell.width/2, self.selectedCell!.initialCenterPoint.y)
                        animateCellToPoint(point, performAction: "Show Weather")
                    } else if swipeFarEnough.toDelete == true {
                        let point = CGPointMake(cell.width * 1.5, self.selectedCell!.initialCenterPoint.y)
                        animateCellToPoint(point, performAction: "Delete")
                    }
                }
            default:
                break
        }
    }
    
    private func deleteCellAtIndexPath() {
        if let cell = selectedCell {
            if let indexPath = tableView.indexPathForCell(cell) {
                var error: NSError?
                let event = dataModel.events[indexPath.row].event
                do {
                    try eventStore.removeEvent(event!, span: EKSpan.ThisEvent, commit: true)
                    tableView.beginUpdates()
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
                    dataModel.events.removeAtIndex(indexPath.row)
                    tableView.endUpdates()
                } catch let error1 as NSError {
                    error = error1
                    print(error?.localizedDescription)
                }
            }
        }
    }
    
    private func showEventWeather() {
        performSegueWithIdentifier(Segue.ShowEventWeather, sender: self)
    }
    
}
