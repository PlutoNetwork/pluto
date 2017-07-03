//
//  EventChatCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/29/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import BadgeSwift

class EventChatCell: UITableViewCell {
    
    // MARK: - UI Components
    
    let eventImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let timeLabel: UILabel = {
        
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = LIGHT_BLUE_COLOR
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let newMessageCountBadge: BadgeSwift = {
        
        let badge = BadgeSwift()
        badge.text = "2"
        badge.textColor = WHITE_COLOR
        badge.badgeColor = UIColor.red
        badge.isHidden = true
        badge.translatesAutoresizingMaskIntoConstraints = false
        
        return badge
    }()
    
    // MARK: - View Components

    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 4, width: textLabel!.frame.width + 20, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 4, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
        textLabel?.textColor = WHITE_COLOR
        textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        detailTextLabel?.textColor = WHITE_COLOR
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        // Change the background color of the cell.
        backgroundColor = DARK_BLUE_COLOR
        
        // Add the UI components to the cell.
        addSubview(eventImageView)
        addSubview(timeLabel)
        addSubview(newMessageCountBadge)
        
        // Set up the constraints for the UI components.
        setUpEventImageView()
        setUpTimeLabel()
        setUpNewMessageCountBadge()
    }
    
    func setUpEventImageView() {
        
        // Add X, Y, width, and height constraints to the eventImageView.
        eventImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        eventImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func setUpTimeLabel() {
        
        // Add X, Y, width, and height constraints to the eventImageView.
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    func setUpNewMessageCountBadge() {
        
        // Add X, Y, width, and height constraints to the newMessageCountBadge.
        newMessageCountBadge.leftAnchor.constraint(equalTo: (textLabel?.rightAnchor)!, constant: 8).isActive = true
        newMessageCountBadge.centerYAnchor.constraint(equalTo: (textLabel?.centerYAnchor)!).isActive = true
        newMessageCountBadge.widthAnchor.constraint(equalToConstant: 25).isActive = true
        newMessageCountBadge.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    
    func trunc(length: Int, trailing: String? = "...") -> String {
        
        if self.characters.count > length {
            
            return self.substring(to: self.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
            
        } else {
            return self
        }
    }
}
