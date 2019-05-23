//
//  GMViewController.swift
//  Rush01
//
//  Created by Artem KUPRIIANETS on 20/04/2019.
//  Copyright © 2019 Artem Kupriianets. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import MapKit

class GMViewController: UIViewController {

    @IBOutlet weak var depLocTextField: UITextField!
    @IBOutlet weak var arrLocTextField: UITextField!
    @IBOutlet weak var transType: UISegmentedControl!
    @IBOutlet weak var wayButton: UIButton!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var distRoute: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapTabBarItem: UITabBarItem!
    
    let locationManager = CLLocationManager()
    var curCoord: CLLocationCoordinate2D?
    var marker: GMSAnnotation?
    var routes: Routes = Routes()
    var locChosen: Location = .depLocation
    var waysDisplayed = false
    var pinsArr = [GMSMarker]()
    var transChosen = trType.auto
    var destStr = ""
    var depStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.isTrafficEnabled = true
        Utils.displayRouteViews(views: [firstView, distRoute], isHidden: true)
        Utils.setupUser(locationManager: locationManager, vc: self, views: [wayButton, distRoute, depLocTextField, arrLocTextField])
        mapView.settings.myLocationButton = true
//        mapTabBarItem.imageInsets = UIEdgeInsetsMake(12, 12, 12, 12)
    }
    
    @IBAction func setGeoLoc(_ sender: UIButton) {
        if let geoLoc = curCoord {
            let depLoc = sender.tag == 0
            let loc = CLLocation(latitude: geoLoc.latitude, longitude: geoLoc.longitude)
            depLoc ? (depLocTextField.text = "Your location") : (arrLocTextField.text = "Your location")
            depLoc ? (routes.depCoord = loc) : (routes.arrCoord = loc)
        }
    }
    
    @IBAction func depPlace(_ sender: UITextField) {
        launchGMSAutoComp(locChosen: &locChosen, loc: .depLocation)
    }
    
    @IBAction func arrPlace(_ sender: UITextField) {
        launchGMSAutoComp(locChosen: &locChosen, loc: .destLocation)
    }
    
    @IBAction func dispRoutesView(_ sender: UIButton) {
        if !firstView.isHidden {
            Utils.displayRouteViews(views: [firstView, distRoute], isHidden: true)
        } else {
            firstView.isHidden = false
            if waysDisplayed == true {
                distRoute.isHidden = false
            }
        }
    }
    
    @IBAction func vehicleType(_ sender: UISegmentedControl) {
        let segment = Int(transChosen.hashValue)
        transType.setImage(segment == 0 ? UIImage(named: "auto") :  UIImage(named: "walk"), forSegmentAt: segment)
        switch sender.selectedSegmentIndex {
        case 0:
            transChosen = trType.auto
        default:
            transChosen = trType.walk
        }
    }
    
    @IBAction func alterTypeMap(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .normal
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .terrain
        }
    }
    
    @IBAction func getRoute(_ sender: UIButton) {
        Utils.displayRouteViews(views: [firstView, distRoute], isHidden: true)
        if !((arrLocTextField.text?.isEmpty)!) && !((depLocTextField.text?.isEmpty)!) {
            pinsArr.forEach({ $0.map = nil })
            pinsArr.removeAll()
            guard let (departureLoc, destinationLoc) = routes.getRoutesLocations() else { return }
            guard let (url, curTrType) = getRoutesUrl(departureLoc: departureLoc, destinationLoc: destinationLoc) else { return }
            mapView.clear()
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let err = error {
                    Utils.alert(title: nil, message: err.localizedDescription, prefStyle: .alert, handler: nil, vc: self)
                }
                else {
                    guard let data = data else { return }
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                            if let err = json["status"] as? String, let message = json["error_message"] as? String {
                                Utils.alert(title: err, message: message, prefStyle: .alert, handler: nil, vc: self)
                                return
                            }
                            guard let routesArr = json["routes"] as? NSArray, routesArr.count != 0 else {
                                Utils.alert(title: json["status"] as? String, message: "Unexpected GMS response", prefStyle: .alert, handler: nil, vc: self)
                                return
                            }
                            OperationQueue.main.addOperation {
                               self.drawRoutes(routesArr: routesArr, curTrType: curTrType)
                            }
                        }
                    }
                    catch let error as NSError{
                        Utils.alert(title: nil, message: error.localizedDescription, prefStyle: .alert, handler: nil, vc: self)
                    }
                }
            }).resume()
            pinsArr.append(contentsOf: [GMSAnnotation(data: (depStr, nil), coord: departureLoc, isDraggable: false, attachTo: self.mapView), GMSAnnotation(data: (destStr, nil), coord: destinationLoc, isDraggable: false, attachTo: self.mapView)])
            waysDisplayed = true
            routes.doRoutes = true
        } else if ((arrLocTextField.text?.isEmpty)!) {
            Utils.alert(title: nil, message: "Bitte, set destination of the route", prefStyle: .alert, handler: nil, vc: self)
        }
        else {
            Utils.alert(title: nil, message: "Bitte, set departure of the route", prefStyle: .alert, handler: nil, vc: self)
        }
    }
}

extension GMViewController: MKMapViewDelegate, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let locCho = locChosen == .destLocation
        setRoutePoints(place: place, isDeparture: locCho ? false : true)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: GMSMarker Dragging
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        marker.opacity = 0.75
        if let gmsann = marker as? GMSAnnotation {
            gmsann.isBeingDragged = true
        }
    }

    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        marker.opacity = 1
        if let gmsann = marker as? GMSAnnotation {
            gmsann.isBeingDragged = false
            gmsann.wasDragged = true
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        Utils.alert(title: nil, message: "Error: \(error.localizedDescription)", prefStyle: .alert, handler: nil, vc: self)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        routes.userTapped = true
        reverseGeocodeLocation(coordinate)
    }
