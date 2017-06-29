//
//  Event.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/27/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import Foundation

class Event: NSObject {
    
    private var _key: String!
    private var _count: Int!
    private var _creator: String!
    private var _title: String!
    private var _imageUrl: String!
    
    var key: String {
        
        return _key
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
    
    var imageUrl: String {
        
        return _imageUrl
    }
    
    init(count: Int, creator: String, title: String, imageUrl: String) {
        
        self._count = count
        self._creator = creator
        self._title = title
        self._imageUrl = imageUrl
    }
    
    init(eventKey: String, eventData: Dictionary<String, AnyObject>) {
        
        self._key = eventKey
        
        if let count = eventData["count"] as? Int {
            
            self._count = count
        }
        
        if let creator = eventData["creator"] as? String {
            
            self._creator = creator
        }
        
        if let title = eventData["title"] as? String {
            
            self._title = title
        }
        
        if let imageUrl = eventData["eventImageUrl"] as? String {
            
            self._imageUrl = imageUrl
        }
    }
}
