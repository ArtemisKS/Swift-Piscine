//
//  GMSAnnotation.swift
//  Rush01
//
//  Created by Artem KUPRIIANETS on 07/05/2019.
//  Copyright © 2019 Artem Kupriianets. All rights reserved.
//

import UIKit
import GoogleMaps

class GMSAnnotation: GMSMarker {
    
    var isBeingDragged: Bool = false
    var wasDragged: Bool = false
    
    init(data: (title: String, snippet: String?), coord: CLLocationCoordinate2D, isDraggable: Bool, attachTo mapView: GMSMapView) {
        super.init()
        editGMSMarker(data: data, coord: coord, isDraggable: isDraggable, mapView: mapView)
    }
    
    private func editGMSMarker(data: (title: String, snippet: String?), coord: CLLocationCoordinate2D, isDraggable: Bool, mapView: GMSMapView){
        self.title = data.title
        self.position = coord
        if let snip = data.snippet {
            self.snippet = snip
        }
        self.map = mapView
        self.appearAnimation = GMSMarkerAnimation.pop
        self.isDraggable = isDraggable
    }

}
