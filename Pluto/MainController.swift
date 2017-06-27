//
//  MainController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/26/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import Hue

class MainController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the background color of the view using the Hue library.
        let gradient = [UIColor(red: 255, green: 89, blue: 49), UIColor(red: 240, green: 49, blue: 126)].gradient()
        gradient.bounds = view.bounds
        gradient.frame = view.frame
        view.layer.insertSublayer(gradient, at: 0)

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        // If a user is not logged in, get the hell outta here.
        if Auth.auth().currentUser?.uid == nil {
            
            // Without the following line, a warning appears and tells us that we have too many controllers while the app is starting. To fix, add the following:
            perform(#selector(handleLogout), with: nil, afterDelay: 0)            
        }
    }
    
    /**
        - TODO: check if the user logged in using Facebook, then log out of Facebook.
    */
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
