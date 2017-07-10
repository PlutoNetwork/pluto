//
//  User.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/27/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import Foundation

class User: NSObject {
    
    var key: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    
    init(name: String, email: String, profileImageUrl: String) {
        
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        super.init()
        
        self.key = userKey
        
        if let name = userData["name"] as? String {
            
            self.name = name
        }
        
        if let email = userData["email"] as? String {
            
            self.email = email
        }
        
        if let profileImageUrl = userData["profileImageUrl"] as? String {
            
            self.profileImageUrl = profileImageUrl
        }
    }
}
