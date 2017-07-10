//
//  MessageInputContainerView.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/1/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import ImagePicker

class MessageInputContainerView: UIView, ImagePickerDelegate, UINavigationControllerDelegate {
    
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
    
    var messageLogController: MessageLogController? {
        didSet {
            
            // Add functionality to the send button using a function from MessageLogController.
            sendButton.addTarget(messageLogController, action: #selector(MessageLogController.handleSend), for: .touchUpInside)
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
        
        // Use the ImagePicker library to summon the almighty image picker.
        var configuration = Configuration()
        configuration.doneButtonTitle = "Finish"
        configuration.noImagesTitle = "Whoops! There are no images here!"
        configuration.recordLocation = false
        configuration.bottomContainerColor = DARK_BLUE_COLOR
        configuration.gallerySeparatorColor = LIGHT_BLUE_COLOR
        configuration.settingsColor = WHITE_COLOR
        
        let imagePickerController = ImagePickerController(configuration: configuration)
        imagePickerController.imageLimit = 5
        imagePickerController.delegate = self
        messageLogController?.present(imagePickerController, animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        // Send each image picked.
        for image in images {
       
            MessageService.sharedInstance.uploadMessageImagesToFirebaseStorageUsing(image: image, completion: { (imageUrl) in
                
                self.sendMessageWith(imageUrl: imageUrl, image: image)
            })
        }
        
        messageLogController?.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
        
    private func sendMessageWith(imageUrl: String, image: UIImage) {
        
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        messageLogController?.sendMessageWith(properties: properties)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Dismiss the image picker.
        messageLogController?.dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MessageInputContainerView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Dismiss the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
}
