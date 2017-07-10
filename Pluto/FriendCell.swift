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
    
    let profileImageView: UIImageView = {
       
        let imageView = UIImageView()
        imageView.image = UIImage(named: "map_icon")
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 25
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let nameLabel: UILabel = {
       
        let label = UILabel()
        label.text = "Name"
        label.textColor = WHITE_COLOR
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
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
        
        if let profileImageUrl = user.profileImageUrl, let name = user.name {
            
            profileImageView.setImageWithKingfisher(url: profileImageUrl)
            nameLabel.text = name
        }
    }
}
