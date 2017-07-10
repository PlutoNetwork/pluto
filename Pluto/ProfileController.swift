//
//  ProfileController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/10/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

class ProfileController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI Components
    
    lazy var settingsButtomItem: UIBarButtonItem = {
        
        let button = UIBarButtonItem(image: UIImage(named: "ic_settings_white"), style: .plain, target: self, action: #selector(handleShowSettings))
        
        return button
    }()
    
    func handleShowSettings() {
    
        // Open the settings controller.
        let settingsController = SettingsController()
        // Pass along the profile pic.
        settingsController.userProfileImage = profileImageView.image
        
        navigationController?.pushViewController(settingsController, animated: true)
    }
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "map_icon")
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 100
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let nameLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Name"
        label.textColor = WHITE_COLOR
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var eventsTableView: UITableView = {
       
        let tableView = UITableView()
        tableView.backgroundColor = DARK_BLUE_COLOR
        tableView.separatorColor = LIGHT_BLUE_COLOR
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    // MARK: - Global Variables
    
    var user: User? {
        didSet {
            
            // Set the user's details.
            setUserValues()
            
            // Grab the events under the user.
            fetchUserEvents()
        }
    }
    
    var userEvents = [Event]()
    var userEventsDictionary = [String: Event]()
    
    var eventCellId = "eventCell"
    
    var timer: Timer?
    
    // MARK: - View Configuration

    fileprivate func navigationBarCustomization() {
        
        // Set the title of the navigationItem.
        navigationItem.title = "Profile"
        
        // Set the color of the navigationItem to white.
        let colorAttribute = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = colorAttribute
        
        // Change the tint color to white.
        navigationController?.navigationBar.tintColor = WHITE_COLOR
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarCustomization()
        
        // Change the backgroundColor.
        view.backgroundColor = DARK_BLUE_COLOR
        
        // Add the UI components.
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(eventsTableView)
        
        // Set up the constraints.
        setUpProfileImageView()
        setUpNameLabel()
        setUpEventsTableView()
    }
    
    func setUpProfileImageView() {
    
        // Add X, Y, width, and height constraints to the profileImageView.
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setUpNameLabel() {
        
        // Add X and Y constraints. to the nameLabel.
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 25).isActive = true
    }
    
    func setUpEventsTableView() {
        
        // Add X, Y, width, and height constraints to the eventsTableView.
        eventsTableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 50).isActive = true
        eventsTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        eventsTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        eventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Register a cell classe in the eventsTableView.
        eventsTableView.register(EventCell.self, forCellReuseIdentifier: eventCellId)
        
        // Hide empty cells in the eventsTableView.
        eventsTableView.tableFooterView = UIView()
    }
    
    func setUserValues() {
        
        if let profileImageUrl = user?.profileImageUrl, let name = user?.name {
            
            profileImageView.setImageWithKingfisher(url: profileImageUrl)
            nameLabel.text = name
        }
        
        // Add the bar button items if this is the current user's profile.
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let userKey = user?.key {
            
            if uid == userKey {
                
                navigationItem.rightBarButtonItems = [settingsButtomItem]
            }
        }
    }
    
    func fetchUserEvents() {
        
        if let userKey = user?.key {
        
            let userEventsRef = DataService.ds.REF_USERS.child(userKey).child("events")
            
                // Detect added events.
                userEventsRef.observe(.childAdded, with: { (snapshot) in
                    
                    let eventKey = snapshot.key
                    self.fetchEvent(withKey: eventKey, toDelete: false)
                })
                
                // Detect removed events.
                userEventsRef.observe(.childRemoved, with: { (snapshot) in
                    
                    // Remove the deleted event from the userEvents dictionary and the user's calendar and reload the table.
                    self.userEventsDictionary.removeValue(forKey: snapshot.key)
                    let eventKey = snapshot.key
                    self.fetchEvent(withKey: eventKey, toDelete: true)
                    self.attemptReloadOfTable()
                })
            }
    }
    
    func fetchEvent(withKey: String, toDelete: Bool) {
        
        let eventRef = DataService.ds.REF_EVENTS.child(withKey)
        
        eventRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let eventData = snapshot.value as? [String: AnyObject] {
                
                let key = snapshot.key
                
                // Use the data received from Firebase to create a new Event object.
                let event = Event(eventKey: key, eventData: eventData)
                
                if toDelete {
                    
                    EventService.sharedInstance.syncToCalendar(add: false, event: event)
                    
                } else {
                    
                    // Add the event to the userEvents dictionary.
                    self.userEventsDictionary[key] = event
                    
                    self.attemptReloadOfTable()
                }
            }
        })
    }
    
    fileprivate func attemptReloadOfTable() {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        
        self.userEvents = Array(self.userEventsDictionary.values)
        
        // Sort by upcoming.
        self.userEvents.sort(by: { (event1, event2) -> Bool in

            let event1TimeStart = event1.timeStart.toDate()
            let event2TimeStart = event2.timeStart.toDate()
            return event1TimeStart < event2TimeStart
        })
        
        DispatchQueue.main.async(execute: {
            
            self.eventsTableView.reloadData()
        })
    }
    
    // MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userEvents.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Upcoming events"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header = view as! UITableViewHeaderFooterView
        header.backgroundColor = UIColor.clear
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        header.textLabel?.textColor = WHITE_COLOR
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventCell = tableView.dequeueReusableCell(withIdentifier: eventCellId, for: indexPath) as! EventCell
        
        let event = userEvents[indexPath.row]
        
        eventCell.configureCell(event: event)
        
        return eventCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let event = userEvents[indexPath.row]
        
        // Grab the event details controller.
        let eventController = EventController()
        eventController.event = event
        
        // Open the EventController.
        navigationController?.pushViewController(eventController, animated: true)
    }
}
