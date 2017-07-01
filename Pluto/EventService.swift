//
//  EventService.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

struct EventService {
    
    static let sharedInstance = EventService()
    
    func fetchEvents(withKey: String, completion: @escaping (Event) -> ()) {
        
        DataService.ds.REF_EVENTS.observe(.childAdded, with: { (snapshot) in
            
            if let eventData = snapshot.value as? [String: AnyObject] {
                
                let key = snapshot.key
                
                // Check if the key matches the parameter.
                // We need to do this so we only download events that are in the query radius.
                if key == withKey {
                    
                    // Use the data received from Firebase to create a new Event object.
                    let event = Event(eventKey: key, eventData: eventData)
                    
                    // Return the event with completion of the block.
                    completion(event)
                }
            }
        })
    }
    
    func fetchSingleEvent(withKey: String, completion: @escaping (Event) -> ()) {
        
        DataService.ds.REF_EVENTS.child(withKey).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let eventData = snapshot.value as? [String: AnyObject] {
                
                let key = snapshot.key
                
                // Use the data received from Firebase to create a new Event object.
                let event = Event(eventKey: key, eventData: eventData)
                
                // Return the event with completion of the block.
                completion(event)
            }
        })
    }
    
    func checkIfUserIsGoingToEvent(withKey: String, completion: @escaping (Bool) -> ()) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        DataService.ds.REF_EVENTS.child(withKey).child("users").observe(.childAdded, with: { (snapshot) in
            
            let key = snapshot.key
            
            // Check if the key matches the user's Id.
            // This indicates the user is going to the event.
            if key == uid {
                
                // Return true with completion of the block.
                completion(true)
            }
        })
        
        completion(false)
    }
    
    func changeEventCount(event: Event, completion: @escaping () -> ()) {
        
        let eventKey = event.key
        
        let eventRef = DataService.ds.REF_EVENTS.child(eventKey)
        let userEventRef = DataService.ds.REF_CURRENT_USER_EVENTS.child(eventKey)
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        // Adjust the UI and the database to reflect whether or not the user is going to the event.
        userEventRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                
                // Update the count.
                event.adjustCount(addToCount: true)
                
                // Update the database.
                userEventRef.setValue(true)
                eventRef.child("users").child(uid).setValue(true)
                
            } else {
                
                // Update the count.
                event.adjustCount(addToCount: false)
                
                // Remove the values from the database.
                userEventRef.removeValue()
                eventRef.child("users").child(uid).removeValue()
            }
            
            completion()
        })
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
        })
    }
}
