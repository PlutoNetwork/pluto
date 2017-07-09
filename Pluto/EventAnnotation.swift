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
    var event: Event?
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, event: Event?, title: String) {
        
        self.coordinate = coordinate
        self.event = event
        self.title = title
    }
}
