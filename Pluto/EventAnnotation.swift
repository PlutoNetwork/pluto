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
    var title: String?
    var imageUrl: String
    
    init(coordinate: CLLocationCoordinate2D, title: String, imageUrl: String) {
        
        self.coordinate = coordinate
        self.title = title
        self.imageUrl = imageUrl
    }
}
