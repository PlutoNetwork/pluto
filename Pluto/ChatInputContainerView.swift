//
//  ChatInputContainerView.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/1/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

class ChatInputContainerView: UIView {
    
    // MARK: - UIComponents
    
    let seperatorLineView: UIView = {
        
        let view = UIView()
        view.backgroundColor = LIGHT_BLUE_COLOR
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var sendButton: UIButton = {
        
        // - TODO: Set the button color to gray and un-interactable when the field is blank.
        
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.setTitleColor(LIGHT_BLUE_COLOR, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var inputTextField: UITextField = {
        
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter message...",
                                                             attributes: [NSForegroundColorAttributeName: LIGHT_BLUE_COLOR])
        textField.textColor = WHITE_COLOR
        textField.tintColor = WHITE_COLOR
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        
        return textField
    }()
    
    // MARK: - Global Variables
    
    var messagesController: MessagesController? {
        didSet {
            
            // Add functionality to the send button using a function from MessagesController.
            sendButton.addTarget(messagesController, action: #selector(MessagesController.handleSend), for: .touchUpInside)
        }
    }
    
    // MARK: - View Configuration
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Change the backgroundColor.
        backgroundColor = DARK_BLUE_COLOR
        
        // Add UI components.
        addSubview(seperatorLineView)
        addSubview(sendButton)
        addSubview(inputTextField)
        
        // Add X, Y, width, and height constraints to the seperatorLineView.
        seperatorLineView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        seperatorLineView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add X, Y, width, and height constraints to the sendButton.
        sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        sendButton.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        // Add X, Y, width, and height constraints to the inputTextField.
        inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChatInputContainerView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Dismiss the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
}
