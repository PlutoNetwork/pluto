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
    
    // MARK: - Global Variables
    
    var event: Event?
    var messages = [Message]()
    var userProfileImageUrls = [String]()
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
        
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the image.
        if let eventImage = event?.image {
            
            eventImageView.image = UIImage(named: eventImage)
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
        collectionView?.backgroundColor = HIGHLIGHT_COLOR
        
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
                    
                    // Move the messages up so the user can see the latest ones.
                    self.moveMessagesUp()
                }
            }
        }
        
        // Set up the keyboard voodoo.
        setUpKeyboardObservers()
    }
    
    func handleSend() {
        
        // We need to generate a list of items in the Firebase database so we can have multiple messages.
        // We can do this by creating a new childRef every time the send button is tapped.
        
        if let messageText = messageInputAccessoryView.inputTextField.text {
            
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
                
                let values = ["text": messageText, "toId": toId!, "fromId": fromId, "timeStamp": timeStamp] as [String: Any]
                
                DispatchQueue.global(qos: .background).async {
                    
                    MessageService.sharedInstance.updateMessages(toId: toId!, fromId: fromId, values: values, completion: {
                        
                        DispatchQueue.main.async {
                            
                            // Clear the inputTextField in the inputView.
                            self.messageInputAccessoryView.inputTextField.text = nil
                        }
                    })
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
    
    lazy var messageInputAccessoryView: ChatInputContainerView = {
        
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.messagesController = self
        
        return chatInputContainerView
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
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
        
        // Set the width of the bubbleView to match the text content width.
        if let text = message.text {
            
            messageBubbleCell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32 // Added the extra space b/c of cut off text problem
        }
        
        messageBubbleCell.configureCell(message: message)
        
        return messageBubbleCell
    }    
}
