//
//  LoginController+handlers.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/27/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import NVActivityIndicatorView

extension LoginController: GIDSignInDelegate, NVActivityIndicatorViewable {
        
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
        
        // Clear any text that the user may have typed.
        nameTextField.text = ""
        
        // We also need to show/hide the placeholder text and the nameSeperatorView.
        nameTextField.attributedPlaceholder = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName: LIGHT_BLUE_COLOR]) : NSAttributedString(string: "First + Last", attributes: [NSForegroundColorAttributeName: LIGHT_BLUE_COLOR])
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
        
        startAnimating()
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            
            print("ERROR: the text fields are invalid.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            self.stopAnimating()
            
            if error != nil {
                
                print("ERROR: there was an error logging in. Details: \(error.debugDescription)")
                
                switch (error?._code)! {
                    
                    case ERROR_WRONG_PASSWORD:
                        SCLAlertView().showError("Whoops!", subTitle: "The password is wrong or nonexistent.")
                    default:
                        SCLAlertView().showError("Whoops!", subTitle: "Pluto couldn't log you in. Try again.")
                }
                
                return
            }
            
            // Reload the main controller.
            self.mainController?.setUpMainCollectionView()
            
            // Dismiss the login controller.
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        
        startAnimating()
        
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            
            print("ERROR: the text fields are invalid.")
            return
        }
        
        if name == "" || !imageSelected {
            
            stopAnimating()
            
            SCLAlertView().showError("Whoops!", subTitle: "You forgot to pick a profile picture or you didn't enter your name.")
            
        } else {
        
            // Authenticate the new user using Firebase.
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                
                if error != nil {
                    
                    self.stopAnimating()
                    
                    print("ERROR: something went wrong while creating the account. Details: \(error.debugDescription)")
                    
                    switch (error?._code)! {
                        
                    case ERROR_WEAK_PASSWORD:
                        SCLAlertView().showError("Whoops!", subTitle: "Your password is weak. Make it longer.")
                    case ERROR_BAD_EMAIL:
                        SCLAlertView().showError("Whoops!", subTitle: "Your email is invalid. Make it exist.")
                    case ERROR_ACCOUNT_EXISTS:
                        SCLAlertView().showError("Whoops!", subTitle: "There's a problem with your email. Either an account already exists or you just typed it incorrectly.")
                    default:
                        SCLAlertView().showError("Whoops!", subTitle: "Pluto could not create your account. Try again.")
                    }
                    
                    return
                }
                
                guard let uid = user?.uid else {
                    
                    print("ERROR: could not get user ID.")
                    return
                }
                
                let token = Messaging.messaging().fcmToken
                
                // Upload the selected profile pic to Firebase.
                if let uploadData = UIImagePNGRepresentation(self.addProfilePicImageView.image!) {
                    
                    DataService.ds.REF_PROFILE_PICS.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil {
                            
                            print("ERROR: could not upload profile pic to Firebase. Details: \(error.debugDescription)")
                            
                            SCLAlertView().showError("Whoops!", subTitle: "Pluto couldn't upload your profile picture. Try again later.")
                            
                            return
                        }
                        
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                         
                            // Create a dictionary of values to add to the database.
                            let values = ["name": name,
                                          "email": email,
                                          "profileImageUrl": profileImageUrl,
                                          "pushToken": token as Any,
                                          "events": ["-123456789": true]] as [String : Any]
                            
                            // Once the profile pic has been uploaded, register the user to Firebase.
                            self.registerUserToDatabase(withUid: uid, values: values as [String : AnyObject])
                        }
                    })
                }
            }
        }
    }
    
    func handleFacebookLogin() {
        
        startAnimating()
        
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            
            if error != nil {
                
                print("ERROR: could not login with Facebook. Details: \(error.debugDescription)")
                return
            }
            
            self.signInUsingFirebaseWithFacebook()
        }
    }
    
    func signInUsingFirebaseWithFacebook() {
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        // Make a request to Facebook to grab the new user's data.
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture.type(large)"]).start { (connection, result, error) in
            
            if error != nil {
                
                print("ERROR: failed to start graph request. Details: \(error.debugDescription)")
                return
            }
            
            let userData = result as! NSDictionary
            
            // Grab the user's profile picture from Facebook.
            if let profileImageUrl = ((userData.value(forKey: "picture") as AnyObject).value(forKey: "data") as AnyObject).value(forKey: "url") as? String {
                
                self.firebaseAuthSignIn(withCredentials: credentials, name: userData.value(forKey: "name") as! String, email: userData.value(forKey: "email") as! String, profileImageUrl: profileImageUrl)
                
                self.stopAnimating()
            }
        }
    }
    
    func handleGoogleSignIn() {
        
        startAnimating()
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            
            print("ERROR: failed to log in with Google. Details: \(error)")
            return
        }
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        let profileImageUrl = user.profile.imageURL(withDimension: 1000).absoluteString
        
        self.firebaseAuthSignIn(withCredentials: credentials, name: user.profile.name, email: user.profile.email, profileImageUrl: profileImageUrl)
        
        stopAnimating()
    }
    
    private func firebaseAuthSignIn(withCredentials: AuthCredential, name: String, email: String, profileImageUrl: String) {
        
        let token = Messaging.messaging().fcmToken
        
        // Create a dictionary of values to add to the database.
        let values = ["name": name,
                      "email": email,
                      "profileImageUrl": profileImageUrl,
                      "pushToken": token as Any,
                      "events": ["-123456789": true]] as [String : Any]
        
        // Authenticate with Firebase.
        Auth.auth().signIn(with: withCredentials) { (user, error) in
            
            if error != nil {
                
                print("ERROR: something went wrong authenticating in Firebase with the Google user data. Details: \(error.debugDescription)")
                return
            }
            
            guard let uid = user?.uid else {
                
                print("ERROR: could not get user ID.")
                return
            }
            
            // Register the user to the Firebase database.
            self.registerUserToDatabase(withUid: uid, values: values as [String : AnyObject])
        }
    }
    
    private func registerUserToDatabase(withUid: String, values: [String: AnyObject]) {
        
        DataService.ds.REF_USERS.child(withUid).updateChildValues(values, withCompletionBlock: { (error, reference) in
            
            self.stopAnimating()
            
            if error != nil {
                
                print("ERROR: could not authenticate the user with Firebase. Details: \(error.debugDescription)")
            }
            
            // Reload the main controller.
            self.mainController?.setUpMainCollectionView()
            
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
        
        // Indicate that a profile image has been selected.
        imageSelected = true
        
        // Dismiss the image picker.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Dismiss the image picker.
        dismiss(animated: true, completion: nil)
    }
}
