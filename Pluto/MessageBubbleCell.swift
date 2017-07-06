//
//  MessageBubbleCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/30/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MessageBubbleCell: BaseCollectionViewCell {
    
    var messageLogController: MessageLogController?
    
    let bubbleView: UIView = {
        
        let view = UIView()
        view.backgroundColor = HIGHLIGHT_COLOR
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let messageTextView: UITextView = {
        
        let textView = UITextView()
        textView.text = "Message goes here."
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = WHITE_COLOR
        textView.backgroundColor = UIColor.clear // Need this so we can see the bubble view.
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()

    lazy var messageImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageZoomInTap(tapGesture:))))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    func handleImageZoomInTap(tapGesture: UITapGestureRecognizer) {
        
        // Dismiss the keyboard.
        messageLogController?.messageInputAccessoryView.inputTextField.resignFirstResponder()
        
        if let tappedImageView = tapGesture.view as? UIImageView {
        
            messageLogController?.performZoomInForStartingImageView(startingImageView: tappedImageView)
        }
    }
    
    override func setUpViews() {
        super.setUpViews()
        
        // Add the UI components to the cell.
        addSubview(bubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        
        // Set up the constraints for the UI components.
        setUpProfileImageView()
        setUpBubbleView()
        setUpMessageTextView()
    }
    
    // We need these here so we can access them elsewhere.
    var bubbleWidthAnchor: NSLayoutConstraint?
    var bubbleRightAnchor: NSLayoutConstraint?
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    func setUpBubbleView() {
        
        // Add X, Y, width, and height constraints to the bubbleView.
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnchor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        bubbleView.addSubview(messageImageView)
        
        // Add X, Y, width, and height constraints to the messageImageView.
        messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
        messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
        messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
    }
    
    func setUpMessageTextView() {
        
        // Add X, Y, width, and height constraints to the messageTextView.
        messageTextView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        messageTextView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageTextView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageTextView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
    
    func setUpProfileImageView() {
        
        // Add X, Y, width, and height constraints to the profileImageView.
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
}
