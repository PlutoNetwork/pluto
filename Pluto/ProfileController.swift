//
//  ProfileController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/10/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {
    
    // MARK: - UI Components
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "map_icon")
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 100
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let nameLabel: UILabel = {
        
        let label = UILabel()
        label.text = "Name"
        label.textColor = WHITE_COLOR
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - Global Variables
    
    var user: User? {
        didSet {
            
            setUserValues()
        }
        
    }
    
    // MARK: - View Configuration

    override func viewDidLoad() {
        super.viewDidLoad()

        // Change the backgroundColor.
        view.backgroundColor = DARK_BLUE_COLOR
        
        // Add the UI components.
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        
        // Set up the constraints.
        setUpProfileImageView()
        setUpNameLabel()
    }
    
    func setUpProfileImageView() {
    
        // Add X, Y, width, and height constraints to the profileImageView.
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setUpNameLabel() {
        
        // Add X and Y constraints. to the nameLabel.
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 25).isActive = true
    }
    
    func setUserValues() {
        
        if let profileImageUrl = user?.profileImageUrl, let name = user?.name {
            
            profileImageView.setImageWithKingfisher(url: profileImageUrl)
            nameLabel.text = name
        }
    }
}
