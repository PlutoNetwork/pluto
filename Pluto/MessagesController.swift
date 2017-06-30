//
//  MessagesController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/29/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MessagesController: UICollectionViewController {
    
    // MARK: - UI Components
    
    let seperatorLineView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let inputContainerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var sendButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(ORANGE_COLOR, for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    func handleSend() {
        
        // We need to generate a list of items in the Firebase database so we can have multiple messages.
        // We can do this by creating a new childRef every time the send button is tapped.
        
        if let messageText = inputTextField.text {
            
            if messageText != "" {
                
                // We need to send the message to the event.
                let toId = event?.key
                
                // Use the current user's id as the fromId to show the message sender.
                guard let uid = Auth.auth().currentUser?.uid else {
                    
                    print("ERROR: could not get user ID.")
                    return
                }
                
                let fromId = uid
                
                // We should get a timestamp too, so we know when the message was sent out.
                let timeStamp: NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
                
                let values = ["text": messageText, "toId": toId!, "fromId": fromId, "timeStamp": timeStamp] as [String : Any]
                
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
                    DataService.ds.REF_EVENT_MESSAGES.child(toId!).updateChildValues([messageId: 1])
                })
            }
        }
    }
    
    lazy var inputTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Enter message"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
       
        return textField
    }()
    
    // MARK: - Global Variables
    
    var event: Event?
    
    // MARK: - View Configuration
    
    fileprivate func navigationBarCustomization() {
        
        // Create a title view to show in the middle of the navigation bar.
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        
        // Create a container view that fixes spacing issues.
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.addSubview(containerView)
            
        // Create an image view to show the event's image.
        let eventImageView = UIImageView()
        eventImageView.contentMode = .scaleAspectFill
        
        // Round the eventImageView.
        eventImageView.layer.cornerRadius = 20
        eventImageView.layer.masksToBounds = true
        
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the image using the Kingfisher library.
        if let eventImageUrl = event?.imageUrl {
            
            let url = URL(string: eventImageUrl)
            eventImageView.kf.setImage(with: url)
            containerView.addSubview(eventImageView)
        }
        
        // Add X, Y, width, and height constraints to the eventImageView.
        eventImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        eventImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Create a text label that shows the event's title.
        let eventTitleLabel = UILabel()
        eventTitleLabel.textColor = UIColor.white
        
        eventTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the title.
        if let eventTitle = event?.title {
            
            eventTitleLabel.text = eventTitle
            containerView.addSubview(eventTitleLabel)
        }
        
        // Add X, Y, width, and height constraints to the eventTitleLabel.
        // - TODO: Fix spacing for long event titles.
        eventTitleLabel.leftAnchor.constraint(equalTo: eventImageView.rightAnchor, constant: 8).isActive = true
        eventTitleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        eventTitleLabel.centerYAnchor.constraint(equalTo: eventImageView.centerYAnchor).isActive = true
        eventTitleLabel.heightAnchor.constraint(equalTo: eventImageView.heightAnchor).isActive = true
        
        // Add X and Y to the containerView.
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        navigationItem.titleView = titleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarCustomization()
        
        // Change the background color of the background.
        collectionView?.backgroundColor = UIColor.white
        
        // Add the UI components.
        view.addSubview(inputContainerView)
        
        // Set up the constraints for the UI components.
        setUpInputContainerView()
    }
    
    func setUpInputContainerView() {
        
        // Add X, Y, width, and height constraints to the inputContainerView.
        inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        inputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Add UI components to the inputContainerView.
        inputContainerView.addSubview(seperatorLineView)
        inputContainerView.addSubview(sendButton)
        inputContainerView.addSubview(inputTextField)
        
        // Add X, Y, width, and height constraints to the seperatorLineView.
        seperatorLineView.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add X, Y, width, and height constraints to the sendButton.
        sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor).isActive = true
        
        // Add X, Y, width, and height constraints to the inputTextField.
        inputTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 8).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor).isActive = true
    }
}

extension MessagesController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSend()
        
        return true
    }
}
