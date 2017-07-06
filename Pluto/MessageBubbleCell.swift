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
    
    func configureCell(message: Message) {
        
        // Set the messageBubbleCell's textView text as the message content.
        messageTextView.text = message.text
        profileImageView.image = nil
        
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
                
                // Download the profile image of the message sender.
                self.fetchUserProfileImage(withKey: messageFromId)
                
                // Since the message is from someone else, make the bubbleView gray and the text black.
                bubbleView.backgroundColor = LIGHT_BLUE_COLOR
                
                // Move the bubble to the left.
                bubbleRightAnchor?.isActive = false
                bubbleLeftAnchor?.isActive = true
            }
        }
        
        // If there was an image in the message, set the image.
        if let messageImageUrl = message.imageUrl {
            
            // Set the image using the Kingfisher library.
            messageImageView.setImageWithKingfisher(url: messageImageUrl)
            messageImageView.isHidden = false
            bubbleView.backgroundColor = UIColor.clear
            
        } else {
            
            messageImageView.isHidden = true
        }
    }
    
    func fetchUserProfileImage(withKey: String) {
        
        print("About to fetch pic")
        
        // Go into the Firebase database and retrieve the given user's data.
        DataService.ds.REF_USERS.child(withKey).observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("Fetching...")
            
            if let userData = snapshot.value as? [String: AnyObject] {
                
                print("Found user \(userData["name"]!)")
                
                if let profileImageUrl = userData["profileImageUrl"] as? String {
                    
                    print("Setting \(userData["name"]!)'s pic.")
                    self.profileImageView.setImageWithKingfisher(url: profileImageUrl)
                }
            }
        })
        
        print("****")
    }
}
