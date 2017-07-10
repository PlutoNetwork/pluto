//
//  FriendCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/10/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit

class FriendCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    
    lazy var profileImageView: UIImageView = {
       
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 25
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap(tapGesture:))))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    func handleProfileImageTap(tapGesture: UITapGestureRecognizer) {
        
        // Show the user's profile.
        let profileController = ProfileController()
        profileController.user = user
        
        // Open the ProfileController.
        self.eventController?.navigationController?.pushViewController(profileController, animated: true)
    }
    
    let nameLabel: UILabel = {
       
        let label = UILabel()
        label.text = "Name"
        label.textColor = WHITE_COLOR
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - Global Variables
    
    var eventController: EventController?
    var user: User?
    
    // MARK: - View Configuration

    override func setUpViews() {
        super.setUpViews()
        
        // Change the backgroundColor.
        backgroundColor = UIColor.clear
        
        // Add the UI components.
        self.addSubview(profileImageView)
        self.addSubview(nameLabel)
        
        // Set up constraints.
        
        // Add X, Y, width, and height constraints to the profileImageView.
        profileImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -8).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Add X and Y constraints. to the nameLabel.
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
    }

    func configureCell(user: User) {
        
        self.user = user
        
        if let profileImageUrl = user.profileImageUrl, let name = user.name {
            
            profileImageView.setImageWithKingfisher(url: profileImageUrl)
            nameLabel.text = name
        }
    }
}
