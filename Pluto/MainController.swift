//
//  MainController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/26/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class MainController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UI Components
    
    lazy var logoutButtonItem: UIBarButtonItem = {
        
        let button = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        return button
    }()
    
    lazy var menuBar: MenuBar = {
        
        let bar = MenuBar()
        bar.mainController = self
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        return bar
    }()
    
    lazy var mainCollectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        // The following line will allow us to snap the cell into place when scrolling.
        collectionView.isPagingEnabled = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    // MARK: - Global Variables
    
    let mapCellId = "mapCell"
    let chatCellId = "chatCell"
    let profileCellId = "profileCell"
    let notificationsCellId = "notificationsCell"
    
    // MARK: - View Configuration

    fileprivate func navigationBarCustomization() {
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = WHITE_COLOR
        // Add a custom title view to the navigation bar.
        let navigationBarTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        navigationBarTitleLabel.text = "Pluto - Beta"
        navigationBarTitleLabel.textColor = WHITE_COLOR
        navigationBarTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        navigationItem.titleView = navigationBarTitleLabel
    }
    
    func setUpNavigationBarButtons() {
        
        navigationItem.rightBarButtonItems = [logoutButtonItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBarButtons()
        
        // Change the background color of the view.
        view.backgroundColor = DARK_BLUE_COLOR

        navigationBarCustomization()
        
        // Add the UI components.
        view.addSubview(menuBar)
        view.addSubview(mainCollectionView)
        
        // Set up constraints for the UI components.
        setUpMenuBar()
        
        checkIfUserLoggedIn()
    }
    
    func checkIfUserLoggedIn() {
                
        // If a user is not logged in, get the hell outta here.
        if Auth.auth().currentUser?.uid == nil {
            
            // Without the following line, a warning appears and tells us that we have too many controllers while the app is starting. To fix, add the following:
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            
        } else {
            
            setUpMainCollectionView()
        }
    }
    
    func setUpMenuBar() {
    
        // Add X, Y, width, and height constraints to the menuBar.
        menuBar.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        menuBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menuBar.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        menuBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setUpMainCollectionView() {
                
        if let flowLayout = mainCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            // Make the mainCollectionView flow horizontally.
            flowLayout.scrollDirection = .horizontal
            
            // Take out the gap between cells.
            flowLayout.minimumLineSpacing = 0
        }
        
        // Add X, Y, width, and height constraints to the mainCollectionView.
        mainCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainCollectionView.topAnchor.constraint(equalTo: menuBar.bottomAnchor).isActive = true
        mainCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mainCollectionView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        // Register cell classes in the mainCollectionView.
        mainCollectionView.register(MapCell.self, forCellWithReuseIdentifier: mapCellId)
        mainCollectionView.register(ChatCell.self, forCellWithReuseIdentifier: chatCellId)
        
        // The top of each section is hidden by the menuBar. So adjust the content and the scroll.
        let contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        mainCollectionView.contentInset = contentInset
        mainCollectionView.scrollIndicatorInsets = contentInset
    }
    
    func scrollToMenu(index: Int) {
        
        let indexPath = NSIndexPath(item: index, section: 0)
        
        // Scroll to the given index in the menuBar and the mainCollectionView.
        mainCollectionView.scrollToItem(at: indexPath as IndexPath, at: [], animated: true)
    }
    
    // MARK: - Collection View Functions
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Change the menuBar's underline bar position to match the cell being shown.
        menuBar.horizontalUnderlineBarViewLeftAnchor?.constant = scrollView.contentOffset.x/2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Return a section for every menu bar tab.
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Return a size that covers the view.
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 0 {
        
            let mapCell = collectionView.dequeueReusableCell(withReuseIdentifier: mapCellId, for: indexPath) as! MapCell
         
            mapCell.mainController = self
            
            return mapCell
        
        } else if indexPath.item == 1 {
            
            let chatCell = collectionView.dequeueReusableCell(withReuseIdentifier: chatCellId, for: indexPath) as! ChatCell
            
            chatCell.mainController = self
            
            return chatCell
        }
        
        return UICollectionViewCell()
    }
}
