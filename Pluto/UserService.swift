//
//  UserService.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

struct UserService {
    
    static let sharedInstance = UserService()
    
    func fetchUserData(withKey: String, completion: @escaping (User) -> ()) {
        
        // Go into the Firebase database and retrieve the given user's data.
        DataService.ds.REF_USERS.child(withKey).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userData = snapshot.value as? [String: AnyObject] {
                
                let user = User(userData: userData)
                
                completion(user)
            }
        })
    }
}
