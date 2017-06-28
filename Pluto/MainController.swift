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
    
    let mapView: MKMapView = {
        
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        
        return map
    }()
    
    // MARK: - Global Variables
    
    let cellId = "sectionCell"
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationAuthStatus()
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
        //view.addSubview(mapView)
        
        // Set up constraints for the UI components.
        setUpMenuBar()
        setUpNavigationBarButtons()
        setUpCollectionView()
        //setUpMapView()
        
        // Register a cell class in the collectionView.
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        // Set up any necessary delegates.
        mapView.delegate = self
        
        // The following line will allow the map to follow the user's location.
        mapView.userTrackingMode = .follow
        
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
    
    func setUpMapView() {
        
        // Add X, Y, width, and height constraints to the mapView.
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: menuBar.bottomAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        let colors: [UIColor] = [.green, .blue, .red, .purple]
        
        cell.backgroundColor = colors[indexPath.item]
        
        return cell
    }
    
    // MARK: - Map View Functions
    
    func locationAuthStatus() {
        
        // Check if the user has given permission to use their location.
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            // Show the user's location.
            mapView.showsUserLocation = true
            
        } else {
            
            // Request the user's location.
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Check if the user has given permission to use their location.
        if status == .authorizedWhenInUse {
            
            // Show the user's location.
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        // Specify a region to show.
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        // Show the region.
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        // We want to zoom to the user's location, but ONLY the first time the map loads.
        
        if let loc = userLocation.location {
            
            if !mapHasCenteredOnce {
                
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
}
