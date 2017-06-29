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
import NVActivityIndicatorView

class EventDetailsController: FormViewController, NVActivityIndicatorViewable {
    
    // MARK: - UI Components
    
    var loadingView: NVActivityIndicatorView?
    
    lazy var manipulateEventButton: UIBarButtonItem = {
        
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleManipulateEvent))
        
        return button
    }()
    
    func handleManipulateEvent() {
        
        // First check if the user has filled out all the required fields.
        if form.validate().isEmpty {
            
            // Create the event.
            UploadService.sharedInstance.uploadEventImageAndCreateEvent(eventTitle: eventTitle!, eventImage: eventImage!, eventLocationCoordinate: coordinate!)
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Global Variables
    
    var coordinate: CLLocationCoordinate2D?
    
    var eventTitle: String?
    var eventImage: UIImage?
    
    // MARK: - View Configuration

    fileprivate func navigationBarCustomization() {
        
        navigationItem.title = "Create Event"
        
        // Set the color of the navigationItem to white.
        let colorAttribute = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = colorAttribute
    }
    
    func setUpNavigationBarButtons() {
        
        navigationItem.rightBarButtonItems = [manipulateEventButton]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarCustomization()
        setUpNavigationBarButtons()
        
        setUpForm()
    }
    
    func setUpForm() {
        
        // Create a form using the Eureka library.
        form
            +++ Section("Details")	// The basic event details section.
            <<< TextRow() {
                $0.title = "Title"
                $0.placeholder = "Pick a title for your event"
                $0.onChange { [unowned self] row in
                    
                    // Set the value to the eventTitle.
                    self.eventTitle = row.value
                }
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.cellUpdate { (cell, row) in
                    
                    if !row.isValid {
                        
                        // The row is empty, notify the user by highlighting the label.
                        cell.titleLabel?.textColor = UIColor.red
                    }
                }
            }
            <<< ImageRow() {
                $0.title = "Select image"
                $0.sourceTypes = [.PhotoLibrary, .Camera]
                $0.clearAction = .yes(style: .destructive)
                $0.onChange { [unowned self] row in
                    
                    // Set the image to the eventImage.
                    self.eventImage = row.value
                }
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.cellUpdate { (cell, row) in
                    
                    if !row.isValid {
                        
                        // For now, just don't allow the user to post.
                        // - TODO: add a default image to the event.
                        
                    }
                }
        }
    }
}
