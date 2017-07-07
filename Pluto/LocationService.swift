//
//  LocationService.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/7/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import Foundation
import Eureka

struct LocationService {
    
    static let sharedInstance = LocationService()
    
    func convertCoordinatesToAddress(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String) -> ()) {
        
        // Turn the coordinate into an address.
        let geoCoder = CLGeocoder()
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            
            // Grab fully formatted address.
            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                
                let address = formattedAddress.joined(separator: ", ")
                
                // Return the address.
                completion(address)
            }
        })
    }
}
