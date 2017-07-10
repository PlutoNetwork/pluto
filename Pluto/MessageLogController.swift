//
//  MessageLogController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/29/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class MessageLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UI Components
    
    lazy var eventDetailsButtonItem: UIBarButtonItem = {
        
        let button = UIBarButtonItem(image: UIImage(named: "ic_dehaze_white"), style: .plain, target: self, action: #selector(handleShowEventDetails))
        
        return button
    }()
    
    func handleShowEventDetails() {
        
        // Pass the event to the EventController.
        let eventController = EventController()
        eventController.event = event
        
        // Open the EventController.
        navigationController?.pushViewController(eventController, animated: true)
    }
    
    // MARK: - Global Variables
    
    var messagesCell: MessagesCell?
    
    var event: Event? {
        didSet {
            
            navigationItem.title = event?.title
            observeMessages()
        }
    }
    
    var messages = [Message]()
    var userProfileImageUrls = [String]()
    let messageBubbleCellId = "messageBubbleCellId"
    
    // MARK: - View Configuration
    
    fileprivate func navigationBarCustomization() {
        
        // Set the color of the navigationItem to white.
        let colorAttribute = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = colorAttribute
        
        // Change the tint color to white.
        navigationController?.navigationBar.tintColor = WHITE_COLOR
        
        // Add the bar button items.
        navigationItem.rightBarButtonItems = [eventDetailsButtonItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarCustomization()
        
        // Change the background color of the background.
        collectionView?.backgroundColor = HIGHLIGHT_COLOR
        
        // Register a cell class for the collectionView.
        collectionView?.register(MessageBubbleCell.self, forCellWithReuseIdentifier: messageBubbleCellId)
        
        // Add some space to the top and bottom of the collectionView.
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        // Make the collectionView draggable.
        collectionView?.alwaysBounceVertical = true
        
        // The following line will allow the user to interact with the keyboard.
        collectionView?.keyboardDismissMode = .interactive
    
        // Set up the keyboard voodoo.
        setUpKeyboardObservers()
    }
    
    func observeMessages() {
        
        if let eventKey = event?.key {
            
            DataService.ds.REF_EVENT_MESSAGES.child(eventKey).observe(.childAdded, with: { (snapshot) in
                
                let messageKey = snapshot.key
                
                // Find all the messages under the current event.
                self.fetchMessageData(withMessageId: messageKey)
            })
        }
    }
    
    func fetchMessageData(withMessageId: String) {
        
        // Grab the message's data from Firebase.
        DataService.ds.REF_MESSAGES.child(withMessageId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let messageData = snapshot.value as? [String: AnyObject] {
                
                let message = Message(messageData: messageData)
        
                // Add the message to the array of messages.
                self.messages.append(message)
                
                DispatchQueue.main.async(execute: {
                    
                    self.collectionView?.reloadData()
                    
                    // Scroll the latest message.
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
                })
            }
        })
    }
    
    func handleSend() {
        
        // We need to generate a list of items in the Firebase database so we can have multiple messages.
        // We can do this by creating a new childRef every time the send button is tapped.
        if let messageText = messageInputAccessoryView.inputTextField.text {
            
            // Make sure messageText isn't empty.
            if messageText != "" {
                
                // Clear the input text field.
                self.messageInputAccessoryView.inputTextField.text = nil
                
                let properties: [String: AnyObject] = ["text": messageText as AnyObject]
                self.sendMessageWith(properties: properties)
            }
        }
    }
    
    func sendMessageWith(properties: [String: AnyObject]) {
        
        // We need to send the message to the event.
        let toId = (event?.key)!
        
        // Use the current user's id as the fromId to show the message sender.
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        let fromId = uid
        
        // We should get a timestamp too, so we know when the message was sent out.
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        // Grab the sender's profile image url.
        DataService.ds.REF_USERS.child(fromId).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let userData = snapshot.value as? [String: AnyObject] {
                
                if let profileImageUrl = userData["profileImageUrl"] as? String {
                    
                    var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "fromIdProfileImageUrl": profileImageUrl as AnyObject, "timeStamp": timeStamp as AnyObject]
                    
                    // Append the parameter dictionary to the values.
                    properties.forEach({values[$0] = $1})
                    
                    MessageService.sharedInstance.updateMessages(toId: toId, fromId: fromId, values: values)
                }
            }
        })
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
    
    lazy var messageInputAccessoryView: MessageInputContainerView = {
        
        let messageInputContainerView = MessageInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        messageInputContainerView.messageLogController = self
        
        return messageInputContainerView
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
    
    func setUpKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(moveMessagesUp), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    func moveMessagesUp() {
        
        // Move the latest up to show it above the keyboard.
        if messages.count > 0 {
        
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    // MARK: - Collection View Functions
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Provide a default height value.
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        // We need the height of each cell matching the text content size or the image size.
        if let text = message.text {
            
            height = estimateFrameForText(text: text).height + 20 // Added 20 for padding on the bottom.
            
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            
            // heightofRect1 / widthOfRect1 = heightOfRect2 / widthOfRect2
            // heightofRect1 = heightofRect2 / widthOfRect2 * widthOfRect1

            height = CGFloat(imageHeight / imageWidth * 200) // The 200 is the default width set in the sizeForItem function.
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Set the initial state of the cell.
        cell.alpha = 0
        
        // Animate to change the final state.
        UIView.animate(withDuration: 0.5) {
            
            cell.alpha = 1.0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let messageBubbleCell = collectionView.dequeueReusableCell(withReuseIdentifier: messageBubbleCellId, for: indexPath) as! MessageBubbleCell
        
        messageBubbleCell.messageLogController = self
        
        let message = messages[indexPath.item]
        
        // Set the messageBubbleCell's textView text as the message content.
        messageBubbleCell.messageTextView.text = message.text
        
        setUpMessageBubbleCell(messageBubbleCell, message: message)
        
        // Set the width of the bubbleView to match the text content width or the image width.
        if let text = message.text {
            
            messageBubbleCell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32 // Added the extra space b/c of cut off text problem
            messageBubbleCell.messageTextView.isHidden = false
            
        } else if message.imageUrl != nil {
            
            messageBubbleCell.bubbleWidthAnchor?.constant = 200
            messageBubbleCell.messageTextView.isHidden = true
        }
        
        return messageBubbleCell
    }
    
    fileprivate func setUpMessageBubbleCell(_ cell: MessageBubbleCell, message: Message) {
        
        if let profileImageUrl = message.fromIdProfileImageUrl {
            
            cell.profileImageView.setImageWithKingfisher(url: profileImageUrl)
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            
            print("ERROR: could not get user ID.")
            return
        }
        
        // We need to check which user the message is from so we can sort gray and orange bubbles.
        
        if let messageFromId = message.fromId {
            
            if messageFromId == uid {
                
                // Since the message is from the user, make the bubbleView orange and the text white.
                cell.bubbleView.backgroundColor = DARK_BLUE_COLOR
                
                // Hide the profileImageView since the current user is the sender.
                cell.profileImageView.isHidden = true
                
                // Move the bubble to the right.
                cell.bubbleRightAnchor?.isActive = true
                cell.bubbleLeftAnchor?.isActive = false
                
            } else {
                
                // Since the message is from someone else, make the bubbleView gray and the text black.
                cell.bubbleView.backgroundColor = LIGHT_BLUE_COLOR
                
                // Show the profileImageView since the current user is the sender.
                cell.profileImageView.isHidden = false
                
                // Move the bubble to the left.
                cell.bubbleRightAnchor?.isActive = false
                cell.bubbleLeftAnchor?.isActive = true
            }
        }
        
        // If there was an image in the message, set the image.
        if let messageImageUrl = message.imageUrl {
            
            // Set the image using the Kingfisher library.
            cell.messageImageView.setImageWithKingfisher(url: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            
        } else {
            
            cell.messageImageView.isHidden = true
        }

    }
}
