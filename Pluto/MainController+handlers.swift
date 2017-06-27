//
//  MainController+handlers.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/27/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

extension MainController {
    
    func handleLogout() {
        
        do {
            
            // Sign out using Firebase.
            try Auth.auth().signOut()
            
        } catch let error {
            
            print("ERROR: could not log out the current user. Details: \(error.localizedDescription)")
        }
        
        let loginController = LoginController()
        
        // Transition to the LoginController.
        present(loginController, animated: true, completion: nil)
    }
}
