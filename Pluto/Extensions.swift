//
//  Extensions.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/4/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import Foundation
import Kingfisher

extension UIColor {
    
    // Makes color declaration easier.
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        
        self.init(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}

extension String {
 
    // Truncates the string and ends it with an elipsis.
    func trunc(length: Int, trailing: String? = "...") -> String {
        
        if self.characters.count > length {
            
            return self.substring(to: self.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
            
        } else {
            return self
        }
    }
    
    // Converts strings to dates.
    func toDate() -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        return dateFormatter.date(from: self)!
    }
}

extension UIImageView {
    
    // Sets the image with the Kingfisher library.
    func setImageWithKingfisher(url: String) {
        
        // Always masksToBounds for cornerRadius.
        self.layer.masksToBounds = true
        
        // Set the image.
        let url = URL(string: url)
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url)
    }
}

extension Date {
    // Converts dates to strings.
    func toString() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        return dateFormatter.string(from: self)
    }
}
