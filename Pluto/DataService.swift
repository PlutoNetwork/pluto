//
//  DataService.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/26/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import Foundation
import Firebase

/// Contains the url of the database for Pluto.
let DB_BASE = Database.database().reference()

/// Contains the url of the storage for Pluto.
let STORAGE_BASE = Storage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    // Database references
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_EVENTS = DB_BASE.child("events")
    private var _REF_EVENT_LOCATIONS = DB_BASE.child("event_locations")
    private var _REF_MESSAGES = DB_BASE.child("messages")
    private var _REF_EVENT_MESSAGES = DB_BASE.child("event_messages")
    
    var REF_BASE: DatabaseReference {
        
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        
        return _REF_USERS
    }
    
    var REF_CURRENT_USER: DatabaseReference {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return DatabaseReference()
        }
        
        let user = REF_USERS.child(uid)
        
        return user
    }
    
    var REF_CURRENT_USER_EVENTS: DatabaseReference {
        
        return REF_CURRENT_USER.child("events")
    }
    
    var REF_EVENTS: DatabaseReference {
        
        return _REF_EVENTS
    }
    
    var REF_EVENT_LOCATIONS: DatabaseReference {
        
        return _REF_EVENT_LOCATIONS
    }
    
    var REF_MESSAGES: DatabaseReference {
        
        return _REF_MESSAGES
    }

    var REF_EVENT_MESSAGES: DatabaseReference {
        
        return _REF_EVENT_MESSAGES
    }
    
    // Storage references
    private var _REF_PROFILE_PICS = STORAGE_BASE.child("profile_pics").child("\(NSUUID().uuidString).png")
    
    var REF_PROFILE_PICS: StorageReference {
        
        return _REF_PROFILE_PICS
    }
    
    private var _REF_EVENT_PICS = STORAGE_BASE.child("event_pics").child("\(NSUUID().uuidString).png")
    
    var REF_EVENT_PICS: StorageReference {
        
        return _REF_EVENT_PICS
    }
    
    private var _REF_MESSAGE_PICS = STORAGE_BASE.child("message_pics").child("\(NSUUID().uuidString).png")
    
    var REF_MESSAGE_PICS: StorageReference {
        
        return _REF_MESSAGE_PICS
    }
}
