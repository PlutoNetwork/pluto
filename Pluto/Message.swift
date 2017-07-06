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
    var fromIdProfileImageUrl: String?
    var text: String?
    var timeStamp: NSNumber?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    init(toId: String, fromId: String, fromIdProfileImageUrl: String, text: String, timeStamp: NSNumber, imageUrl: String, imageWidth: NSNumber, imageHeight: NSNumber) {
        
        self.toId = toId
        self.fromId = fromId
        self.fromIdProfileImageUrl = fromIdProfileImageUrl
        self.text = text
        self.timeStamp = timeStamp
        self.imageUrl = imageUrl
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
    }
    
    init(messageData: Dictionary<String, AnyObject>) {
        super.init()
        
        if let toId = messageData["toId"] as? String {
            
            self.toId = toId
        }
        
        if let fromId = messageData["fromId"] as? String {
            
            self.fromId = fromId
        }
        
        if let fromIdProfileImageUrl = messageData["fromIdProfileImageUrl"] as? String {
            
            self.fromIdProfileImageUrl = fromIdProfileImageUrl
        }
        
        if let text = messageData["text"] as? String {
            
            self.text = text
        }
        
        if let timeStamp = messageData["timeStamp"] as? NSNumber {
            
            self.timeStamp = timeStamp
        }
        
        if let imageUrl = messageData["imageUrl"] as? String {
            
            self.imageUrl = imageUrl
        }
        
        if let imageWidth = messageData["imageWidth"] as? NSNumber {
            
            self.imageWidth = imageWidth
        }
        
        if let imageHeight = messageData["imageHeight"] as? NSNumber {
            
            self.imageHeight = imageHeight
        }
    }
}
