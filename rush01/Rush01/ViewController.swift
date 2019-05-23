//
//  ViewController.swift
//  Rush01
//
//  Created by Artem KUPRIIANETS on 28/01/2019.
//  Copyright © 2019 Artem Kupriianets. All rights reserved.
//


import UIKit
import GooglePlaces
import GoogleMaps
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var depLocTextField: UITextField!
    @IBOutlet weak var arrLocTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var transType: UISegmentedControl!
    @IBOutlet weak var wayButton: UIButton!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var distRoute: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapTabBarItem: UITabBarItem!
    
    let locationManager = CLLocationManager()
    var transChosen = trType.auto
    var curTrType: MKDirectionsTransportType = .automobile
    
    var waysDisplayed = false
    var pinsArr = [OurAnnotation]()
    var curPin: OurAnnotation?

    var routes: Routes = Routes()
    var locChosen: Location = .depLocation
    
    var curCoord: CLLocationCoordinate2D?
    var myLocationPin = true
    var initialAppear = true
    var destStr = ""
    var depStr = ""
    var lastCentCoord: CLLocationCoordinate2D?
    var draggingMode = false
    var pinColor: UIColor?
    var snapshotView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Figure out how to reference instance's properties
//        var mvBoolVals = [#keyPath(MKMapView.showsScale), #keyPath(MKMapView.showsCompass), #keyPath(MKMapView.showsTraffic)]
//        var kpValArr = NSMutableArray()
//        for el in mvBoolVals {
//            if var shScale = mapView.value(forKey: mvBoolVals.first!) {
//                kpValArr.add(shScale)
//            }
//        }
////      kpValArr = mvBoolVals.map { self.mapView.value(forKey: $0)! }
////        if var shScale = mapView.value(forKey: mvBoolVals.first!) {
//        withUnsafePointer(to: &kpValArr[0], {
//            print("Address: \($0)")
//        })
////        }
////        for (index, _) in mvBoolVals.enumerated() {
////            withUnsafePointer(to: &mvBoolVals[index], {
////                print("Address of \(index + 1) element: \($0)")
////            })
////        }
//        withUnsafePointer(to: &mapView.showsScale, {
//            print("Address: \($0)")
//        })
//        Utils.setBoolValues(as: true, for: kpValArr)
//        Utils.displayRouteViews(views: [firstView, distRoute], isHidden: true)
//        withUnsafePointer(to: &kpValArr[0], {
//            print("Address: \($0)")
//        })
//        withUnsafePointer(to: &mapView.showsScale, {
//            print("Address: \($0)")
//        })
        mapView.showsTraffic = true
        mapView.showsCompass = true
        mapView.showsScale = true
        Utils.setupUser(locationManager: locationManager, vc: self, views: [wayButton, distRoute, depLocTextField, arrLocTextField])
        UISearchBar.appearance().setTextColor(color: UIColor.black)
