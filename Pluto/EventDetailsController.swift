//
//  EventDetailsController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import Firebase

class EventDetailsController: FormViewController {
    
    // MARK: - Global Variables
    
    
    // MARK: - View Configuration

    fileprivate func navigationBarCustomization() {
        
        navigationItem.title = "Create Event"
        
        // Set the color of the navigationItem to white.
        let colorAttribute = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = colorAttribute
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarCustomization()
        
        // Create a form using the Eureka library.
        form
            +++ Section("Picture")
            <<< ImageRow() {
                $0.title = "Image"
                $0.sourceTypes = [.PhotoLibrary, .Camera]
                $0.clearAction = .yes(style: .destructive)
            }
            +++ Section("Details")	// The basic event details section.
            <<< TextRow() {
                $0.title = "Title"
                $0.placeholder = "Pick a title for your event"
            }
    }
}
