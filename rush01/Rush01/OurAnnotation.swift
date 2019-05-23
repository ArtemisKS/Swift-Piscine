//
//  OurAnnotation.swift
//  Rush01
//
//  Created by Artem KUPRIIANETS on 28/01/2019.
//  Copyright © 2019 Artem Kupriianets. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class OurAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String?, location: CLLocationCoordinate2D) {
        self.title = title
        if let subtitle = subtitle {
            self.subtitle = subtitle
        }
        self.coordinate = location
    }
}

