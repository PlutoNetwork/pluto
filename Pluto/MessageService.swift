//
//  MessageService.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/29/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

struct MessageService {
    
    static let sharedInstance = MessageService()
    
    func observeEventMessages(event: Event, completion: @escaping (Message) -> ()) {
        
        var messages = [Message]()
        var messagesDictionary = [String: Message]()
        
        DataService.ds.REF_EVENT_MESSAGES.child(event.key).observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            // Find all the messages under the current event.
            DataService.ds.REF_MESSAGES.child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let messageData = snapshot.value as? [String: AnyObject] {
                    
                    let message = Message(messageData: messageData)
                    
                    if let toId = message.toId {
                        
                        messagesDictionary[toId] = message
                        
                        messages = Array(messagesDictionary.values)
                        
                        // Sort the messages array so the latest will be on top.
                        messages.sort(by: { (message1, message2) -> Bool in
                            
                            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
                        })
                    }
                    
                    completion(messages[0])
                }
            })
        })
    }
    
    func observeMessages(event: Event, completion: @escaping ([Message]) -> ()) {
        
        var messages = [Message]()
        
        DataService.ds.REF_EVENT_MESSAGES.child(event.key).observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            // Find all the messages under the current event.
            DataService.ds.REF_MESSAGES.child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let messageData = snapshot.value as? [String: AnyObject] {
                    
                    let message = Message(messageData: messageData)
                    
                    // Add the message to the array of messages to send back.
                    messages.append(message)
                    
                    completion(messages)
                }
            })
        })
    }
    
    func updateMessages(toId: String, fromId: String, values: [String: Any], completion: @escaping () -> ()) {
        
        let messageChildRef = DataService.ds.REF_MESSAGES.childByAutoId()
        
        messageChildRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
            
            if error != nil {
                
                print("ERROR: there was an error saving the message to Firebase. Details: \(error.debugDescription)")
                return
            }
            
            // Add data to the event messages node as well.
            // See "fanning-out."
            let messageId = messageChildRef.key
            DataService.ds.REF_EVENT_MESSAGES.child(fromId).updateChildValues([messageId: 1])
            
            // We need to save the same values for the user sending the message.
            DataService.ds.REF_EVENT_MESSAGES.child(toId).updateChildValues([messageId: 1])
            
            completion()
        })
    }
}
