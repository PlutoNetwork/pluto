//
//  MessageBubbleCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/30/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit

class MessageBubbleCell: BaseCollectionViewCell {
    
    let bubbleView: UIView = {
        
        let view = UIView()
        view.backgroundColor = ORANGE_COLOR
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let messageTextView: UITextView = {
        
        let textView = UITextView()
        textView.text = "Message goes here."
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.clear // Need this so we can see the bubble view.
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    override func setUpViews() {
        super.setUpViews()
        
        // Add the UI components to the cell.
        addSubview(bubbleView)
        addSubview(messageTextView)
        
        // Set up the constraints for the UI components.
        setUpBubbleView()
        setUpMessageTextView()
    }
    
    // We need this here so we can access it elsewhere.
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    func setUpBubbleView() {
        
        // Add X, Y, width, and height constraints to the bubbleView.
        bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func setUpMessageTextView() {
        
        // Add X, Y, width, and height constraints to the messageTextView.
        messageTextView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        messageTextView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageTextView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageTextView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
}