//        mapTabBarItem.imageInsets = UIEdgeInsetsMake(12, 12, 12, 12)
        lastCentCoord = mapView.centerCoordinate
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userDidTap(sender:)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if initialAppear {
            setUserLoc()
        }
        initialAppear = false
    }
    
    func userDidDragPin(sender: UITapGestureRecognizer) {
        switch sender.state {
        case .changed:
            sender.view?.center = sender.location(in: sender.view?.superview)
        default:
            break
        }
    }
    
    @objc func userDidTap(sender: UITapGestureRecognizer) {
//        let deadlineTime = DispatchTime.now() + .milliseconds(100)
        switch sender.state {
        case .ended:
            let loc = sender.location(in: self.mapView)
            //            DispatchQueue.main.asyncAfter(deadline: deadlineTime, qos: .utility) {
            let coord = mapView.convert(loc, toCoordinateFrom: mapView)
            guard !Utils.pinIsTapped(tapLoc: loc, pins: mapView.annotations, mapView: mapView) else { return }
            routes.userTapped = true
            lookUpCurrentLocation(lastLocationCoord: coord, completionHandler: { (revGeoLoc) in
                self.geocodeCompHandler(revGeoLoc: revGeoLoc)
            })
        default:
            break
        }
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
        self.launchGMSAutoComp(locChosen: &locChosen, loc: .depLocation)
    }
    
    @IBAction func arrPlace(_ sender: UITextField) {
        self.launchGMSAutoComp(locChosen: &locChosen, loc: .destLocation)
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
        self.transType.setImage(segment == 0 ? UIImage(named: "auto") :  UIImage(named: "walk"), forSegmentAt: segment)
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
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .hybrid
        }
    }

    @IBAction func geoLoc(_ sender: UIButton) {
        routes.doRoutes = false
        setUserLoc()
    }
    
    @IBAction func getRoute(_ sender: UIButton) {
        Utils.displayRouteViews(views: [firstView, distRoute], isHidden: true)
        if !((arrLocTextField.text?.isEmpty)!) && !((depLocTextField.text?.isEmpty)!) {
            mapView.removeAnnotations(pinsArr)
            if let curPin = curPin {
                mapView.removeAnnotation(curPin)
            }
            mapView.removeOverlays(mapView.overlays)
            pinsArr.removeAll()
            
            guard let dirObj = getDirObject() else { return }
            dirObj.calculate { (response, error) in
                guard let dirResponse = response else {
                    if let error = error {
                        Utils.alert(title: nil, message: "Error while obtaining directions: \(error.localizedDescription)", prefStyle: .alert, handler: nil, vc: self)
                    }
                    return
                }
                self.routes.doRoutes = true
                self.displayRoutes(dirResponse: dirResponse)
            }
        } else if ((arrLocTextField.text?.isEmpty)!) {
            Utils.alert(title: nil, message: "Bitte, set destination of the route", prefStyle: .alert, handler: nil, vc: self)
        }
        else {
            Utils.alert(title: nil, message: "Bitte, set departure of the route", prefStyle: .alert, handler: nil, vc: self)
        }
    }
}

extension ViewController: MKMapViewDelegate, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate {
    
    // MARK: - locManager delegates
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Utils.alert(title: nil, message: "Error while obtaining location: \(error.localizedDescription)", prefStyle: .alert, handler: nil, vc: self)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locationManager.location else {
            return
        }
        curCoord = location.coordinate
        if let coord = curCoord {
            mapView.camera = MKMapCamera(lookingAtCenter: coord, fromDistance: 15, pitch: 0, heading: 0)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            Utils.alert(title: nil, message: "Please, allow the app to access your location", prefStyle: .alert, handler: nil, vc: self)
            return
        }
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - renderers for route overlays
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyRender = MKPolylineRenderer(overlay: overlay)
        if !(routes.mainWay!) || transChosen == .walk {
            polyRender.strokeColor = Utils.getRandomColor()
            polyRender.lineWidth = 2.1
        } else {
            polyRender.strokeColor = UIColor(red: 0.1804, green: 0.1961, blue: 0.9686, alpha: 1.0)
            polyRender.lineWidth = 5
        }
        return polyRender
    }
    
    // MARK: - snapshot maker
    
    func configureDetailView(annotationView: MKAnnotationView) {
        let width = 200.0
        let height = 134.0
        
//        while let subview = snapshotView.subviews.last {
//            subview.removeFromSuperview()
//        }
        snapshotView = UIView()
        let views = ["snapshotView": snapshotView]
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(\(width))]", options: [], metrics: nil, views: views))
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(\(height))]", options: [], metrics: nil, views: views))
        
        let options = MKMapSnapshotOptions()
        options.size = CGSize(width: width, height: height)
        options.mapType = .satelliteFlyover
        options.mapRect = MKMapRect(origin: MKMapPointForCoordinate(annotationView.annotation!.coordinate), size: MKMapSize(width: width, height: height))
        options.camera = MKMapCamera(lookingAtCenter: annotationView.annotation!.coordinate, fromDistance: 250, pitch: 65, heading: 0)
        
