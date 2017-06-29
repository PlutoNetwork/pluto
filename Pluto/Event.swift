//
//  Event.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/27/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import Foundation

class Event: NSObject {
    
    private var _eventKey: String!
    private var _count: Int!
    private var _creator: String!
    private var _title: String!
    private var _eventImageUrl: String!
    
    var eventKey: String {
        
        return _eventKey
    }
    
    var count: Int {
        
        return _count
    }
    
    var creator: String {
        
        return _creator
    }
    
    var title: String {
        
        return _title
    }
    
    var eventImageUrl: String {
        
        return _eventImageUrl
    }
    
    init(count: Int, creator: String, title: String, eventImageUrl: String) {
        
        self._count = count
        self._creator = creator
        self._title = title
        self._eventImageUrl = eventImageUrl
    }
    
    init(eventKey: String, eventData: Dictionary<String, AnyObject>) {
        
        self._eventKey = eventKey
        
        if let count = eventData["count"] as? Int {
            
            self._count = count
        }
        
        if let creator = eventData["creator"] as? String {
            
            self._creator = creator
        }
        
        if let title = eventData["title"] as? String {
            
            self._title = title
        }
        
        if let eventImageUrl = eventData["eventImageUrl"] as? String {
            
            self._eventImageUrl = eventImageUrl
        }
    }
}