//
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        marker.opacity = 0.75
//        return true
//    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        guard !routes.doRoutes else { return }
        if marker == nil || !marker!.isBeingDragged {
            if let m = marker, m.wasDragged {
                m.wasDragged = false
                return
            }
            let target = position.target
            reverseGeocodeLocation(target)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Utils.alert(title: nil, message: "Error while obtaining location: \(error.localizedDescription)", prefStyle: .alert, handler: nil, vc: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        curCoord = location.coordinate
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        mapView.isMyLocationEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            Utils.alert(title: nil, message: "Please, allow the app to access your location", prefStyle: .alert, handler: nil, vc: self)
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        routes.doRoutes = false
        return false
    }
    
    //MARK: helper route funcs
    
    private func getRoutesUrl(departureLoc: CLLocationCoordinate2D, destinationLoc: CLLocationCoordinate2D) -> (URL, String)? {
        if departureLoc.isEqual(to: destinationLoc) {
            Utils.alert(title: nil, message: "Please, set distinct locations", prefStyle: .alert, handler: nil, vc: self)
            Utils.displayRouteViews(views: [firstView, distRoute], isHidden: false)
            return nil
        }
        let dep = "\(departureLoc.latitude),\(departureLoc.longitude)"
        let dest = "\(destinationLoc.latitude),\(destinationLoc.longitude)"
        var curTrType = "driving"
        if transChosen == trType.walk {
            curTrType = "walking"
        }
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(dep)&destination=\(dest)&mode=\(curTrType)&key=\(planAPI)"
        guard let url = URL(string: urlString) else {
            Utils.alert(title: nil, message: "GMS url is invalid", prefStyle: .alert, handler: nil, vc: self)
            return nil
        }
        return (url, curTrType)
    }
    
    private func drawRoutes(routesArr: NSArray, curTrType: String) {
        for (index, route) in routesArr.enumerated() {
            let routeOverviewPolyline = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
            let legs = (route as! NSDictionary).value(forKey: "legs") as! NSArray
            let points = routeOverviewPolyline.object(forKey: "points")
            let path = GMSPath.init(fromEncodedPath: points! as! String)
            let polyline = GMSPolyline.init(path: path)
            if (index == 0) {
                if curTrType != "walking" {
                    polyline.strokeColor = UIColor(red: 0.1804, green: 0.1961, blue: 0.9686, alpha: 1.0)
                    polyline.strokeWidth = 5
                }
                let routeDistDict = (legs.firstObject as! NSDictionary).value(forKey: "distance") as! NSDictionary
                let timeLabelDict = (legs.firstObject as! NSDictionary).value(forKey: "duration") as! NSDictionary
                let routeDist = routeDistDict.value(forKey: "text") as! String
                let timeLabel = timeLabelDict.value(forKey: "text") as! String
                self.distRoute.text = routeDist
                self.transType.setTitle(timeLabel, forSegmentAt: Int(self.transChosen.hashValue))
                Utils.displayRouteViews(views: [self.firstView, self.distRoute], isHidden: false)
            }
            else {
                polyline.strokeColor = Utils.getRandomColor()
                polyline.strokeWidth = 2.1
            }
            let bounds = GMSCoordinateBounds(path: path!)
            self.mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 80.0))
            polyline.map = self.mapView
        }
    }
    
    //MARK: Pieces of different actions encapsulated into functions
    
    private func setRoutePoints(place: GMSPlace, isDeparture: Bool) {
        let str = String(describing: place.name)
        let address = "\(String(describing: place.formattedAddress!))"
        let loc = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        isDeparture ? (depStr = str) : (destStr = str)
        isDeparture ? (depLocTextField.text = address) : (arrLocTextField.text = address)
        isDeparture ? (routes.depCoord = loc) : (routes.arrCoord = loc)
    }
    
    private func launchGMSAutoComp(locChosen: inout Location, loc: Location) {
        let autoCompVC = GMSAutocompleteViewController()
        autoCompVC.delegate = self
        locChosen = loc
        UISearchBar.appearance().setTextColor(color: UIColor.black)
        locationManager.stopUpdatingLocation()
        present(autoCompVC, animated: true, completion: nil)
    }
    
    private func geocodeCompHandler(revGeoLoc :GMSReverseGeocodeResponse?, coord: CLLocationCoordinate2D) {
        guard let address = revGeoLoc?.firstResult(), let lines = address.lines, (!self.routes.doRoutes || routes.userTapped) else {
            return
        }
        self.addressLabel.text = lines.joined(separator: "\n")
        let labelHeight = self.addressLabel.intrinsicContentSize.height
        self.mapView.padding = UIEdgeInsetsMake(self.view.safeAreaInsets.top, 0, labelHeight, 0)
        if let mark = self.marker {
            mark.map = nil
        }
        let title = lines.first ?? "Map center"
        self.marker = GMSAnnotation(data: (title, lines.count > 1 ? lines[1] : nil), coord: coord, isDraggable: true, attachTo: self.mapView)
        if routes.userTapped {
            routes.userTapped = false
        }
        UIView.animate(withDuration: Data.layoutAnimTime, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func reverseGeocodeLocation(_ coord: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coord) { (response, error) in
            if let error = error {
                Utils.alert(title: nil, message: error.localizedDescription, prefStyle: .alert, handler: nil, vc: self)
            }
            self.geocodeCompHandler(revGeoLoc: response, coord: coord)
        }
    }
}
