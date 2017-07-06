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
    
    init(count: Int, creator: String, title: String, image: String) {
        
        self.count = count
        self.creator = creator
        self.title = title
        self.image = image
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
