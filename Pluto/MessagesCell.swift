//
//  MessagesCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MessagesCell: BaseCollectionViewCell, UITableViewDelegate, UITableViewDataSource {
 
    // MARK: - UI Components
    
    lazy var messagesTableView: UITableView = {
        
        let tableView = UITableView()
        tableView.backgroundColor = DARK_BLUE_COLOR
        tableView.separatorColor = LIGHT_BLUE_COLOR
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    // MARK: - Global Variables
    
    var userEvents = [Event]()
    var userEventsDictionary = [String: Event]()
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    let messageBubbleCellId = "messageBubbleCell"
    
    var timer: Timer?
    
    // MARK: - View Configuration
    
    override func setUpViews() {
        super.setUpViews()
        
        // Change the background color of the cell.
        backgroundColor = .clear
        
        // Add the UI components.
        addSubview(messagesTableView)
        
        // Set up constraints for the UI components.
        setUpMessagesTableView()
        
        // Grab the events under the user.
        fetchUserEvents()
    }
    
    func setUpMessagesTableView() {
        
        // Add X, Y, width, and height constraints to the messagesTableView.
        messagesTableView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        messagesTableView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        messagesTableView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        messagesTableView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        // Register a cell classe in the messagesTableView.
        messagesTableView.register(EventMessagesPreviewCell.self, forCellReuseIdentifier: messageBubbleCellId)
        
        // Hide empty cells in the messagesTableView.
        messagesTableView.tableFooterView = UIView()
    }
    
    func fetchUserEvents() {
        
        // Clear the messages.
        messages.removeAll()
        messagesDictionary.removeAll()
        
        let userEventsRef = DataService.ds.REF_CURRENT_USER_EVENTS
        
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
                    
                    // Grab the event's messages.
                    self.observeEventMessages(event: event)
                }
            }
        })
    }
    
    func observeEventMessages(event: Event) {
        
        let eventMessagesRef = DataService.ds.REF_EVENT_MESSAGES.child(event.key)
        
        eventMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageKey = snapshot.key
            
            // Find all the messages under the current event.
            self.fetchMessageData(withMessageId: messageKey)
        })
    }
    
    func fetchMessageData(withMessageId: String) {
        
        // Grab the message's data from Firebase.
        DataService.ds.REF_MESSAGES.child(withMessageId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let messageData = snapshot.value as? [String: AnyObject] {
                
                let message = Message(messageData: messageData)
                
                if let toId = message.toId {
                    
                    self.messagesDictionary[toId] = message
                }
                
                self.attemptReloadOfTable()
            }
        })
    }
    
    fileprivate func attemptReloadOfTable() {
                
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        
        self.userEvents = Array(self.userEventsDictionary.values)
        
//        self.userEvents.sort(by: { (event1, event2) -> Bool in
//            
//            return (event1.timeStamp?.int32Value)! > (message2.timeStamp?.int32Value)!
//        })
        
        self.messages = Array(self.messagesDictionary.values)
        
//        // Sort the messages array so the latest will be on top.
//        self.messages.sort(by: { (message1, message2) -> Bool in
//            
//            return (message1.timeStamp?.int32Value)! > (message2.timeStamp?.int32Value)!
//        })
        
        DispatchQueue.main.async(execute: {
            
            self.messagesTableView.reloadData()
        })
    }
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userEvents.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventMessagesPreviewCell = tableView.dequeueReusableCell(withIdentifier: messageBubbleCellId, for: indexPath) as! EventMessagesPreviewCell
        
        // Grab the event from the userEvents array.
        let event = userEvents[indexPath.row]
        
        // Grab the message from the messages array.
        
        if messages.count > 0  {
        
            let message = messages[indexPath.row]
            eventMessagesPreviewCell.configureCell(event: event, message: message)
        }
        
        return eventMessagesPreviewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let event = userEvents[indexPath.row]
        
        // Pass in the event to the MessageLogController.
        let messageLogController = MessageLogController(collectionViewLayout: UICollectionViewFlowLayout())
        messageLogController.messagesCell = self
        messageLogController.event = event
        
        // Open the MessageLogController.
        mainController?.navigationController?.pushViewController(messageLogController, animated: true)
    }
}
