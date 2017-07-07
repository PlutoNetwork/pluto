//
//  EventService.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import EventKit

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
            
            let values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromIdProfileImageUrl": PLUTO_DEFAULT_IMAGE_URL as AnyObject, "timeStamp": timeStamp as AnyObject, "text": defaultMessage as AnyObject]
            
            MessageService.sharedInstance.updateMessages(toId: toId, fromId: fromId, values: values)
        }
    }
    
    var calendar: EKCalendar!
    
    func syncToCalendar(add: Bool, event: Event) {
        
        let eventStore = EKEventStore()
        
        if EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized {
            
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                
                if error != nil {
                    
                    /* ERROR: Something went wrong and the user's calendar could not be accessed. */
                    
                    print(error.debugDescription)
                    
                } else {
                    
                    /* SUCCESS: We have access to modify the user's calendar. */
                    
                    if add {
                        
                        DispatchQueue.main.async {
                            
                            self.calendarCall(calEvent: eventStore, add: true, event: event)
                        }
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            self.calendarCall(calEvent: eventStore, add: false, event: event)
                        }
                    }
                }
            })
            
        } else {
            
            // Code if we already have permission.
            
            if add {
                
                calendarCall(calEvent: eventStore, add: true, event: event)
                
            } else {
                
                self.calendarCall(calEvent: eventStore, add: false, event: event)
            }
        }
    }
    func calendarCall(calEvent: EKEventStore, add: Bool, event: Event){
        
        let newEvent = EKEvent(eventStore: calEvent)
        
        newEvent.title = event.title //Sets event title
        newEvent.startDate = event.timeStart.toDate() // Sets start date and time for event
        newEvent.endDate = event.timeEnd.toDate() // Sets end date and time for event
        newEvent.location = event.address // Copies location into calendar
        newEvent.calendar = calEvent.defaultCalendarForNewEvents // Copies event into calendar
        newEvent.notes = event.eventDescription // Copies event description into calendar
        
        if add {
            
            do {
                
                //Saves event to calendar
                try calEvent.save(newEvent, span: .thisEvent)
                
                let notice = SCLAlertView()
                
                notice.addButton("Go to calendar", action: {
                    
                    let date = newEvent.startDate as NSDate
                    
                    UIApplication.shared.openURL(NSURL(string: "calshow:\(date.timeIntervalSinceReferenceDate)")! as URL)
                })
                
                notice.showSuccess("Success", subTitle: "Event added to calendar.", closeButtonTitle: "Done")
                
            } catch {
                
                SCLAlertView().showError("Error!", subTitle: "Event not added; try again later.")
            }
            
        } else {
            
            let predicate = calEvent.predicateForEvents(withStart: newEvent.startDate, end: newEvent.endDate, calendars: nil)
            
            let eV = calEvent.events(matching: predicate) as [EKEvent]!
            
            if eV != nil {
                
                for i in eV! {
                    
                    if i.title == newEvent.title {
                        
                        do {
                            
                            try calEvent.remove(i, span: EKSpan.thisEvent, commit: true)
                            
                            SCLAlertView().showSuccess("Success", subTitle: "Event removed from calendar.")
                            
                        } catch {
                            
                            SCLAlertView().showError("Error!", subTitle: "Event not removed; try again later.")
                        }
                    }
                }
            }
        }
    }
}
