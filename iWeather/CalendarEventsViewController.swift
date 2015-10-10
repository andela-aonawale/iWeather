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
        if let location = event.valueForKey(DictionaryConstant.StructuredLocation) as? EKStructuredLocation {
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
    
    private var swipedCell: EventTableViewCell?
    private var swipeFarEnough = Swipe()

}

extension CalendarEventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.events.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.EventCell) as! EventTableViewCell
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
                    guard let vc = segue.destinationViewController as? EventWeatherPopoverViewController else {
                        return
                    }
                    guard let indexPath = tableView.indexPathForCell(swipedCell!) else {
                        return
                    }
                    vc.event = dataModel.events[indexPath.row]
                    guard let ppc = vc.popoverPresentationController else {
                        return
                    }
                    ppc.delegate = self
                default:
                    break
            }
        }
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        repositionCell()
    }
    
    private func repositionCell() {
        guard let swipedCell = swipedCell else {
            return
        }
        UIView.animateWithDuration(0.15,
            animations: {
                swipedCell.center = swipedCell.initialCenterPoint
            }
        )
    }
    
    @IBAction func closePopover(segue:UIStoryboardSegue) {
        guard !segue.sourceViewController.isBeingDismissed() else {
            return
        }
        guard let popover = segue.sourceViewController as? EventWeatherPopoverViewController else {
            return
        }
        popover.dismissViewControllerAnimated(true) { [unowned self] in
            self.repositionCell()
        }
    }
    
}

extension CalendarEventsViewController {
    
    private func moveCellToPoint(point: CGPoint) {
        if let swipedCell = swipedCell {
            let originX = swipedCell.frame.origin.x
            let cellWidth = swipedCell.frame.size.width
            swipeFarEnough.toDelete = (originX > cellWidth / 2)
            swipeFarEnough.toShowWeather = (originX < -cellWidth / 2)
            swipedCell.center = CGPoint(x: (swipedCell.initialCenterPoint.x + point.x), y: swipedCell.initialCenterPoint.y)
        }
    }
    
    private func setswipedCellToCellAtPoint(point: CGPoint) {
        if let swipedIndexPath = tableView.indexPathForRowAtPoint(point) {
            if let swipedCell = tableView.cellForRowAtIndexPath(swipedIndexPath) {
                self.swipedCell = swipedCell as? EventTableViewCell
            }
        } else {
            swipedCell = nil
        }
    }
        
    private func animateCellToPoint(point: CGPoint, action: PerformAction) {
        UIView.animateWithDuration(0.1, animations: {
            self.swipedCell!.center = point }) { finished in
            switch action {
                case .Delete where finished:
                    self.confirmDeletion()
                case .ShowWeather where finished:
                    self.showEventWeather()
                default:
                    break
            }
        }
    }
    
    enum PerformAction {
        case Delete
        case ShowWeather
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            case .Began:
                let point = gesture.locationInView(tableView)
                setswipedCellToCellAtPoint(point)
            case .Changed where swipedCell != nil:
                let point = gesture.translationInView(tableView)
                moveCellToPoint(point)
            case .Ended where swipedCell != nil:
                let cell = (width: swipedCell!.frame.size.width, height: swipedCell!.frame.size.height)
                let initialFrame = CGRect(x: 0, y: swipedCell!.frame.origin.y, width: cell.width, height: cell.height)
                if !swipeFarEnough.toShowWeather && !swipeFarEnough.toDelete {
                    UIView.animateWithDuration(0.1) { self.swipedCell!.frame = initialFrame }
                } else if swipeFarEnough.toShowWeather == true {
                    let point = CGPoint(x: -cell.width/2, y: self.swipedCell!.initialCenterPoint.y)
                    animateCellToPoint(point, action: .ShowWeather)
                } else if swipeFarEnough.toDelete == true {
                    let point = CGPoint(x: cell.width * 1.5, y: self.swipedCell!.initialCenterPoint.y)
                    animateCellToPoint(point, action: .Delete)
                }
            default:
                break
        }
    }
    
    private func confirmDeletion() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete this event?" , preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .Default) { action in
            self.deleteSwipedCell()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            self.repositionCell()
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func deleteSwipedCell() {
        if let swipedCell = swipedCell, indexPath = tableView.indexPathForCell(swipedCell) {
            let event = dataModel.events[indexPath.row].event
            do {
                try eventStore.removeEvent(event!, span: EKSpan.ThisEvent, commit: true)
                dataModel.events.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    private func showEventWeather() {
        performSegueWithIdentifier(Segue.ShowEventWeather, sender: self)
    }
    
}
