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
import NVActivityIndicatorView

class EventController: FormViewController, NVActivityIndicatorViewable {
        
    // MARK: - UI Components
    
    var loadingView: NVActivityIndicatorView?
    
    func handleCreateEvent() {
        
        if let eventTitle = self.newEventTitle, let eventImage = self.newEventImage {
            
            // The user is saving a new event.
            // Check if the user has filled out all the required fields.
            if form.validate().isEmpty {
                
                // Create the event.
                createEvent(eventTitle: eventTitle, eventImage: eventImage, eventLocationCoordinate: coordinate!)
            }
        }
        
        // Dismiss the controller.
        navigationController?.popViewController(animated: true)
    }
    
    func handleUpdateEvent() {
        
        if let eventToBeUpdated = self.event {
            
            // The user is updating a created event.
            // Check if the user has filled out all the required fields.
            if form.validate().isEmpty {
                
                // Update the event.
                updateEvent(event: eventToBeUpdated)
            }
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
    
    func createEvent(eventTitle: String, eventImage: String, eventLocationCoordinate: CLLocationCoordinate2D) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        // Create a dictionary of values to add to the database.
        let values = ["count": 1,
                      "creator": uid,
                      "title": eventTitle as Any,
                      "eventImage": eventImage] as [String: Any]
        
        /// An event created on Firebase with a random key.
        let newEvent = DataService.ds.REF_EVENTS.childByAutoId()
        
        /// Uses the event model to add data to the event created on Firebase.
        newEvent.setValue(values, withCompletionBlock: { (error, reference) in
            
            /// The key for the event created on Firebase.
            let newEventKey = newEvent.key
            
            /// A reference to the new event under the current user.
            let userEventRef = DataService.ds.REF_CURRENT_USER.child("events").child(newEventKey)
            userEventRef.setValue(true) // Sets the value to true indicating the event is under the user.
            
            /// A reference to the current user under the event.
            let eventUserRef = DataService.ds.REF_EVENTS.child(newEventKey).child("users").child(uid)
            eventUserRef.setValue(true)
            
            // Save the event location to Firebase.
            let location = CLLocation(latitude: eventLocationCoordinate.latitude, longitude:eventLocationCoordinate.longitude)
            
            let geoFire = GeoFire(firebaseRef: DataService.ds.REF_EVENT_LOCATIONS)
            geoFire?.setLocation(location, forKey: newEventKey)
            
            // Use the Event model to reference the event so we can add a message to it.
            let event = Event(eventKey: newEventKey, eventData: values as Dictionary<String, AnyObject>)
            
            // Create a default message and add it to the event.
            EventService.sharedInstance.addDefaultMessagesTo(event: event)
        })
    }
    
    func updateEvent(event: Event) {
        
        /// Holds the reference to the user's image key in the database.
        let eventRef = DataService.ds.REF_EVENTS.child(event.key)
        
        // Sets the value for the updated fields.
        
        let updatedEvent = ["title": event.title as Any,
                            "eventImage": event.image as Any]
        
        eventRef.updateChildValues(updatedEvent)
    }
    
    func changeEventCount(event: Event) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        if let eventKey = event.key {
            
            let eventRef = DataService.ds.REF_EVENTS.child(eventKey).child("events").child(uid)
            let userEventRef = DataService.ds.REF_CURRENT_USER_EVENTS.child(eventKey)
            
            // Adjust the database to reflect whether or not the user is going to the event.
            
            EventService.sharedInstance.checkIfUserIsGoingToEvent(eventKey: eventKey) { (isUserGoing) in
                
                if isUserGoing {
                    
                    event.adjustCount(addToCount: false)
                    eventRef.removeValue()
                    userEventRef.removeValue()
                    
                } else {
                    
                    event.adjustCount(addToCount: true)
                    eventRef.setValue(true)
                    userEventRef.setValue(true)
                }
            }
        }
    }
    
    // MARK: - Global Variables
    
    var coordinate: CLLocationCoordinate2D?
    
    var event: Event?
    
    var isNewEvent = false
    var newEventTitle: String?
    var newEventImage: String?
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
        
        setUpForm()
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
            
            // Set empty values for the new event.
            event?.title = ""
            event?.image = ""
            
            navigationItemTitle = "Create Event"
            manipulateEventBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleCreateEvent))
            
        } else {
            
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
        }
        
        navigationItem.title = navigationItemTitle
    }
    
    func setUpForm() {
        
        // Create a form using the Eureka library.
        form
            +++ Section("Details")	// The basic event details section.
            <<< TextRow() {
                $0.title = "Title"
                $0.placeholder = "Pick a title for your event"
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.value = event?.title
                $0.onChange { [unowned self] row in
                    
                    // Set the value to the event's title.
                    self.newEventTitle = row.value
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
                $0.title = "Select image"
                $0.selectorTitle = "Pick an image"
                $0.options = ["🍔", "🏈", "🎉", "🎷"]
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.value = self.event?.image
                $0.onChange { [unowned self] row in
                    
                    // Set the value to the event's image.
                    self.newEventImage = row.value
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
            }
        
        // Add a delete option if the user is the event's creator.
        if !isNewEvent && isEventCreator {
            
            form
                +++ Section("Delete")
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
            
            if let eventKey = event.key {
                
                DataService.ds.REF_EVENTS.child(eventKey).removeValue()
                DataService.ds.REF_CURRENT_USER_EVENTS.child(eventKey).removeValue()
                
                // Grab the messages under the event and delete them.
                DataService.ds.REF_EVENT_MESSAGES.child(eventKey).observe(.childAdded, with: { (snapshot) in
                    
                    let messageKey = snapshot.key
                    
                    // Delete all the messages.
                    DataService.ds.REF_MESSAGES.child(messageKey).removeValue()
                })
                
                // Delete the event message node.
                DataService.ds.REF_EVENT_MESSAGES.child(eventKey).removeValue()
            }
            
            // Dismiss the controller.
            self.navigationController?.popViewController(animated: true)
        }
        
        notice.showWarning("Are you sure?", subTitle: "This event will be deleted and event-goers will be notified.", closeButtonTitle: "On second thought...")
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // Change header label color.
        if let view = view as? UITableViewHeaderFooterView {
            
            view.textLabel?.textColor = WHITE_COLOR
        }
    }
}
