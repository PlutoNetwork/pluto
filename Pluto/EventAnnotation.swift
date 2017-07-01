//
//  EventAnnotation.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/28/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import Foundation

class EventAnnotation: NSObject, MKAnnotation {
    
    var coordinate = CLLocationCoordinate2D()
    var eventKey: String
    var title: String?
    var image: String
    var count: Int
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, eventKey: String, title: String, image: String, count: Int) {
        
        self.coordinate = coordinate
        self.eventKey = eventKey
        self.title = title
        self.image = image
        self.count = count
        self.subtitle = "\(self.count) going"
    }
}
