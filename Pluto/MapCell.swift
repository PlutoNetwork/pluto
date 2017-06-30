//
//  MainCollectionViewCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import Kingfisher

class MapCell: BaseCollectionViewCell, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UI Components
    
    lazy var mapView: MKMapView = {
        
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        
        return map
    }()
    
    // MARK: - Global Variables
        
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    var geoFire: GeoFire!
    
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
        
        // The following line will allow the map to follow the user's location.
        mapView.userTrackingMode = .follow
        
        // Add a long press gesture to the mapView.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapViewPointLongPressed(gestureRecognizer:)))
        longPressGesture.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
        
        // Set up GeoFire.
        geoFire = GeoFire(firebaseRef: DataService.ds.REF_EVENT_LOCATIONS)
    }
    
    func setUpMapView() {
        
        // Add X, Y, width, and height constraints to the mapView.
        mapView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    func showEventsOnMap(location: CLLocation) {
        
        // Create a query that shows events within a given radius.
        let circleQuery = geoFire.query(at: location, withRadius: 2.5)
        
        // Whenever a key is found, show an event.
        _ = circleQuery?.observe(.keyEntered, with: { (key, location) in
            
            // First check if the key and location exist, because the query may not find anything.
            if let key = key, let location = location {
                
                EventService.sharedInstance.fetchEvents(withKey: key, completion: { (event) in
                    
                    // Create an annotation with the event's data.
                    let eventAnnotation = EventAnnotation(coordinate: location.coordinate, title: event.title, imageUrl: event.imageUrl, count: event.count)
                    
                    // Add the eventAnnotation to the mapView.
                    self.mapView.addAnnotation(eventAnnotation)
                })
            }
        })
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
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        let currentLoc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showEventsOnMap(location: currentLoc)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let eventAnnotationIdentifier = "event"
        var eventAnnotationView: MKAnnotationView?
        
        // Create an imageView to show instead of the annotation pin.
        let eventImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        eventImageView.contentMode = .scaleAspectFill
        
        eventImageView.layer.masksToBounds = true
        
        if annotation.isKind(of: MKUserLocation.self) {
            
            // This annotationView specficially refers to the user's current location.
            eventAnnotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            
            // We need the user's profile picture.
            UserService.sharedInstance.fetchUserData(completion: { (name, profileImageUrl) in
                
                // Set the eventAnnotationView (really the userAnnotationView)'s image to the user's profile picture.
                // Use the Kingfisher library.
                let url = URL(string: profileImageUrl)
                eventImageView.kf.setImage(with: url)
                
                // Make the eventImageView bigger to assert the user's dominance.
                eventImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                
                // Add the eventImageView to the eventAnnotationView.
                eventAnnotationView?.addSubview(eventImageView)
                
                // Round the eventImageView with the new frame.
                eventImageView.layer.cornerRadius = eventImageView.layer.frame.size.width/2
                
            })
        } else if let deqAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: eventAnnotationIdentifier) {
            
            eventAnnotationView = deqAnnotation
            eventAnnotationView?.annotation = annotation
            
        } else {
            
            let defaultAnnotation = MKAnnotationView(annotation: annotation, reuseIdentifier: eventAnnotationIdentifier)
            defaultAnnotation.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            eventAnnotationView = defaultAnnotation
        }
        
        if let eventAnnotationView = eventAnnotationView, let eventAnnotation = annotation as? EventAnnotation {
            
            eventAnnotationView.canShowCallout = true
            
            // Create a button for directions that shows when the user taps on the annotation.
            let mapButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            mapButton.setImage(UIImage(named: "map_icon"), for: .normal)
            eventAnnotationView.rightCalloutAccessoryView = mapButton
            
            // Round the eventImageView.
            eventImageView.layer.cornerRadius = eventImageView.layer.frame.size.width / 2
            
            // Download each event's image using the Kingfisher library.
            let url = URL(string: eventAnnotation.imageUrl)
            eventImageView.kf.setImage(with: url)
            
            // Add the eventImageView to the eventAnnotationView.
            eventAnnotationView.addSubview(eventImageView)
            
            // We can't click on the annotation anymore because the eventAnnotationView is too small, so change its size to match the eventImageView's size.
            eventAnnotationView.frame = eventImageView.frame
        }
        
        return eventAnnotationView
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
