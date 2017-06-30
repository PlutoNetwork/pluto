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

class MessagesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UI Components
    
    let seperatorLineView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var sendButton: UIButton = {
        
        // - TODO: Set the button color to gray and un-interactable when the field is blank.
        
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
                    
                    // Clear the inputTextField.
                    self.inputTextField.text = nil
                    
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
    var messages = [Message]()
    let messageCellId = "messageCellId"
    
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
        
        // Register a cell class for the collectionView.
        collectionView?.register(MessageBubbleCell.self, forCellWithReuseIdentifier: messageCellId)
        
        // Make the collectionView draggable.
        collectionView?.alwaysBounceVertical = true
        
        // Add some space to the top and bottom of the collectionView.
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        // The following line will allow the user to interact with the keyboard.
        collectionView?.keyboardDismissMode = .interactive
        
        DispatchQueue.global(qos: .background).async {
        
            MessageService.sharedInstance.observeMessages(event: self.event!) { (messages) in
                
                self.messages = messages
                
                DispatchQueue.main.async {
                    
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // Fixes the layout and corrects it when the user rotates the device.
        // Doesn't really matter because the app is Portrait-only, but... y'know.
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Not having the following line will result in a memory leak.
        NotificationCenter.default.removeObserver(self)
    }
    
    lazy var messageInputAccessoryView: UIView = {
        
        let inputContainerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add UI components to the inputContainerView.
        inputContainerView.addSubview(self.seperatorLineView)
        inputContainerView.addSubview(self.sendButton)
        inputContainerView.addSubview(self.inputTextField)
        
        // Add X, Y, width, and height constraints to the seperatorLineView.
        self.seperatorLineView.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        self.seperatorLineView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        self.seperatorLineView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        self.seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add X, Y, width, and height constraints to the sendButton.
        self.sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor).isActive = true
        self.sendButton.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.sendButton.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor).isActive = true
        
        // Add X, Y, width, and height constraints to the inputTextField.
        self.inputTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor).isActive = true
        self.inputTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor).isActive = true
        
        return inputContainerView
    }()
    
    // The following overrides will allow us to move the inputContainerView with the keyboard.
    
    override var inputAccessoryView: UIView? {
        get {
            
            return messageInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            
            return true
        }
    }
    
    // MARK: - Collection View Functions
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Provide a default height value.
        var height: CGFloat = 80
        
        // We need the height of each cell matching the text content size.
        if let text = messages[indexPath.item].text {
            
            height = estimateFrameForText(text: text).height + 20 // Added 20 for padding on the bottom.
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let messageBubbleCell = collectionView.dequeueReusableCell(withReuseIdentifier: messageCellId, for: indexPath) as! MessageBubbleCell
        
        let message = messages[indexPath.item]
        
        // Set the messageBubbleCell's textView text as the message content.
        messageBubbleCell.messageTextView.text = message.text
        
        // Set the width of the bubbleView to match the text content width.
        if let text = message.text {
            
            messageBubbleCell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32 // Added the extra space b/c of cut off text problem
        }
        
        return messageBubbleCell
    }
}

extension MessagesController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Dismiss the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
}
