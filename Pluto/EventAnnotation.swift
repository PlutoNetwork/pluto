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
    
    init(coordinate: CLLocationCoordinate2D, event: Event?) {
        
        self.coordinate = coordinate
        self.event = event
    }
}
