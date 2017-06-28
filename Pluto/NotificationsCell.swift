//
//  NotificationsCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit

class NotificationsCell: BaseCollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - UI Components
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    // MARK: - Global Variables
    
    let cellId = "notificationCell"
    
    // MARK: - View Configuration
    
    override func setUpViews() {
        super.setUpViews()
        
        // Change the background color of the cell.
        backgroundColor = .clear
        
        // Add the UI components.
        addSubview(tableView)
        
        // Set up constraints for the UI components.
        setUpTableView()
    }
    
    func setUpTableView() {
        
        // Add X, Y, width, and height constraints to the mapView.
        tableView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        return cell
    }
}

