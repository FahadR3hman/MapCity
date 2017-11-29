//
//  DroppablePin.swift
//  MapCity
//
//  Created by Fahad Rehman on 11/28/17.
//  Copyright © 2017 Codecture. All rights reserved.
//

import Foundation
import MapKit

class DroppablePin : NSObject , MKAnnotation {
  dynamic  var coordinate: CLLocationCoordinate2D
    var identifier : String
    
     init(coordiante : CLLocationCoordinate2D , identifier : String) {
        self.coordinate = coordiante
        self.identifier = identifier
        super.init()
    }
    
    
}
