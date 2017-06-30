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
    var count: Int
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, imageUrl: String, count: Int) {
        
        self.coordinate = coordinate
        self.title = title
        self.imageUrl = imageUrl
        self.count = count
        self.subtitle = "\(self.count) people going"
    }
}
