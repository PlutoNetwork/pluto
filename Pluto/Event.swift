//
//  Event.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/27/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import Foundation
import Firebase

class Event: NSObject {
    
    private var eventRef: DatabaseReference?
    
    var key: String!
    var count: Int!
    var creator: String!
    var title: String!
    var image: String!
    var eventDescription: String!
    var address: String!
    var latitude: NSNumber!
    var longitude: NSNumber!
    var timeStart: String!
    var timeEnd: String!
    
    init(count: Int, creator: String, title: String, image: String, eventDescription: String, address: String, latitude: NSNumber, longitude: NSNumber, timeStart: String, timeEnd: String) {
        
        self.count = count
        self.creator = creator
        self.title = title
        self.image = image
        self.eventDescription = eventDescription
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.timeStart = timeStart
        self.timeEnd = timeEnd
    }
    
    init(eventKey: String, eventData: Dictionary<String, AnyObject>) {
        
        self.key = eventKey
        
        if let count = eventData["count"] as? Int {
            
            self.count = count
        }
        
        if let creator = eventData["creator"] as? String {
            
            self.creator = creator
        }
        
        if let title = eventData["title"] as? String {
            
            self.title = title
        }
        
        if let image = eventData["eventImage"] as? String {
            
            self.image = image
        }
        
        if let eventDescription = eventData["eventDescription"] as? String {
            
            self.eventDescription = eventDescription
        }
        
        if let address = eventData["address"] as? String {
            
            self.address = address
        }
        
        if let latitude = eventData["latitude"] as? NSNumber {
            
            self.latitude = latitude
        }
        
        if let longitude = eventData["longitude"] as? NSNumber {
            
            self.longitude = longitude
        }
        
        if let timeStart = eventData["timeStart"] as? String {
            
            self.timeStart = timeStart
        }
        
        if let timeEnd = eventData["timeEnd"] as? String {
            
            self.timeEnd = timeEnd
        }
        
        eventRef = DataService.ds.REF_EVENTS.child(key)
    }
    
    func adjustCount(addToCount: Bool) {
        
        if addToCount {
            
            count = count + 1
            
        } else {
            
            count = count - 1
        }
        
        // Update the database to reflect the count change.
        eventRef?.child("count").setValue(count)
    }
}
