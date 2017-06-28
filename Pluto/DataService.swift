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
    
    // Storage references
    private var _REF_PROFILE_PICS = STORAGE_BASE.child("profile_pics").child("\(NSUUID().uuidString).png")
    
    var REF_PROFILE_PICS: StorageReference {
        
        return _REF_PROFILE_PICS
    }
}
