//
//  Message.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/29/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit

class Message: NSObject {

    var toId: String?
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    
    init(toId: String, fromId: String, text: String, timeStamp: NSNumber) {
        
        self.toId = toId
        self.fromId = fromId
        self.text = text
        self.timeStamp = timeStamp
    }
    
    init(messageData: Dictionary<String, AnyObject>) {
        
        if let toId = messageData["toId"] as? String {
            
            self.toId = toId
        }
        
        if let fromId = messageData["fromId"] as? String {
            
            self.fromId = fromId
        }
        
        if let text = messageData["text"] as? String {
            
            self.text = text
        }
        
        if let timeStamp = messageData["timeStamp"] as? NSNumber {
            
            self.timeStamp = timeStamp
        }
    }

}
