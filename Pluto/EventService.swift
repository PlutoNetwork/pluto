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
    
    func fetchEvent(withKey: String, completion: @escaping (Event) -> ()) {
        
        let eventRef = DataService.ds.REF_EVENTS.child(withKey)
        
        eventRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let eventData = snapshot.value as? [String: AnyObject] {
                
                let key = snapshot.key
                
                // Use the data received from Firebase to create a new Event object.
                let event = Event(eventKey: key, eventData: eventData)
                
                // Return the event with completion of the block.
                completion(event)
            }
        })
    }
    
    func checkIfUserIsGoingToEvent(eventKey: String, completion: @escaping (Bool) -> ()) {
        
        let userEventRef = DataService.ds.REF_CURRENT_USER_EVENTS.child(eventKey)
        
        userEventRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                
                completion(false)
                
            } else {
                
                completion(true)
            }
        })
    }
    
    func addDefaultMessagesTo(event: Event) {
        
        // We need to send the message to the event.
        if let toId = event.key {
        
            // Use the Pluto account's id as the fromId to show the message sender.
            let fromId = PLUTO_ACCOUNT_ID
            
            // We should get a timestamp too, so we know when the event was created..
            let timeStamp = Int(Date().timeIntervalSince1970)
            
            let defaultMessage = "Welcome to the '\(event.title!)' group chat!"
            
            let values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timeStamp": timeStamp as AnyObject, "text": defaultMessage as AnyObject]
            
            MessageService.sharedInstance.updateMessages(toId: toId, fromId: fromId, values: values)
        }
    }
}
