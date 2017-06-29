//
//  MainCollectionViewCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import MapKit

class MapCell: BaseCollectionViewCell, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UI Components
    
    let mapView: MKMapView = {
        
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        
        return map
    }()
    
    // MARK: - Global Variables
        
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    // MARK: - View Configuration
    
    override func setUpViews() {
        super.setUpViews()
        
        // Change the background color of the cell.
        backgroundColor = .clear
        
        locationAuthStatus()
        
        // Add the UI components.
        addSubview(mapView)
        
        // Set up constraints for the UI components.
        setUpMapView()
        
        // Set up any necessary delegates.
        mapView.delegate = self
        
        // The following line will allow the map to follow the user's location.
        mapView.userTrackingMode = .follow
        
        // Add a long press gesture to the mapView.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapViewPointLongPressed(gestureRecognizer:)))
        longPressGesture.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    func setUpMapView() {
        
        // Add X, Y, width, and height constraints to the mapView.
        mapView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
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
    
    func mapViewPointLongPressed(gestureRecognizer: UIGestureRecognizer){
        
        // The longPressGestureRecognizer is called twice: when it starts, and when it ends.
        // We need to seperate these states.
        
        if gestureRecognizer.state == .began {
            
            // Create a coordinate from the point pressed.
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            // Pass the coordinate to the EventDetailsController.
            let eventDetailsController = EventDetailsController()
            eventDetailsController.coordinate = coordinate
            
            // Open the EventDetailsController.
            mainController?.navigationController?.pushViewController(eventDetailsController, animated: true)
        }
    }
}
