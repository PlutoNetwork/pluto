//
//  LoginController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/26/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginController: UIViewController, GIDSignInUIDelegate {

    // MARK: - UI Components
        
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
        segmentedControl.tintColor = LIGHT_BLUE_COLOR
        // Start the control with the "Register" item highlighted.
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.addTarget(self, action: #selector(handleLoginRegisterSegmentChange), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        return segmentedControl
    }()
    
    /// A view for the login and register text fields.
    let inputsContainerView: UIView = {
        
        let view = UIView()
        view.backgroundColor = DARK_BLUE_COLOR
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        // The corner radius will not take effect if the following line is not added:
        view.layer.masksToBounds = true
        
        return view
    }()
    
    let nameTextField: UITextField = {
        
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "First + Last",
                                                             attributes: [NSForegroundColorAttributeName: LIGHT_BLUE_COLOR])
        textField.textColor = WHITE_COLOR
        textField.tintColor = WHITE_COLOR
        textField.autocapitalizationType = .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let nameSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = LIGHT_BLUE_COLOR
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let emailTextField: UITextField = {
        
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "email@something.com",
                                                             attributes: [NSForegroundColorAttributeName: LIGHT_BLUE_COLOR])
        textField.textColor = WHITE_COLOR
        textField.tintColor = WHITE_COLOR
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let emailSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = LIGHT_BLUE_COLOR
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let passwordTextField: UITextField = {
        
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                             attributes: [NSForegroundColorAttributeName: LIGHT_BLUE_COLOR])
        textField.textColor = WHITE_COLOR
        textField.tintColor = WHITE_COLOR
        textField.translatesAutoresizingMaskIntoConstraints = false
        // Hide the text in the field.
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    lazy var loginRegisterButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.layer.borderColor = LIGHT_BLUE_COLOR.cgColor
        button.layer.borderWidth = 1
        button.setTitle("REGISTER", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(LIGHT_BLUE_COLOR, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleLoginOrRegister), for: .touchUpInside)
        
        return button
    }()
    
    lazy var facebookLoginButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 59, green: 89, blue: 152)
        button.setTitle("Login with Facebook", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleFacebookLogin), for: .touchUpInside)
        
        return button
    }()
    
    lazy var googleLoginButton: UIButton = {
       
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.setTitle("Sign in with Google", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Global Variables
    
    var mainController: MainController?
    var imageSelected = false
    
    // MARK: - View Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the background color of the view.
        view.backgroundColor = DARK_BLUE_COLOR
        
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
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
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
        
        // Set up text field delegates.
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
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

extension LoginController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Dismiss the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
}
