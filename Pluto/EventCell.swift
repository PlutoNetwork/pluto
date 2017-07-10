//
//  EventCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/10/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    // MARK: - UI Components
    
    let eventImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
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
        
        // Set up the constraints for the UI components.
        setUpEventImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpEventImageView() {
        
        // Add X, Y, width, and height constraints to the eventImageView.
        eventImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        eventImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        eventImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        eventImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func configureCell(event: Event) {
        
        // Set the text label to the event's title and the detail to the event's timeStart.
        textLabel?.text = event.title.trunc(length: 20)
        detailTextLabel?.text = event.timeStart
        
        // Set the cell's image.
        if let image = event.image {
            
            eventImageView.image = UIImage(named: image)
        }
    }
}
