//
//  Routes.swift
//  Rush01
//
//  Created by Artem KUPRIIANETS on 20/04/2019.
//  Copyright © 2019 Artem Kupriianets. All rights reserved.
//

import Foundation
import MapKit

struct Routes {
    var depCoord = CLLocation()
    var arrCoord = CLLocation()
    var doRoutes = false
    var mainWay: Bool?
    var userTapped = false
    static let shared = Routes()
    
    func getRoutesLocations() -> (CLLocationCoordinate2D, CLLocationCoordinate2D)? {
        let departureLoc = CLLocationCoordinate2D(latitude: self.depCoord.coordinate.latitude, longitude: self.depCoord.coordinate.longitude)
        let destinationLoc = CLLocationCoordinate2D(latitude: self.arrCoord.coordinate.latitude, longitude: self.arrCoord.coordinate.longitude)
        return (departureLoc, destinationLoc)
    }
    
    func getDirReguestObj(departure: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) -> MKDirectionsRequest {
        let depPlacemark = MKPlacemark(coordinate: departure)
        let destPlacemark = MKPlacemark(coordinate: destination)
        
        let dirRequestObj = MKDirectionsRequest()
        dirRequestObj.source = MKMapItem(placemark: depPlacemark)
        dirRequestObj.destination = MKMapItem(placemark: destPlacemark)
        dirRequestObj.requestsAlternateRoutes = true
        return (dirRequestObj)
    }
    
    func setupDateForm() -> DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter
    }
    
    func setupMainRoute(route: MKRoute, formatter: DateComponentsFormatter) -> (routeDist: Double, timeLabel: String) {
        var routeTimeSec = route.expectedTravelTime.magnitude
        let routeDist = Double(route.distance / 1000)
        let secaDay: Double = 86400
        let rts = Int(routeTimeSec / secaDay)
        if rts > 0 {
            routeTimeSec -= Double(rts * Int(secaDay))
        }
        let tempRouteTime = formatter.string(from: TimeInterval(routeTimeSec))!
        let timeLabel = (rts > 0 ? String(rts) + " d, " : "") + String(tempRouteTime)
        return (routeDist, timeLabel)
    }
}
