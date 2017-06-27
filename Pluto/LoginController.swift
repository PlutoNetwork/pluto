//
//  LoginController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/26/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Hue

class LoginController: UIViewController {

    // MARK: - UI Components
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // Turn the status bar white.
        return .lightContent
    }
    
    let addProfilePicImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "add_profile_pic")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
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
    
    let usernameTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "@username"
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    let usernameSeperatorView: UIView = {
        
        let view = UIView()
        view.backgroundColor = UIColor.black
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
        view.backgroundColor = UIColor.black
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
    
    let loginRegisterButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        button.setTitle("REGISTER", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: - View Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the background color of the view using the Hue library.
        let gradient = [UIColor(red: 255, green: 89, blue: 49), UIColor(red: 240, green: 49, blue: 126)].gradient()
        gradient.bounds = view.bounds
        gradient.frame = view.frame
        view.layer.insertSublayer(gradient, at: 0)
        
        // view.backgroundColor = UIColor.black
        
        // Add the UI components.
        view.addSubview(addProfilePicImageView)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        
        // Set up the constraints.
        setUpProfileImageView()
        setUpInputsContainerView()
        setUpLoginRegisterButton()
    }
    
    /**
        Adds constaints to the inputsContainerView.
     */
    func setUpProfileImageView() {
        
        // Add X, Y, width, and height constraints to the profileImageView.
        addProfilePicImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addProfilePicImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        addProfilePicImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        addProfilePicImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    /**
        Adds constaints to the inputsContainerView.
    */
    func setUpInputsContainerView() {
    
        // Add X, Y, width, and height constraints to the inputsContainerView.
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        // Add the username, email, and password fields, along with their seperators, to the view.
        inputsContainerView.addSubview(usernameTextField)
        inputsContainerView.addSubview(usernameSeperatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        // Add X, Y, width, and height constraints to the usernameTextField.
        usernameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        usernameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        usernameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        // Add X, Y, width, and height constraints to the usernameSeperatorView.
        usernameSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        usernameSeperatorView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
        usernameSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        usernameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add X, Y, width, and height constraints to the emailTextField.
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        // Add X, Y, width, and height constraints to the emailSeperatorView.
        emailSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // Add X, Y, width, and height constraints to the passwordTextField.
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        
        // Set the delegates of the text fields.
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    /**
     Adds constaints to the loginRegisterButton.
     */
    func setUpLoginRegisterButton() {
        
        // Add X, Y, width, and height constraints to the loginRegisterButton.
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension LoginController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == usernameTextField {
            
            // Add an @ to the beginning of the username.
            textField.text = "@"
        }
    }
}

extension UIColor {
    
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}
