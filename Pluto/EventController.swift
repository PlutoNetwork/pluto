//
//  EventController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class EventController: FormViewController {
        
    // MARK: - UI Components
    
    func handleCreateEvent() {
        
        // The user is saving a new event.
        // Check if the user has filled out all the required fields.
        if form.validate().isEmpty {
            
            // Create the event.
            createEvent()
            
            // Dismiss the controller.
            navigationController?.popViewController(animated: true)
        }
    }
    
    func handleUpdateEvent() {
        
        // The user is updating a created event.
        // Check if the user has filled out all the required fields.
        if form.validate().isEmpty {
            
            // Update the event.
            updateEvent()
        }
        
        // Dismiss the controller.
        navigationController?.popViewController(animated: true)
    }
    
    func handleChangeEventCount() {
        
        if let eventToBeAddedOrRemoved = self.event {
            
            // The user wants to add a created event.
            changeEventCount(event: eventToBeAddedOrRemoved)
        }
        
        // Dismiss the controller.
        navigationController?.popViewController(animated: true)
    }
    
    func createEvent() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        // Add other required values like count to the event.
        newEventValues["count"] = 1 as AnyObject
        newEventValues["creator"] = uid as AnyObject
        
        guard let latitude = newEventValues["latitude"] as? CLLocationDegrees, let longitude = newEventValues["longitude"] as? CLLocationDegrees else { return }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        LocationService.sharedInstance.convertCoordinatesToAddress(latitude: latitude, longitude: longitude) { (address) in
            
            self.newEventValues["address"] = address as AnyObject
            
            /// An event created on Firebase with a random key.
            let newEventRef = DataService.ds.REF_EVENTS.childByAutoId()
            
            self.updateFirebaseWith(newEventReference: newEventRef, location: location)
        }
    }
    
    func updateFirebaseWith(newEventReference: DatabaseReference, location: CLLocation) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        /// Uses the event reference to add data to the event created on Firebase.
        newEventReference.setValue(newEventValues, withCompletionBlock: { (error, reference) in
            
            /// The key for the event created on Firebase.
            let newEventKey = newEventReference.key
            
            /// A reference to the new event under the current user.
            let userEventRef = DataService.ds.REF_CURRENT_USER.child("events").child(newEventKey)
            userEventRef.setValue(true) // Sets the value to true indicating the event is under the user.
            
            /// A reference to the current user under the event.
            let eventUserRef = DataService.ds.REF_EVENTS.child(newEventKey).child("users").child(uid)
            eventUserRef.setValue(true)
            
            // Save the event location to Firebase.
            let geoFire = GeoFire(firebaseRef: DataService.ds.REF_EVENT_LOCATIONS)
            geoFire?.setLocation(location, forKey: newEventKey)
            
            // Use the Event model to reference the event so we can add a message to it.
            let newEvent = Event(eventKey: newEventKey, eventData: self.newEventValues as Dictionary<String, AnyObject>)
            
            // Create a default message and add it to the event.
            self.addDefaultMessageTo(event: newEvent)
            
            // Sync the event to the user's calendar.
            EventService.sharedInstance.syncToCalendar(add: true, event: newEvent)
        })
    }
    
    func addDefaultMessageTo(event: Event) {
        
        // We need to send the message to the event.
        if let toId = event.key {
            
            // Use the Pluto account's id as the fromId to show the message sender.
            let fromId = PLUTO_ACCOUNT_ID
            
            // We should get a timestamp too, so we know when the event was created..
            let timeStamp = Int(Date().timeIntervalSince1970)
            
            let defaultMessage = "Welcome to the '\(event.title!)' group chat!"
            
            let values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromIdProfileImageUrl": PLUTO_DEFAULT_IMAGE_URL as AnyObject, "timeStamp": timeStamp as AnyObject, "text": defaultMessage as AnyObject]
            
            MessageService.sharedInstance.updateMessages(toId: toId, fromId: fromId, values: values)
        }
    }
    
    func updateEvent() {
        
        if let event = event {
        
            /// Holds the reference to the user's image key in the database.
            let eventRef = DataService.ds.REF_EVENTS.child(event.key)
            eventRef.updateChildValues(newEventValues)
        }
    }
    
    func changeEventCount(event: Event) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        if let eventKey = event.key {
            
            let eventRef = DataService.ds.REF_EVENTS.child(eventKey).child("users").child(uid)
            let userEventRef = DataService.ds.REF_CURRENT_USER_EVENTS.child(eventKey)
            
            // Adjust the database to reflect whether or not the user is going to the event.
            
            EventService.sharedInstance.checkIfUserIsGoingToEvent(eventKey: eventKey) { (isUserGoing) in
                
                if isUserGoing {
                    
                    event.adjustCount(addToCount: false)
                    eventRef.removeValue()
                    userEventRef.removeValue()
                    EventService.sharedInstance.syncToCalendar(add: false, event: event)
                    
                } else {
                    
                    event.adjustCount(addToCount: true)
                    eventRef.setValue(true)
                    userEventRef.setValue(true)
                    EventService.sharedInstance.syncToCalendar(add: true, event: event)
                }
            }
        }
    }
    
    // MARK: - Global Variables
    
    var event: Event?
    
    var isNewEvent = false
    var newEventValues = [String: AnyObject]()
    var isEventCreator = false
    
    // MARK: - View Configuration

    fileprivate func navigationBarCustomization() {
        
        // Set the color of the navigationItem to white.
        let colorAttribute = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = colorAttribute
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarCustomization()
        
        // Customize the view.
        tableView.backgroundColor = HIGHLIGHT_COLOR
        tableView.separatorColor = LIGHT_BLUE_COLOR
        
        checkPassedInEvent()
    }
    
    func checkPassedInEvent() {
        
        var navigationItemTitle: String?
        var manipulateEventBarButtonItem: UIBarButtonItem?
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        if event == nil {
            
            // The user wants to create a new event.
            isNewEvent = true
            isEventCreator = true
            
            let blank = ""
            newEventValues["title"] = blank as AnyObject
            newEventValues["eventImage"] = blank as AnyObject
            newEventValues["eventDescription"] = blank as AnyObject
            newEventValues["timeStart"] = Date().toString() as AnyObject
            newEventValues["timeEnd"] = Date().addingTimeInterval(60*60).toString() as AnyObject
            
            guard let latitude = newEventValues["latitude"] as? CLLocationDegrees, let longitude = newEventValues["longitude"] as? CLLocationDegrees else { return }
            
            LocationService.sharedInstance.convertCoordinatesToAddress(latitude: latitude, longitude: longitude, completion: { (address) in
                
                self.newEventValues["address"] = address as AnyObject
                
                self.setUpForm()
            })
            
            navigationItemTitle = "Create Event"
            manipulateEventBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleCreateEvent))
            navigationItem.rightBarButtonItems = [manipulateEventBarButtonItem!]
            
        } else {

            if let event = event {
            
                newEventValues = ["title": event.title,
                                  "eventImage": event.image,
                                  "eventDescription": event.eventDescription,
                                  "address": event.address,
                                  "latitude": event.latitude,
                                  "longitude": event.longitude,
                                  "timeStart": event.timeStart,
                                  "timeEnd": event.timeEnd] as [String: AnyObject]
            }
            
            // The user is viewing a created event.
            // Check if the user is the event creator.
            if let eventCreator = event?.creator {
                
                if eventCreator == uid {
                    
                    // The user is the event creator.
                    isEventCreator = true
                    
                    navigationItemTitle = "Edit Event"
                    manipulateEventBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleUpdateEvent))
                    navigationItem.rightBarButtonItems = [manipulateEventBarButtonItem!]
                    
                } else {
                    
                    // The user is not the creator.
                    //self.tableView.isUserInteractionEnabled = false
                    
                    navigationItemTitle = "Event Details"
                    
                    if let eventKey = event?.key {
                    
                        // Check if the user is already going to the event.
                        EventService.sharedInstance.checkIfUserIsGoingToEvent(eventKey: eventKey, completion: { (isUserGoing) in
                            
                            if isUserGoing {
                                
                                manipulateEventBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_clear_white"), style: .plain, target: self, action: #selector(self.handleChangeEventCount))
                                
                            } else {
                                
                                manipulateEventBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_add_white"), style: .plain, target: self, action: #selector(self.handleChangeEventCount))
                            }
                            
                            self.navigationItem.rightBarButtonItems = [manipulateEventBarButtonItem!]
                        })
                    }
                }
            }
            
            self.setUpForm()
        }
        
        navigationItem.title = navigationItemTitle
    }
    
    func setUpForm() {
        
        guard let latitude = newEventValues["latitude"] as? CLLocationDegrees, let longitude = newEventValues["longitude"] as? CLLocationDegrees else { return }
        
        // Create a form using the Eureka library.
        
        // If it's not a new event, show people going to the event.
        if !isNewEvent {
            form
                +++ Section(){ section in
                    var header = HeaderFooterView<FriendsView>(.class)
                    header.height = { 100 }
                    header.onSetupView = { view, _ in
                        
                        view.event = self.event
                        view.eventController = self
                    }
                    section.header = header
                }
                
                +++ Section()
                <<< PushRow<String>() {
                    $0.title = "People going"
                    $0.options = ["🍔", "🏈", "🎉", "🎷"]
                    $0.cell.backgroundColor = DARK_BLUE_COLOR
                    $0.value = ""
                    $0.selectorTitle = "Choose an emoji"
                    $0.onChange { row in
                        
                        // Set the value to the event's image.
                        self.newEventValues["eventImage"] = row.value as AnyObject
                    }
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    $0.cellUpdate { (cell, row) in
                        
                        cell.textLabel?.textColor = WHITE_COLOR
                        cell.tintColor = WHITE_COLOR
                    }
                    _ = $0.onPresent { (from, to) in
                        
                        // Change the colors of the push view controller.
                        to.view.layoutSubviews()
                        to.tableView?.backgroundColor = DARK_BLUE_COLOR
                        to.tableView.separatorColor = LIGHT_BLUE_COLOR
                        to.selectableRowCellUpdate = { (cell, row) in
                            
                            cell.backgroundColor = DARK_BLUE_COLOR
                        }
                    }
            }
        }
        
        form
            +++ Section()
            <<< TextRow() {
                $0.title = "Title"
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.value = newEventValues["title"] as? String
                $0.onChange { row in
                    
                    // Set the value to the event's title.
                    self.newEventValues["title"] = row.value as AnyObject
                }
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.cellUpdate { (cell, row) in
                    
                    cell.titleLabel?.textColor = WHITE_COLOR
                    cell.textField.textColor = WHITE_COLOR
                    cell.tintColor = WHITE_COLOR
                    
                    if !row.isValid {
                        
                        // The row is empty, notify the user by highlighting the label.
                        cell.titleLabel?.textColor = UIColor.red
                    }
                }
            }
            <<< PushRow<String>() {
                $0.title = "Type"
                $0.options = ["🍔", "🏈", "🎉", "🎷"]
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.value = (newEventValues["eventImage"] as? String)
                $0.selectorTitle = "Choose an emoji"
                $0.onChange { row in
                    
                    // Set the value to the event's image.
                    self.newEventValues["eventImage"] = row.value as AnyObject
                }
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.cellUpdate { (cell, row) in
                    
                    cell.textLabel?.textColor = WHITE_COLOR
                    cell.tintColor = WHITE_COLOR
                    
                    if !row.isValid {
                        
                        // The row is empty, notify the user by highlighting the label.
                        cell.textLabel?.textColor = UIColor.red
                    }
                }
                _ = $0.onPresent { (from, to) in
                    
                    // Change the colors of the push view controller.
                    to.view.layoutSubviews()
                    to.tableView?.backgroundColor = DARK_BLUE_COLOR
                    to.tableView.separatorColor = LIGHT_BLUE_COLOR
                    to.selectableRowCellUpdate = { (cell, row) in
                     
                        cell.backgroundColor = DARK_BLUE_COLOR
                    }
                }
            }
            <<< TextAreaRow() {
                $0.placeholder = "Description"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 110)
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.value = newEventValues["eventDescription"] as? String
                $0.cellUpdate({ (cell, row) in
                    
                    cell.textView.backgroundColor = DARK_BLUE_COLOR
                    cell.textView.textColor = WHITE_COLOR
                    cell.textView.tintColor = WHITE_COLOR
                    cell.placeholderLabel?.textColor = WHITE_COLOR
                })
                $0.onChange { row in
                    
                    // Set the value to the event's description.
                    self.newEventValues["eventDescription"] = row.value as AnyObject
                }
            }
            
            +++ Section()
            <<< LabelRow () {
                $0.title = (newEventValues["address"] as? String)
                $0.tag = "address"
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.cellUpdate({ (cell, row) in
                    
                    cell.textLabel?.textColor = WHITE_COLOR
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                    
                })
            }
            
            if isEventCreator {
                form
                    +++ Section()
                    <<< LocationRow () {
                        $0.title = "Change location"
                        $0.value = CLLocation(latitude: latitude, longitude: longitude)
                        $0.cell.backgroundColor = DARK_BLUE_COLOR
                        $0.cellUpdate({ (cell, row) in
                            
                            cell.textLabel?.textColor = WHITE_COLOR
                            cell.tintColor = WHITE_COLOR
                            cell.detailTextLabel?.textColor = WHITE_COLOR
                            
                            if !row.isValid {
                                
                                // The row is empty, notify the user by highlighting the label.
                                cell.textLabel?.textColor = UIColor.red
                            }
                        })
                        $0.onChange { [weak self] row in
                            
                            let addressLabelRow: LabelRow! = self?.form.rowBy(tag: "address")
                            
                            // Set the value to the event's coordinates.
                            if let eventCoordinate = row.value?.coordinate {
                                
                                // Save it as an NSNumber so Firebase can store it.
                                let latitude: NSNumber = NSNumber(value: eventCoordinate.latitude)
                                let longitude: NSNumber = NSNumber(value: eventCoordinate.longitude)
                                
                                self?.newEventValues["latitude"] = latitude
                                self?.newEventValues["longitude"] = longitude
                                
                                LocationService.sharedInstance.convertCoordinatesToAddress(latitude: eventCoordinate.latitude, longitude: eventCoordinate.longitude, completion: { (address) in
                                    
                                    addressLabelRow.value = address
                                    self?.newEventValues["address"] = address as AnyObject
                                })
                            }
                        }
                    }
                }
        
        form
            +++ Section()
            <<< DateTimeInlineRow("Starts") {
                $0.title = $0.tag
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.value = (newEventValues["timeStart"] as? String)?.toDate()
                $0.cellUpdate { (cell, row) in
                    
                    cell.textLabel?.textColor = WHITE_COLOR
                    cell.tintColor = WHITE_COLOR
                    cell.detailTextLabel?.textColor = WHITE_COLOR
                    
                    if self.isNewEvent {
                        
                        // Set the starting value to the event's start time.
                        let timeStart = row.value?.toString()
                        self.newEventValues["timeStart"] = timeStart as AnyObject
                    }
                }
                }
                .onChange { [weak self] row in
                    
                    let endRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Ends")
                    
                    if let endRowValue = endRow.value {
                    
                        if row.value?.compare(endRowValue) == .orderedDescending {
                            
                            endRow.value = Date(timeInterval: 60*60, since: row.value!)
                            
                            endRow.cell!.textLabel?.textColor = UIColor.red
                            
                            endRow.updateCell()
                            
                            // Set the value to the event's start time.
                            let timeStart = row.value?.toString()
                            self?.newEventValues["timeStart"] = timeStart as AnyObject
                            
                            // Set the endRow's value to the event's end time (in case he/she does not change the end row).
                            let timeEnd = endRowValue.toString()
                            self?.newEventValues["timeEnd"] = timeEnd as AnyObject
                        }
                    }
                }
                .onExpandInlineRow { cell, row, inlineRow in
                    
                    inlineRow.cellUpdate() { cell, row in
                        cell.datePicker.datePickerMode = .dateAndTime
                        cell.datePicker.backgroundColor = DARK_BLUE_COLOR
                        cell.datePicker.setValue(WHITE_COLOR, forKey: "textColor")
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
            }
            <<< DateTimeInlineRow("Ends") {
                $0.title = $0.tag
                $0.value = (newEventValues["timeEnd"] as? String)?.toDate()
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.cellUpdate { (cell, row) in
                    
                    cell.textLabel?.textColor = WHITE_COLOR
                    cell.tintColor = WHITE_COLOR
                    cell.detailTextLabel?.textColor = WHITE_COLOR
                    
                    if self.isNewEvent {
                        
                        // Set the starting value to the event's end time.
                        let timeEnd = row.value?.toString()
                        self.newEventValues["timeEnd"] = timeEnd as AnyObject
                    }
                }
                }
                .onChange { [weak self] row in
                    let startRow: DateTimeInlineRow! = self?.form.rowBy(tag: "Starts")
                    
                    if let startRowValue = startRow.value {
                    
                        if row.value?.compare(startRowValue) == .orderedAscending {
                            
                            row.cell!.textLabel?.textColor = UIColor.red
                        }
                            
                        else {
                            
                            row.cell!.textLabel?.textColor = WHITE_COLOR
                        }
                    }
                    
                    row.updateCell()
                    
                    // Set the value to the event's end time.
                    let timeEnd = row.value?.toString()
                    self?.newEventValues["timeEnd"] = timeEnd as AnyObject
                }
                .onExpandInlineRow { cell, row, inlineRow in
                    inlineRow.cellUpdate { cell, dateRow in
                        cell.datePicker.datePickerMode = .dateAndTime
                        cell.datePicker.backgroundColor = DARK_BLUE_COLOR
                        cell.datePicker.setValue(WHITE_COLOR, forKey: "textColor")
                    }
                    let color = cell.detailTextLabel?.textColor
                    row.onCollapseInlineRow { cell, _, _ in
                        cell.detailTextLabel?.textColor = color
                    }
                    cell.detailTextLabel?.textColor = cell.tintColor
        }
        
        // Add a delete option if the user is the event's creator.
        if !isNewEvent && isEventCreator {
            
            form
                +++ Section()
                <<< ButtonRow() { (row: ButtonRow) -> Void in
                    
                        row.title = "Delete"
                    }
                    .cellUpdate({ (cell, row) in
                        
                        cell.backgroundColor = DARK_BLUE_COLOR
                        cell.textLabel?.textColor = UIColor.red
                    })
                    .onCellSelection { [weak self] (cell, row) in
                        
                        // Delete the event.
                        if let eventToBeDeleted = self?.event {
                            
                            self?.deleteEvent(event: eventToBeDeleted)
                        }
                    }
        }
    }
    
    func deleteEvent(event: Event) {
        
        let notice = SCLAlertView()
        
        notice.addButton("Delete") {
            
            // Remove the event from the calendar.
            EventService.sharedInstance.syncToCalendar(add: false, event: event)
            
            if let eventKey = event.key {
                
                // Delete the event under users who are attending.
                EventService.sharedInstance.updateUserEventsUnder(eventKey: eventKey, completion: {
                    
                    //DataService.ds.REF_EVENTS.child(eventKey).removeValue()
                })
                
                let geoFire = GeoFire(firebaseRef: DataService.ds.REF_EVENT_LOCATIONS)
                geoFire?.removeKey(eventKey)
                
                // Grab the messages under the event and delete them.
                MessageService.sharedInstance.deleteMessagesUnder(eventKey: eventKey, completion: { 
                    
                    DataService.ds.REF_EVENT_MESSAGES.child(eventKey).removeValue()
                })
            }
            
            // Dismiss the controller.
            self.navigationController?.popViewController(animated: true)
        }
        
        notice.showWarning("Are you sure?", subTitle: "This event will be deleted and event-goers will be notified.", closeButtonTitle: "On second thought...")
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // Change header label color.
        if let view = view as? UITableViewHeaderFooterView {
            
            view.textLabel?.textColor = LIGHT_BLUE_COLOR
        }
    }
}
