//
//  FirstViewController.swift
//  D05
//
//  Created by Artem KUPRIIANETS on 1/21/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FirstViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, LocationProtocol { // this class is delegated for the map and for the location manager
    var locationManager = CLLocationManager()
    var secondVC: SecondViewController?
    var prevLocation: CLLocation?
    
    var isUpdatingLoc: Bool = false
    @IBOutlet weak var myMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        secondVC = self.tabBarController?.viewControllers?.last as! SecondViewController?
        secondVC?.delegate = self
        
        myMapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 10
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestLocation()
        myMapView.showsUserLocation = true
        myMapView.userTrackingMode = .follow
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 50.468981, longitude: 30.462142)
        annotation.title = "UNIT Factory"
        annotation.subtitle = "The (in)famous coding school"
        let span = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        myMapView.setRegion(region, animated: true)
        
        myMapView.addAnnotation(annotation)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//            print("locations = \(locValue.latitude) \(locValue.longitude)")
//        }

    @IBAction func geoLoc(_ sender: UIButton) {
        if let location = locationManager.location
        {
            isUpdatingLoc = true
            prevLocation = location
            let coord = location.coordinate
            print("Successful Geolocalisation : \(String(describing: coord))")
            let span = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coord, span: span)
            myMapView.setRegion(region, animated: true)
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
//                annotation.title = "London"
//                annotation.subtitle = "The capital of Great Britain, baby"
//                myMapView.addAnnotation(annotation)
        }
    }

    @IBAction func segButton(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            myMapView.mapType = .standard
        case 1:
            myMapView.mapType = .satellite
        default:
            myMapView.mapType = .hybrid
        }
    }

//        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            print("Updated position: \(String(describing: manager.location?.coordinate))")
//        }

// implementation of the LocationProtocol protocol
    func updateLocation(newLocation : Location) {
        print("updateLocation")
        let coord = CLLocationCoordinate2D(latitude: newLocation.latitude, longitude: newLocation.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coord, span: span)
        myMapView.setRegion(region, animated: true)
    }
    func setPins(locations : [Location]) {
        print("setPins")
        for loc in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            annotation.title = loc.name
            annotation.subtitle = loc.desc
            myMapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("mapView : annotation = \(annotation)")
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
        }
 
        if annotation.subtitle??.range(of:"Tourism") != nil {
            view.pinTintColor = UIColor.green
        }
        else if annotation.subtitle??.range(of:"school") != nil {
            view.pinTintColor = UIColor.blue
        }
        else if annotation.subtitle??.range(of:"sport") != nil {
            view.pinTintColor = UIColor.purple
        }
        else {
            view.pinTintColor = UIColor.red
        }
        return view
    }
}

extension FirstViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            print("our coords: \(lat),\(long)")
            lookUpCurrentLocation { geoLoc1 in
                print("current geolocation is " + (geoLoc1?.locality ?? "unknown"))
            }
            if isUpdatingLoc {
                if let pl = prevLocation {
                    let plat = pl.coordinate.latitude
                    let plong = pl.coordinate.longitude
                    if abs(lat - plat) + abs(long - plong) > 0.005 {
                        let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        let span = MKCoordinateSpan(latitudeDelta: 0.01,longitudeDelta: 0.01)
                        let region = MKCoordinateRegion(center: coord, span: span)
                        myMapView.setRegion(region, animated: true)
                        prevLocation = location
                    }
                }
                else {
                    prevLocation = location
                }
            }
        } else {
            print("No coordinates")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?.first
                    completionHandler(firstLocation)
                }
                else {
                    completionHandler(nil)
                }
            })
        }
        else {
            completionHandler(nil)
        }
    }
}