//        let indicator = UIActivityIndicatorView(frame: CGRect(x: snapshotView.center.x - 30, y: snapshotView.center.y - 30, width: 60, height: 60))
//        view.addSubview(indicator)
//        indicator.startAnimating()
        
        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start { snapshot, error in
            if let err = error {
                Utils.alert(title: "Error", message: err.localizedDescription, prefStyle: .alert, handler: nil, vc: self)
            }
            if let snap = snapshot {
//                indicator.stopAnimating()
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                imageView.image = snap.image
                self.snapshotView.addSubview(imageView)
                self.view.layoutIfNeeded()
            }
        }
        
        annotationView.detailCalloutAccessoryView = snapshotView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if let optTitle = view.annotation?.title, let title = optTitle {
//            let addLineNum = (title.count/30)
//            view.calloutOffset.y -= CGFloat(addLineNum * 10)
////            view.detailCalloutAccessoryView
//        }
//        let calloutView = UIView()
//        calloutView.translatesAutoresizingMaskIntoConstraints = false
//        calloutView.backgroundColor = .lightGray
//        view.addSubview(calloutView)
//
//        NSLayoutConstraint.activate([
//            calloutView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 0),
//            calloutView.widthAnchor.constraint(equalToConstant: 60),
//            calloutView.heightAnchor.constraint(equalToConstant: 30),
//            calloutView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.calloutOffset.x)
//            ])
        //        code some shit to properly display annotation label when it's tapped
    }
    
    // MARK: - mapView and GMSAutocompleteVC delegates
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard !draggingMode else { draggingMode = false; return }
        var lastCentCGPoint: CGPoint?
        var diff: CGFloat?
        let mapCenter = mapView.centerCoordinate
        let presCentGCPoint = mapView.convert(mapCenter, toPointTo: mapView)
        if let lccoord = lastCentCoord {
            lastCentCGPoint = mapView.convert(lccoord, toPointTo: mapView)
            diff = abs(presCentGCPoint.x - lastCentCGPoint!.x) + abs(presCentGCPoint.y - lastCentCGPoint!.y)
        }
        guard let d = diff, d > CGFloat(50) else { return }
        lookUpCurrentLocation( lastLocationCoord: mapCenter, completionHandler: { (revGeoLoc) in
            self.geocodeCompHandler(revGeoLoc: revGeoLoc)
        })
        lastCentCoord = mapCenter
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        Utils.alert(title: nil, message: "Error: \(error.localizedDescription)", prefStyle: .alert, handler: nil, vc: self)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let locCho = locChosen == .destLocation
        setRoutePoints(place: place, isDeparture: locCho ? false : true)
        dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -8, y: -3)
        }
        if myLocationPin == false {
            view.pinTintColor = Utils.getRandomColor()
        }
        else {
            if let color = pinColor, draggingMode {
                view.pinTintColor = color
            } else {
                view.pinTintColor = .red
            }
            pinColor = view.pinTintColor
            myLocationPin = false
        }
        view.isDraggable = true
        configureDetailView(annotationView: view)
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .ending:
            draggingMode = true
        default:
            break
        }
    }
    
    //MARK: Pieces of different actions encapsulated into functions
    
    private func resetRoutes() {
        for segment in 0..<2 {
            self.transType.setImage(segment == 0 ? UIImage(named: "auto") :  UIImage(named: "walk"), forSegmentAt: segment)
        }
        depLocTextField.text = ""
        arrLocTextField.text = ""
    }
    
    private func doSpan(with coord: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let location = CLLocationCoordinate2DMake((coord.latitude), (coord.longitude))
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func setUserLoc() {
        if let coord = curCoord {
            myLocationPin = true
            doSpan(with: coord)
            Utils.setupUserTracking(locMan: locationManager, distFilter: Data.distFilter)
            mapView.userTrackingMode = .follow
            waysDisplayed = false
            if !firstView.isHidden {
                Utils.displayRouteViews(views: [firstView, distRoute], isHidden: true)
            }
            if let deptf = depLocTextField.text?.isEmpty, let arrtf = arrLocTextField.text?.isEmpty, (!deptf || !arrtf) {
                self.resetRoutes()
            }
        }
    }
    
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
        locationManager.stopUpdatingLocation()
        present(autoCompVC, animated: true, completion: nil)
    }
    
    //MARK: reverseGeocodeLocation function
    
    private func lookUpCurrentLocation(lastLocationCoord: CLLocationCoordinate2D, completionHandler: @escaping (CLPlacemark?) -> Void ) {
        let lastLocation = CLLocation(coordinate: lastLocationCoord, altitude: 30, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
            if let error = error {
                Utils.alert(title: nil, message: error.localizedDescription, prefStyle: .alert, handler: nil, vc: self)
            } else {
                let firstLocation = placemarks?.first
                completionHandler(firstLocation)
            }
        })
    }
    
    private func geocodeCompHandler(revGeoLoc: CLPlacemark?) {
        guard let rgl = revGeoLoc, let country = rgl.country, let city = rgl.locality, let name = rgl.name,
            let coord = rgl.location?.coordinate else { return }
        if mapView.region.span.latitudeDelta < 0.02 || mapView.region.span.longitudeDelta < 0.02 {
            self.doSpan(with: coord)
        }
        if !self.routes.doRoutes || routes.userTapped {
            if let pin = self.curPin, name != pin.title! {
                self.mapView.removeAnnotation(pin)
            }
            var desc =  city + ", " + country
            let delim = ((desc.count > 26 && name.count > 15) ? "\n" : ";")
            desc += delim + name
            var pinTitle: String = desc
            if let stInd = desc.index(of: ",") {
                if let endInd = desc.index(of: Character(delim)) {
                    pinTitle = String(desc[..<stInd]  + ", " + desc[(desc.index(after: endInd))..<desc.endIndex] )
                }
            }
            self.addressLabel.text = desc
            if routes.userTapped {
                routes.userTapped = false
            }
            //                let labelHeight = self.addressLabel.intrinsicContentSize.height
            //                self.mapView.bottomAnchor.constraint(equalTo: self.addressLabel.topAnchor, constant: labelHeight).isActive=true
            UIView.animate(withDuration: Data.layoutAnimTime, animations: {
                self.view.layoutIfNeeded()
            })
            let deadlineTime = DispatchTime.now() + .milliseconds(500)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                if !coord.isEqual(to: self.curCoord!) {
                    self.curPin = OurAnnotation(title: pinTitle, subtitle: nil, location: coord)
                    self.mapView.addAnnotation(self.curPin!)
                }
            })
        }
    }
    
    //MARK: helper func for making routes
    
    private func getDirObject() -> MKDirections? {
        guard let (departureLoc, destinationLoc) = routes.getRoutesLocations() else { return nil}
        if departureLoc.isEqual(to: destinationLoc) {
            Utils.alert(title: nil, message: "Please, set distinct locations", prefStyle: .alert, handler: nil, vc: self)
            Utils.displayRouteViews(views: [firstView, distRoute], isHidden: false)
            return nil
        }
        pinsArr.append(OurAnnotation(title: destStr, subtitle: "\(String(describing: arrLocTextField.text!))", location: destinationLoc))
        pinsArr.append(OurAnnotation(title: depStr, subtitle: "\(String(describing: depLocTextField.text!))", location: departureLoc))
        mapView.addAnnotations(pinsArr)
        
        let dirRequestObj = routes.getDirReguestObj(departure: departureLoc, destination: destinationLoc)
        if transChosen == trType.walk {
            dirRequestObj.transportType = .walking
            curTrType = .walking
        } else {
            dirRequestObj.transportType = .automobile
            curTrType = .automobile
        }
        return(MKDirections(request: dirRequestObj))
    }
    
    private func displayRoutes(dirResponse: MKDirectionsResponse) {
        for (index, route) in dirResponse.routes.enumerated() {
            let formatter = routes.setupDateForm()
            
            routes.mainWay = index == 0 ? true : false
            mapView.add(route.polyline, level: .aboveRoads)
            if (index == 0) {
                let (routeDist, timeLabel) = routes.setupMainRoute(route: route, formatter: formatter)
                distRoute.text = ""
                distRoute.text?.append(String(Double(round(10 * routeDist)/10)) + " km")
                transType.setTitle(timeLabel, forSegmentAt: Int(curTrType.rawValue) - 1)
            }
            let rect = route.polyline.boundingMapRect
            mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsetsMake(CGFloat(80.0), CGFloat(80.0), CGFloat(80.0), CGFloat(80.0)), animated: true)
            Utils.displayRouteViews(views: [firstView, distRoute], isHidden: false)
            waysDisplayed = true
        }
    }
}
