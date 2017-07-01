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
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override func setUpViews() {
        super.setUpViews()
        
        // Add the UI components to the cell.
        addSubview(bubbleView)
        addSubview(messageTextView)
        addSubview(profileImageView)
        
        // Set up the constraints for the UI components.
        setUpBubbleView()
        setUpMessageTextView()
        setUpProfileImageView()
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
        bubbleLeftAnchor?.isActive = false // By default, the bubble will be on the right. Change in MessagesController.
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
    
    func setUpProfileImageView() {
        
        // Add X, Y, width, and height constraints to the profileImageView.
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    func configureCell(message: Message) {
        
        // Set the messageBubbleCell's textView text as the message content.
        messageTextView.text = message.text
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        // We need to check which user the message is from so we can sort gray and orange bubbles.
        
        if let messageFromId = message.fromId {
            
            if messageFromId == uid {
                
                // Since the message is from the user, make the bubbleView orange and the text white.
                bubbleView.backgroundColor = DARK_BLUE_COLOR
                
                // Move the bubble to the right.
                bubbleRightAnchor?.isActive = true
                bubbleLeftAnchor?.isActive = false
                
                // Hide the profileImageView since the current user is the sender.
                profileImageView.isHidden = true
                
            } else {
                
                // Set the profile images of the fromUsers.
                DispatchQueue.global(qos: .background).async {
                    
                    if let messageFromId = message.fromId {
                        
                        UserService.sharedInstance.fetchUserProfileImage(withKey: messageFromId, completion: { (profileImageUrl) in
                            
                            DispatchQueue.main.async {
                                
                                let url = URL(string: profileImageUrl)
                                self.profileImageView.kf.setImage(with: url)
                            }
                        })
                    }
                }
                
                // Since the message is from someone else, make the bubbleView gray and the text black.
                bubbleView.backgroundColor = LIGHT_BLUE_COLOR
                
                // Move the bubble to the left.
                bubbleRightAnchor?.isActive = false
                bubbleLeftAnchor?.isActive = true
            }
        }
    }
}
