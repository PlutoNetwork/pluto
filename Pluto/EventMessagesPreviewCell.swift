//
//  EventMessagesPreviewCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/29/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import BadgeSwift

class EventMessagesPreviewCell: UITableViewCell {
    
    // MARK: - UI Components
    
    let eventImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
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
        
        // Turn off the hideous highlighting that happens when a user taps on a cell.
        selectionStyle = .none
        
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
    
    func configureCell(event: Event, message: Message) {
        
        // Set the text label to the event's title.
        textLabel?.text = event.title.trunc(length: 20)
        
        // Set the cell's image.
        if let image = event.image {
            
            eventImageView.image = UIImage(named: image)
        }
        
        if message.imageUrl == nil {
            
            // Set the detail text label to the latest message.
            detailTextLabel?.text = message.text?.trunc(length: 40)
            
        } else {
            
            if let imageSenderKey = message.fromId {
                
                UserService.sharedInstance.fetchUserData(withKey: imageSenderKey, completion: { (user) in
                    
                    // Set the detail text to the image default message.
                    if let imageSenderName = user.name {
                        
                        self.detailTextLabel?.text = "\(imageSenderName) sent an image."
                    }
                })
            }
        }
        
        // Set time label to the latest message's timeStamp.
        if let seconds = message.timeStamp?.doubleValue {
            
            let timeStampDate = Date(timeIntervalSince1970: seconds)
            
            // Format the time stamp.
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            
            timeLabel.text = dateFormatter.string(from: timeStampDate)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
