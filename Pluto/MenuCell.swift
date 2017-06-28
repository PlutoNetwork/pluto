//
//  MenuCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/27/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit

class MenuCell: BaseCollectionViewCell {
    
    // MARK: - UI Components
    
    let iconImageView: UIImageView = {
        
        let imgView = UIImageView()
        imgView.image = UIImage(named: "ic_room_white")
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        return imgView
    }()
    
    override var isSelected: Bool {
        didSet {
            
            // Everytime a cell is selected, underline the bottom of the cell.
            layer.borderColor = isSelected ? UIColor.black.cgColor : UIColor.white.cgColor
        }
    }
    
    override func setUpViews() {
        super.setUpViews()
        
        // Change the background color of the cell.
        backgroundColor = UIColor.clear
        
        // Add the UI components.
        addSubview(iconImageView)
        
        // Set up the constraints of the UI components.
        setUpImageView()
    }
    
    func setUpImageView() {
        
        // Add X, Y, width, and height constraints to the imageView.
        iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}
