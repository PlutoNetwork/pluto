//
//  MainController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/26/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import Hue
import MapKit

class MainController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - UI Components
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // Turn the status bar white.
        return .lightContent
    }
    
    lazy var searchBarButtonItem: UIBarButtonItem = {
        
        let button = UIBarButtonItem(image: UIImage(named: "ic_search")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSearch))
        
        return button
    }()
    
    lazy var createBarButtonItem: UIBarButtonItem = {
        
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleCreate))
        button.tintColor = UIColor.black
        
        return button
    }()
    
    lazy var menuBar: MenuBar = {
        
        let bar = MenuBar()
        bar.mainController = self
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        return bar
    }()
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.backgroundColor = UIColor.clear
        // The following line will allow us to snap the cell into place when scrolling.
        colView.isPagingEnabled = true
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.dataSource = self
        colView.delegate = self
        
        return colView
    }()
    
    // MARK: - Global Variables
    
    let mapCellId = "mapCell"
    let chatCellId = "chatCell"
    let profileCellId = "profileCell"
    let notificationsCellId = "notificationsCell"
    
    // MARK: - View Configuration

    fileprivate func navigationBarCustomization() {
        
        navigationController?.navigationBar.isTranslucent = false
        // Add a custom title view to the navigation bar.
        let navigationBarTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        navigationBarTitleLabel.text = "  Pluto"
        navigationBarTitleLabel.textColor = UIColor.black
        navigationBarTitleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = navigationBarTitleLabel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change the background color of the view using the Hue library.
        let gradient = [ORANGE_COLOR, PINK_COLOR].gradient()
        gradient.bounds = view.bounds
        gradient.frame = view.frame
        view.layer.insertSublayer(gradient, at: 0)

        navigationBarCustomization()
        
        // Add the UI components.
        view.addSubview(menuBar)
        view.addSubview(collectionView)
        
        // Set up constraints for the UI components.
        setUpMenuBar()
        setUpNavigationBarButtons()
        setUpCollectionView()
        
        // Register a cell class in the collectionView.
        collectionView.register(MapCell.self, forCellWithReuseIdentifier: mapCellId)
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: chatCellId)
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: profileCellId)
        collectionView.register(NotificationsCell.self, forCellWithReuseIdentifier: notificationsCellId)
        
        checkIfUserLoggedIn()
    }
    
    func checkIfUserLoggedIn() {
        
        // If a user is not logged in, get the hell outta here.
        if Auth.auth().currentUser?.uid == nil {
            
            // Without the following line, a warning appears and tells us that we have too many controllers while the app is starting. To fix, add the following:
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
    }
    
    func setUpMenuBar() {
    
        // Add X, Y, width, and height constraints to the menuBar.
        menuBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        menuBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menuBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        menuBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setUpNavigationBarButtons() {
        
        navigationItem.rightBarButtonItems = [createBarButtonItem, searchBarButtonItem]
    }
    
    func setUpCollectionView() {
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            // Make the collection view flow horizontally.
            flowLayout.scrollDirection = .horizontal
            
            // Take out the gap between cells.
            flowLayout.minimumLineSpacing = 0
        }
        
        // Add X, Y, width, and height constraints to the collectionView.
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: menuBar.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
    func scrollToMenu(index: Int) {
        
        let indexPath = NSIndexPath(item: index, section: 0)
        
        // Scroll to the given index in the menuBar and the collectionView.
        collectionView.scrollToItem(at: indexPath as IndexPath, at: [], animated: true)
    }
    
    // MARK: - Collection View Functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Change the menuBar's underline bar position to match the cell being shown.
        menuBar.horizontalUnderlineBarViewLeftAnchor?.constant = scrollView.contentOffset.x/4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Return a section for every menu bar tab.
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Return a size that covers the view.
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
        
            let mapCell = collectionView.dequeueReusableCell(withReuseIdentifier: mapCellId, for: indexPath) as! MapCell
         
            return mapCell
        
        } else if indexPath.item == 1 {
            
            let chatCell = collectionView.dequeueReusableCell(withReuseIdentifier: chatCellId, for: indexPath) as! ChatCell
            
            return chatCell
            
        } else if indexPath.item == 2 {
            
            let profileCell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCellId, for: indexPath) as! ProfileCell
            
            return profileCell
            
        } else {
            
            let notificationsCell = collectionView.dequeueReusableCell(withReuseIdentifier: notificationsCellId, for: indexPath) as! NotificationsCell
            
            return notificationsCell
        }
    }
}
