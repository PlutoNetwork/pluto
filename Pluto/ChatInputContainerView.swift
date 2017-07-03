//
//  ChatInputContainerView.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/1/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

class ChatInputContainerView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    lazy var uploadImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_upload_image")
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadImageViewTap)))
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
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
        addSubview(uploadImageView)
        
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
        
        // Add X, Y, width, and height constraints to the uploadImageView.
        uploadImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        uploadImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Add X, Y, width, and height constraints to the inputTextField.
        inputTextField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func handleUploadImageViewTap() {
        
        // Show the user's photo gallery.
        let imagePickerController = UIImagePickerController()
        imagePickerController.navigationBar.isTranslucent = false
        imagePickerController.navigationBar.barTintColor = DARK_BLUE_COLOR
        imagePickerController.navigationBar.tintColor = WHITE_COLOR
        imagePickerController.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : WHITE_COLOR
        ]
        imagePickerController.delegate = self
        messagesController?.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        // Grab the image that was selected by the user.
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            // Upload to Firebase storage.
            uploadToFirebaseStorageUsing(image: selectedImage)
        }
        
        // Dismiss the image picker.
        messagesController?.dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsing(image: UIImage) {
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            
            DataService.ds.REF_MESSAGE_PICS.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    print("ERROR: there was an error uploading the message image to Firebase. Details: \(error.debugDescription)")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    self.sendMessageWith(imageUrl: imageUrl, image: image)
                }
            })
        }
    }
    
    private func sendMessageWith(imageUrl: String, image: UIImage) {
        
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        messagesController?.sendMessageWith(properties: properties)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Dismiss the image picker.
        messagesController?.dismiss(animated: true, completion: nil)
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
