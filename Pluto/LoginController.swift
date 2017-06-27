//
//  LoginController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/26/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import Hue

class LoginController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate {

    // MARK: - UI Components
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // Turn the status bar white.
        return .lightContent
    }
    
    lazy var addProfilePicImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "add_profile_pic")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        
        let segmentedControl = UISegmentedControl(items: ["Login", "Register"])
        segmentedControl.tintColor = UIColor.white
        // Start the control with the "Register" item highlighted.
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(handleLoginRegisterSegmentChange), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        return segmentedControl
    }()
    
    /// A view for the login and register text fields.
    let inputsContainerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        // The corner radius will not take effect if the following line is not added:
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let nameTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "First + Last"
        textField.autocapitalizationType = .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let nameSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let emailTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "email@something.com"
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let emailSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let passwordTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "password"
        textField.translatesAutoresizingMaskIntoConstraints = false
        // Hide the text in the field.
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    lazy var loginRegisterButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.setTitle("REGISTER", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleLoginOrRegister), for: .touchUpInside)
        
        return button
    }()
    
    /// This is a custom button provided by Facebook.
    let facebookLoginButton: FBSDKLoginButton = {
        
        let button = FBSDKLoginButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if error != nil {
            
            print("ERROR: there was an error logging in with Facebook. Details: \(error)")
            return
        }
        
        signInUsingFirebaseWithFacebook()
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
                
                // Create a dictionary of values to add to the database.
                let values = ["name": userData.value(forKey: "name"),
                              "email": userData.value(forKey: "email"),
                              "profileImageUrl": profileImageUrl]
            
                // Use Firebase to sign the user in.
                Auth.auth().signIn(with: credentials) { (user, error) in
                    
                    if error != nil {
                        
                        print("ERROR: something went wrong authenticating in Firebase with the Facebook user data. Details: \(error.debugDescription)")
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
        }
        
        // Dismiss the login controller.
        self.dismiss(animated: true, completion: nil)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    let googleLoginButton: GIDSignInButton = {
       
        let button = GIDSignInButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            
            print("ERROR: failed to log in with Google. Details: \(error)")
            return
        }
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        let profileImageUrl = user.profile.imageURL(withDimension: 1000).absoluteString
        
        // Create a dictionary of values to add to the database.
        let values = ["name": user.profile.name,
                      "email": user.profile.email,
                      "profileImageUrl": profileImageUrl]
        
        // Authenticate with Firebase.
        Auth.auth().signIn(with: credentials) { (user, error) in
            
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
    
    // MARK: - View Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the background color of the view using the Hue library.
        let gradient = [UIColor(red: 255, green: 89, blue: 49), UIColor(red: 240, green: 49, blue: 126)].gradient()
        gradient.bounds = view.bounds
        gradient.frame = view.frame
        view.layer.insertSublayer(gradient, at: 0)
        
        // Add the UI components.
        view.addSubview(addProfilePicImageView)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(facebookLoginButton)
        view.addSubview(googleLoginButton)
        
        // Set up the constraints.
        setUpProfileImageView()
        setUpLoginRegisterSegmentedControl()
        setUpInputsContainerView()
        setUpLoginButtons()
        
        // Set any needed delegates.
        facebookLoginButton.delegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // We need to specifiy read permissions on the facebookLoginButton.
        facebookLoginButton.readPermissions = ["email", "public_profile"]
    }
    
    /**
        Adds constaints to the inputsContainerView.
     */
    func setUpProfileImageView() {
        
        // Add X, Y, width, and height constraints to the profileImageView.
        addProfilePicImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addProfilePicImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -12).isActive = true
        addProfilePicImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        addProfilePicImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    /**
        Adds constaints to the loginRegisterSegmentedControl.
     */
    func setUpLoginRegisterSegmentedControl() {
        
        // Add X, Y, width, and height constraints to the loginRegisterSegmentedControl.
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    // These needs to be declared here so we can change them with the segmented control.
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    /**
        Adds constaints to the inputsContainerView.
    */
    func setUpInputsContainerView() {
    
        // Add X, Y, width, and height constraints to the inputsContainerView.
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        // Add the username, email, and password fields, along with their seperators, to the view.
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeperatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        // Add X, Y, width, and height constraints to the nameTextField.
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        // Add X, Y, width, and height constraints to the nameSeperatorView.
        nameSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add X, Y, width, and height constraints to the emailTextField.
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // Add X, Y, width, and height constraints to the emailSeperatorView.
        emailSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add X, Y, width, and height constraints to the passwordTextField.
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    /**
     Adds constaints to the login buttons.
     */
    func setUpLoginButtons() {
        
        // Add X, Y, width, and height constraints to the loginRegisterButton.
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Add X, Y, width, and height constraints to the facebookLoginButton.
        facebookLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookLoginButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 24).isActive = true
        facebookLoginButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        facebookLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Add X, Y, width, and height constraints to the googleLoginButton.
        googleLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleLoginButton.topAnchor.constraint(equalTo: facebookLoginButton.bottomAnchor, constant: 12).isActive = true
        googleLoginButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        googleLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension UIColor {
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
