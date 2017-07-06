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
    
    func updateMessages(toId: String, fromId: String, values: [String: Any]) {
        
        let messageChildRef = DataService.ds.REF_MESSAGES.childByAutoId()
        
        messageChildRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
            
            if error != nil {
                
                print("ERROR: there was an error saving the message to Firebase. Details: \(error.debugDescription)")
                return
            }
            
            // Add data to the event messages node as well.
            // See "fanning-out."
            let messageId = messageChildRef.key
            
            DataService.ds.REF_EVENT_MESSAGES.child(toId).updateChildValues([messageId: 1])
        })
    }
}
