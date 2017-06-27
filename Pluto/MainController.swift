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
    
    // MARK: - UI Components
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // Turn the status bar white.
        return .lightContent
    }
    
    let menuBar: MenuBar = {
        
        let bar = MenuBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        return bar
    }()
    
    // MARK: - View Configuration

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the background color of the view using the Hue library.
        let gradient = [UIColor(red: 255, green: 89, blue: 49), UIColor(red: 240, green: 49, blue: 126)].gradient()
        gradient.bounds = view.bounds
        gradient.frame = view.frame
        view.layer.insertSublayer(gradient, at: 0)

        // Customize the navigation bar.
        navigationController?.navigationBar.isTranslucent = false
        // Add a custom title view to the navigation bar.
        let navigationBarTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        navigationBarTitleLabel.text = "  Pluto"
        navigationBarTitleLabel.textColor = UIColor.black
        navigationBarTitleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = navigationBarTitleLabel
        
        // Add the UI components.
        view.addSubview(menuBar)
        
        // Set up constraints for the UI components.
        setUpMenuBar()
        
        // Add a logout button the navigation bar.
        // navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        checkIfUserLoggedIn()
    }
    
    func checkIfUserLoggedIn() {
        
        // If a user is not logged in, get the hell outta here.
        if Auth.auth().currentUser?.uid == nil {
            
            // Without the following line, a warning appears and tells us that we have too many controllers while the app is starting. To fix, add the following:
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    func setUpMenuBar() {
    
        // Add X, Y, width, and height constraints to the menuBar.
        menuBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        menuBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menuBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        menuBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
