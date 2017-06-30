//
//  ProfileCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ProfileCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "app_icon_bg_none")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.layer.frame.width/2
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let nameLabel: UILabel = {
       
        let label = UILabel()
        label.text = "First + Last"
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // MARK: - View Configuration
    
    override func setUpViews() {
        super.setUpViews()
        
        // Change the background color of the cell.
        backgroundColor = .clear
        
        // Add the UI components to the view.
        addSubview(profileImageView)
        addSubview(nameLabel)
        
        // Set up the constraints for the UI components.
        setUpProfileImageView()
        setUpNameLabel()
        
        UserService.sharedInstance.fetchCurrentUserData(completion: { (name, profileImageUrl) in
            
            self.nameLabel.text = name
            
            // Use the Kingfisher library.
            let url = URL(string: profileImageUrl)
            self.profileImageView.kf.setImage(with: url)
        })
    }
    
    func setUpProfileImageView() {
        
        // Add X, Y, width, and height constraints to the profileImageView.
        profileImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    func setUpNameLabel() {
        
        // Add X and Y constraints to the nameLabel.
        nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12).isActive = true
    }
}
