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
                    let event = Event(eventKey: snapshot.key, eventData: eventData)
                    
                    // Return the event with completion of the block.
                    completion(event)
                }
            }
        })
    }
    
    func uploadEventImageAndCreateEvent(eventTitle: String, eventImage: UIImage, eventLocationCoordinate: CLLocationCoordinate2D) {
                
        // Upload the eventImage to the Firebase Storage.
        if let uploadData = UIImagePNGRepresentation(eventImage) {
            
            DataService.ds.REF_EVENT_PICS.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    print("ERROR: could not upload event pic to Firebase. Details: \(error.debugDescription)")
                    return
                }
                
                if let eventImageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    // Create the event.
                    self.createEvent(eventTitle: eventTitle, eventImageUrl: eventImageUrl, eventLocationCoordinate: eventLocationCoordinate)
                }
            })
        }
    }
    
    func createEvent(eventTitle: String, eventImageUrl: String, eventLocationCoordinate: CLLocationCoordinate2D) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        // Create a dictionary of values to add to the database.
        let values = ["count": 1,
                      "creator": uid,
                      "title": eventTitle as Any,
                      "eventImageUrl": eventImageUrl] as [String: Any]
        
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
