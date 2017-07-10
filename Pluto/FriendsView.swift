//
//  FriendsView.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/9/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase

class FriendsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - UI Components
    
    lazy var friendsCollectionView: UICollectionView = {
       
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: self.frame.width, height: 100)
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = DARK_BLUE_COLOR
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    // MARK: - Global Variables
    
    let friendCellId = "friendCellId"
    var event: Event? {
        didSet {
            
            grabEventUsers()
        }
    }
    var eventUsers = [User]()
    
    // MARK: - View Configuration

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Change the backgroundColor.
        backgroundColor = DARK_BLUE_COLOR
                
        // Add the UI components.
        addSubview(friendsCollectionView)
        
        // Set up the friendsCollectionView.
        setUpFriendsCollectionView()
    }
    
    func grabEventUsers() {
        
        eventUsers.removeAll()
        
        if let eventKey = event?.key {
            
            DataService.ds.REF_EVENTS.child(eventKey).child("users").observe(.value, with: { (snapshot) in
                
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    
                    for snap in snapshot {
                        
                        let userKey = snap.key
                        DataService.ds.REF_USERS.child(userKey).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            if let userData = snapshot.value as? [String: AnyObject] {
                                
                                let user = User(userData: userData)

                                // Add the user to the eventUsers array.
                                self.eventUsers.append(user)
                                
                                // Reload the collectionView.
                                DispatchQueue.main.async(execute: {
                                    
                                    self.friendsCollectionView.reloadData()
                                })
                            }
                        })
                    }
                }
            })
        }
    }
    
    func setUpFriendsCollectionView() {
        
        // Register a cell class for the friendsCollectionView.
        friendsCollectionView.register(FriendCell.self, forCellWithReuseIdentifier: friendCellId)
        
        // Add some space to the top and bottom of the friendsCollectionView.
        friendsCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        // Add X, Y, width, and height constraints to the friendsCollectionView.
        friendsCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        friendsCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        friendsCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        friendsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Collection View Functions
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return eventUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 100, height: self.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // Set the initial state of the cell.
        cell.alpha = 0
        
        // Animate to change the final state.
        UIView.animate(withDuration: 0.5) {
            
            cell.alpha = 1.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let friendCell = collectionView.dequeueReusableCell(withReuseIdentifier: friendCellId, for: indexPath) as! FriendCell
        
        let user = eventUsers[indexPath.row]
        
        friendCell.configureCell(user: user)
        
        return friendCell
    }
}
