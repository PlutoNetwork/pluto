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
        
        // Make the collectionView draggable.
        collectionView?.alwaysBounceVertical = true
        
        // Add some space to the top and bottom of the collectionView.
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
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
                
                self.attemptReloadOfTable()
            }
        })
    }
    
    var timer: Timer?
    
    fileprivate func attemptReloadOfTable() {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    func handleReloadTable() {
        
        DispatchQueue.main.async(execute: {
            
            self.collectionView?.reloadData()
            self.moveMessagesUp()
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
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timeStamp": timeStamp as AnyObject]
        
        // Append the parameter dictionary to the values.
        properties.forEach({values[$0] = $1})
        
        MessageService.sharedInstance.updateMessages(toId: toId, fromId: fromId, values: values)
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
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // We need these here for zooming out.
    var startingFrame: CGRect?
    var startingImageView: UIImageView?
    var blackBackgroundView: UIView?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        // Establish a starting frame.

        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        // Reference the imageView that will be zoomed.
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageZoomOutTap)))
        
        // Reference the whole of the screen.
        if let keyWindow = UIApplication.shared.keyWindow {
            
            // Add a black background to hide the rest of the window.
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            keyWindow.addSubview(blackBackgroundView!)
            blackBackgroundView?.alpha = 0
            
            // Add the image view.
            keyWindow.addSubview(zoomingImageView)
            
            // Perform the zoom-in animation.
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                self.messageInputAccessoryView.alpha = 0
                
                // heightForRect2 / widthForRect1 = heightForRect1 / widthForRect2
                // heightForRect2 = heightForRect1 / widthForRect1 * widthForRect2
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                // Set the width to match the whole of the screen's width.
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                // Position the image to the center of the screen.
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    func handleImageZoomOutTap(tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true
            
            // We need to animate back to the imageView's normal position within the message bubble.
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
                
                // Change the frame of the image back to normal.
                zoomOutImageView.frame = self.startingFrame!
                
                // Hide the black background view and bring back the messageInputAccessoryView.
                self.blackBackgroundView?.alpha = 0
                self.messageInputAccessoryView.alpha = 1
                
            }, completion: { (completed) in
                
                // Remove the zoomOutImageView from the superView.
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let messageBubbleCell = collectionView.dequeueReusableCell(withReuseIdentifier: messageBubbleCellId, for: indexPath) as! MessageBubbleCell
        
        messageBubbleCell.messageLogController = self
        
        let message = messages[indexPath.item]
        
        // Set the width of the bubbleView to match the text content width or the image width.
        if let text = message.text {
            
            messageBubbleCell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32 // Added the extra space b/c of cut off text problem
            messageBubbleCell.messageTextView.isHidden = false
            
        } else if message.imageUrl != nil {
            
            messageBubbleCell.bubbleWidthAnchor?.constant = 200
            messageBubbleCell.messageTextView.isHidden = true
        }

        messageBubbleCell.configureCell(message: message)
        
        return messageBubbleCell
    }    
}
