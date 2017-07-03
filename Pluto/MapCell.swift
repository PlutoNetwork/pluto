//
//  MainCollectionViewCell.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Kingfisher
import BadgeSwift

class MapCell: BaseCollectionViewCell, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - UI Components
    
    lazy var mapView: MKMapView = {
        
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.delegate = self
        
        return map
    }()
    
    // MARK: - Global Variables
    
    var locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    var geoFire: GeoFire!
    
    // MARK: - View Configuration
    
    override func setUpViews() {
        super.setUpViews()
        
        // Change the background color of the cell.
        backgroundColor = .clear
        
        locationAuthStatus()
        
        // Set up the location manager.
        setUpLocationManager()
        
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
    
    func setUpLocationManager() {
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func showEventsOnMap(location: CLLocation) {
    
        // Create a query that shows events within a given radius.
        let circleQuery = geoFire.query(at: location, withRadius: 2.5)
        
        // Whenever a key is found, show an event.
        _ = circleQuery?.observe(.keyEntered, with: { (key, location) in
            
            // First check if the key and location exist, because the query may not find anything.
            if let key = key, let location = location {
                
                DispatchQueue.global(qos: .background).async {
                    
                    EventService.sharedInstance.fetchEvents(withKey: key, completion: { (event) in
                        
                        // Check if the user is the event creator.
                        EventService.sharedInstance.checkIfUserIsGoingToEvent(withKey: key, completion: { (isUserGoing) in
                            
                            DispatchQueue.main.async {
                                
                                // Create an annotation with the event's data.
                                let eventAnnotation = EventAnnotation(coordinate: location.coordinate, eventKey: event.key, title: event.title, image: event.image, count: event.count, isUserGoing: isUserGoing)
                                
                                // Add the eventAnnotation to the mapView.
                                self.mapView.addAnnotation(eventAnnotation)
                            }
                        })
                    })
                }
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
        
        // Handle authorization for the location manager.
        
        switch status {
            
        case .restricted:
            
            print("INFO: Location access was restricted.")
            
        case .denied:
            
            print("INFO: User denied access to location.")
            SCLAlertView().showWarning("Hey!", subTitle: "You denied permission to use your location, which destroys the purpose of Pluto. Don't worry - we aren't using your location in the background or showing it to others. Please fix this in your Settings.")
            
        case .notDetermined:
            
            print("INFO: Location status not determined.")
            locationAuthStatus()
            
        case .authorizedAlways: fallthrough
            
        case .authorizedWhenInUse:
            
            // Show the user's location.
            mapView.showsUserLocation = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        // Handle location manager errors.
        
        locationManager.stopUpdatingLocation()
        
        print("ERROR: there was an error updating the location \(error)")
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        // Specify a region to show.
        let span = MKCoordinateSpanMake(0.003, 0.003)
        let coordinateRegion = MKCoordinateRegionMake(location.coordinate, span)
        
        // Show the region.
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        // We want to zoom to the user's location, but ONLY the first time the map loads.
        
        if let loc = userLocation.location {
            
            if !mapHasCenteredOnce {
                
                centerMapOnLocation(location: loc)
                showEventsOnMap(location: loc)
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
            UserService.sharedInstance.fetchCurrentUserData(completion: { (name, profileImageUrl) in
                
                // Set the eventAnnotationView (really the userAnnotationView)'s image to the user's profile picture.
                // Use the Kingfisher library.
                let url = URL(string: profileImageUrl)
                eventImageView.kf.setImage(with: url)
                
                // Make the eventImageView bigger to assert the user's dominance.
                eventImageView.frame = CGRect(x: 0, y: 0, width: 75, height: 75)
                
                // Add a border around the image.
                eventImageView.layer.borderWidth = 5
                eventImageView.layer.borderColor = LIGHT_BLUE_COLOR.cgColor
                
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
    
            // Change the calloutButton accordingly.
            if eventAnnotation.isUserGoing {
                
                eventAnnotationView.rightCalloutAccessoryView = self.annotationCalloutButton(image: UIImage(named: "ic_done")!)
                
            } else {
                
                eventAnnotationView.rightCalloutAccessoryView = self.annotationCalloutButton(image: UIImage(named: "ic_add")!)
            }
            
            // Set the image.
            let image = eventAnnotation.image
            eventAnnotationView.image = UIImage(named: image)
            
            // Add a badge that shows the number of people going using the BadgeSwift library.
            let eventCountBadge = BadgeSwift()
            eventCountBadge.text = "\(eventAnnotation.count)"
            eventCountBadge.textColor = WHITE_COLOR
            eventCountBadge.badgeColor = LIGHT_BLUE_COLOR
            eventCountBadge.translatesAutoresizingMaskIntoConstraints = false
            eventAnnotationView.addSubview(eventCountBadge)
            
            // Add X, Y, width, and height constraints to the eventCountBadge.
            eventCountBadge.centerXAnchor.constraint(equalTo: eventAnnotationView.centerXAnchor).isActive = true
            eventCountBadge.centerYAnchor.constraint(equalTo: eventAnnotationView.centerYAnchor, constant: eventAnnotationView.frame.height/2).isActive = true
            eventCountBadge.widthAnchor.constraint(equalToConstant: 25).isActive = true
            eventCountBadge.heightAnchor.constraint(equalToConstant: 25).isActive = true
        }
        
        return eventAnnotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let eventAnnotation = view.annotation as? EventAnnotation {
            
            // Change the eventAnnotation information.
            eventAnnotation.isUserGoing = !eventAnnotation.isUserGoing
            
            let eventKey = eventAnnotation.eventKey
            
            DispatchQueue.global(qos: .background).async {
                
                // Download the event data from Firebase so we can adjust the count.
                EventService.sharedInstance.fetchSingleEvent(withKey: eventKey) { (event) in
                    
                    EventService.sharedInstance.changeEventCount(event: event) {
                        
                        // Refresh the annotations on the map.
                        DispatchQueue.main.async {
                                                        
                            // Change the calloutButton accordingly.
                            if eventAnnotation.isUserGoing {
                                
                                view.rightCalloutAccessoryView = self.annotationCalloutButton(image: UIImage(named: "ic_done")!)
                                eventAnnotation.count = eventAnnotation.count+1
                                
                            } else {
                                
                                view.rightCalloutAccessoryView = self.annotationCalloutButton(image: UIImage(named: "ic_add")!)
                                eventAnnotation.count = eventAnnotation.count-1
                            }
                        }
                    }
                }
            }
        }
    }
    
    func annotationCalloutButton(image: UIImage) -> UIButton {
        
        let calloutButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        calloutButton.setImage(image, for: .normal)
        
        return calloutButton
    }
    
    func mapViewPointLongPressed(gestureRecognizer: UIGestureRecognizer){
        
        // The longPressGestureRecognizer is called twice: when it starts, and when it ends.
        // We need to seperate these states.
        
        if gestureRecognizer.state == .began {
            
            // Create a coordinate from the point pressed.
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            // Pass the coordinate to the CreateEventController.
            let createEventController = CreateEventController()
            createEventController.coordinate = coordinate
            
            // Open the EventDetailsController.
            mainController?.navigationController?.pushViewController(createEventController, animated: true)
        }
    }
}
