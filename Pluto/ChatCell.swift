//
//  ChatCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatCell: BaseCollectionViewCell, UITableViewDelegate, UITableViewDataSource {
 
    // MARK: - UI Components
    
    lazy var chatsTableView: UITableView = {
        
        let tableView = UITableView()
        tableView.backgroundColor = DARK_BLUE_COLOR
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        
        return tableView
    }()
    
    // MARK: - Global Variables
    
    var userEvents = [Event]()
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    let chatCellId = "chatCell"
    
    // MARK: - View Configuration
    
    override func setUpViews() {
        super.setUpViews()
        
        // Change the background color of the cell.
        backgroundColor = .clear
        
        // Add the UI components.
        addSubview(chatsTableView)
        
        // Set up constraints for the UI components.
        setUpChatsTableView()
        
        DispatchQueue.global(qos: .background).async {
            
            UserService.sharedInstance.fetchUserEvents { (userEvents) in
                
                self.userEvents.removeAll()
                
                self.userEvents = userEvents
                
                DispatchQueue.main.async {
                 
                    self.chatsTableView.reloadData()
                }
            }
        }
    }
    
    func setUpChatsTableView() {
        
        // Add X, Y, width, and height constraints to the chatsTableView.
        chatsTableView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        chatsTableView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        chatsTableView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        chatsTableView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        // Register a cell classe in the chatsTableView.
        chatsTableView.register(EventChatCell.self, forCellReuseIdentifier: chatCellId)
        
        // Hide empty cells in the chatsTableView.
        chatsTableView.tableFooterView = UIView()
        
        // Change the color of the seperators.
        chatsTableView.separatorColor = LIGHT_BLUE_COLOR
    }
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userEvents.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let eventChatCell = tableView.dequeueReusableCell(withIdentifier: chatCellId, for: indexPath) as! EventChatCell
        
        // Turn off the hideous highlighting that happens when a user taps on a cell.
        eventChatCell.selectionStyle = .none
        
        // Grab the event from the userEvents array.
        let event = userEvents[indexPath.row]
        
        // Set the eventChatCell's text label to the event's title.
        eventChatCell.textLabel?.text = event.title
        
        // Set the cell's image.
        let image = event.image
        eventChatCell.eventImageView.image = UIImage(named: image)
        
        DispatchQueue.global(qos: .background).async {
            
            MessageService.sharedInstance.observeEventMessages(event: event) { (message) in
                
                DispatchQueue.main.async {
                    
                    // Set the eventChatCell's detail text label to the latest message.
                    eventChatCell.detailTextLabel?.text = message.text
                    
                    // Set the eventChatCell's time label to the latest message's timeStamp.
                    if let seconds = message.timeStamp?.doubleValue {
                        
                        let timeStampDate = Date(timeIntervalSince1970: seconds)
                        
                        // Format the time stamp.
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "hh:mm a"
                        
                        eventChatCell.timeLabel.text = dateFormatter.string(from: timeStampDate)
                    }
                    
                }
            }
        }
    
        return eventChatCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let event = userEvents[indexPath.row]
        
        // Pass in the event to the MessagesController.
        let messagesController = MessagesController(collectionViewLayout: UICollectionViewFlowLayout())
        messagesController.event = event
        
        // Open the MessagesController.
        mainController?.navigationController?.pushViewController(messagesController, animated: true)
    }
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        
        if let index = index(of: object) {
            
            remove(at: index)
        }
    }
}
