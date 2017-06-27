//
//  LoginController+handlers.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/27/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

extension LoginController {
    
    func handleLoginRegisterSegmentChange() {
        
        // Change the addProfilePicImageView and modify user interaction ability.
        addProfilePicImageView.image = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? UIImage(named: "app_icon_bg_none") : UIImage(named: "add_profile_pic")
        addProfilePicImageView.isUserInteractionEnabled = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? false : true
        
        // Change the height of inputsContainerView.
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // Show/hide the usernameTextField by manipulating the height anchor's multiplier.
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        // We also need to show/hide the placeholder text and the nameSeperatorView.
        nameTextField.placeholder = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? "" : "First + Last"
        nameSeperatorView.alpha = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1
        
        // Modify the email and password fields so they take up more or less space in inputsContainerView to adjust for the usernameTextField.
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        // Grab the title of the selected control index and capitalize it.
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)?.uppercased()
        // Set the title to the button text.
        loginRegisterButton.setTitle(title, for: .normal)
    }

    func handleLoginOrRegister() {
        
        // Check the segmented control to decide whether to log in or register.
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            
            handleLogin()
            
        } else {
            
            handleRegister()
        }
    }
    
    func handleLogin() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            
            print("ERROR: the text fields are invalid.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                print("ERROR: there was an error logging in. Details: \(error.debugDescription)")
                return
            }
            
            // Dismiss the login controller.
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            
            print("ERROR: the text fields are invalid.")
            return
        }
        
        // Authenticate the new user using Firebase.
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                
                print("ERROR: something went wrong while creating the account. Details: \(error.debugDescription)")
                return
            }
            
            guard let uid = user?.uid else {
                
                print("ERROR: could not get user ID.")
                return
            }
            
            // Upload the selected profile pic to Firebase.
            if let uploadData = UIImagePNGRepresentation(self.addProfilePicImageView.image!) {
                
                DataService.ds.REF_PROFILE_PICS.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        
                        print("ERROR: could not upload profile pic to Firebase. Details: \(error.debugDescription)")
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                     
                        // Create a dictionary of values to add to the database.
                        let values = ["name": name,
                                      "email": email,
                                      "profileImageUrl": profileImageUrl]
                        
                        // Once the profile pic has been uploaded, register the user to Firebase.
                        self.registerUserToDatabase(withUid: uid, values: values as [String : AnyObject])
                    }
                })
            }
        }
    }
    
    func registerUserToDatabase(withUid: String, values: [String: AnyObject]) {
        
        DataService.ds.REF_USERS.child(withUid).updateChildValues(values, withCompletionBlock: { (error, reference) in
            
            if error != nil {
                
                print("ERROR: could not authenticate the user with Firebase. Details: \(error.debugDescription)")
            }
            
            // Dismiss the login controller.
            self.dismiss(animated: true, completion: nil)
        })
    }
}

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleSelectProfileImageView() {
        
        // Bring up the user's photo gallery.
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        // Grab the image that was selected and/or edited by the user.
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            
            selectedImageFromPicker = editedImage
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            // Set the selected image to the addProfilePicImageView.
            addProfilePicImageView.image = selectedImage
            
            // Add a corner radius to the addProfilePicImageView.
            addProfilePicImageView.layer.cornerRadius = 15
            // The corner radius will not take effect if the following line is not added:
            addProfilePicImageView.layer.masksToBounds = true
        }
        
        // Dismiss the image picker.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Dismiss the image picker.
        dismiss(animated: true, completion: nil)
    }
}
