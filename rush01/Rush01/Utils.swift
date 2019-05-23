//
//  Utils.swift
//  Rush01
//
//  Created by Artem KUPRIIANETS on 23/04/2019.
//  Copyright © 2019 Artem Kupriianets. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import GooglePlaces

public extension UISearchBar {
    public func setTextColor(color: UIColor) {
        let subvws = subviews.flatMap { $0.subviews }
        guard let subvwstf = (subvws.filter { $0 is UITextField }).first as? UITextField else { return }
        subvwstf.textColor = color
    }
}

public extension Double {
    /// Rounds the double to decimal places value
    func rounded(toDigits digits:Int) -> Double {
        let divisor = pow(10.0, Double(digits))
        return (self * divisor).rounded() / divisor
    }
}

extension UIImage {
    func averageColor() -> UIColor {
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        if #available(iOS 9.0, *) {
            // Get average color.
            let context = CIContext()
            let inputImage: CIImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
            let extent = inputImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            
            // Render to bitmap.
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        } else {
            // Create 1x1 context that interpolates pixels when drawing to it.
            let context = CGContext(data: &bitmap, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            let inputImage = cgImage ?? CIContext().createCGImage(ciImage!, from: ciImage!.extent)
            
            // Render to bitmap.
            context.draw(inputImage!, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        
        // Compute result.
        let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }
}

extension UIColor
{
    //    func isLight() -> Bool {
    //        var white: CGFloat = 0
    //        getWhite(&white, alpha: nil)
    //        return white > 0.6
    ////        let originalCGColor = self.cgColor
    ////        guard let components = self.cgColor.components else { return nil }
    ////        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
    ////        if brightness < 0.5 {
    ////            return false
    ////        } else {
    ////            return true
    ////        }
    //    }
    
    func isLight() -> Bool {
        guard let components = cgColor.components, components.count > 2 else { return false }
        let redBrightness = components[0] * 299
        let greenBrightness = components[1] * 587
        let blueBrightness = components[2] * 114
        let brightness = (redBrightness + greenBrightness + blueBrightness) / 1000
        return brightness > 0.6
    }
}

public extension CLLocationCoordinate2D {
    
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
//        let prec = Double(truncating: pow(10, 5) as NSNumber)
        
        return Utils.checkCoordsEquality(selfc: self, coordinate: coordinate, prec: 5)
    }
    
    func isAlmostEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
//        let prec = Double(truncating: pow(10, 2) as NSNumber)
        
        return Utils.checkCoordsEquality(selfc: self, coordinate: coordinate, prec: 3)
    }
}

public extension String {
    func indexInt(of char: Character) -> Int? {
        if let ind = self.index(of: char) {
            return self.distance(from: startIndex, to: ind)
        }
        return nil
    }
    
    subscript (index: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return self[charIndex]
    }
    
    subscript (range: Range<Int>) -> Substring {
        let startIndex = self.index(self.startIndex, offsetBy: range.lowerBound)
        let stopIndex = self.index(self.startIndex, offsetBy: range.lowerBound + range.count)
        return self[startIndex..<stopIndex]
    }
}

class Utils {
    
    static func checkCoordsEquality(selfc: CLLocationCoordinate2D, coordinate: CLLocationCoordinate2D, prec: Int) -> Bool {
        let strDict = ["slat": String(selfc.latitude), "clat": String(coordinate.latitude), "slong": String(selfc.longitude), "clong": String(coordinate.longitude)]
        let dot: Character = "."
        var wrongCoords = false
        strDict.forEach { (_, val) in
            guard val.contains(dot) else {
                wrongCoords = true
                return
            }
        }
        guard !wrongCoords else { return true }
        let (slat, clat, slong, clong) = (strDict["slat"]!, strDict["clat"]!, strDict["slong"]!, strDict["clong"]!)
        if slat[slat.index(slat.index(of: dot)!, offsetBy: prec - 1)] != clat[clat.index(clat.index(of: dot)!, offsetBy: prec - 1)] || slong[slong.index(slong.index(of: dot)!, offsetBy: prec)] != clong[clong.index(clong.index(of: dot)!, offsetBy: prec)] {
            return false
        }
//        if Float(selfc.latitude*prec).rounded() != Float(coordinate.latitude*prec).rounded() || Float(selfc.longitude*prec).rounded() != Float(coordinate.longitude*prec).rounded() {
//            return false
//        }
        // Double version, inaccurate because of inaccurate rounding of Double
//        if selfc.latitude.rounded(toDigits: prec) != coordinate.latitude.rounded(toDigits: prec) ||
//            selfc.longitude.rounded(toDigits: prec) != coordinate.longitude.rounded(toDigits: prec) {
//            return false
//        }
        return true
    }
    
    static func setBoolValues(as value: Bool, for properties: NSMutableArray) {
        for (index, _) in properties.enumerated() {
            properties[index] = true
        }
        return
    }
    
    static func pinIsTapped(tapLoc: CGPoint, pins: [MKAnnotation], mapView: MKMapView) -> Bool {
        var isTapped = false
        pins.forEach {
            let pinLoc = mapView.convert($0.coordinate, toPointTo: mapView)
            if case Int(tapLoc.x.rounded() - 5)..<(Int(tapLoc.x.rounded()) + 5) = Int(pinLoc.x.rounded()),
                case Int(tapLoc.y.rounded())..<(Int(tapLoc.y.rounded()) + 35) = Int(pinLoc.y.rounded()) {
                isTapped = true
                return
            }
        }
        return isTapped
    }
    
    static func getRandomColor() -> UIColor {
        let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    static func alert(title: String?, message: String, prefStyle: UIAlertControllerStyle, handler: ((UIAlertAction??) -> Void)?, vc: UIViewController) {
        let alertMessage = UIAlertController.init(title: title, message: message, preferredStyle: prefStyle)
        let confirm = UIAlertAction.init(title: "OK", style: .default, handler: handler)
        alertMessage.addAction(confirm)
        vc.present(alertMessage, animated: true, completion: nil)
    }
    
    static func displayRouteViews(views: [UIView] ,isHidden: Bool) {
        for view in views {
            if let label = view as? UILabel, !isHidden {
                if let text = label.text, !text.isEmpty {
                    label.isHidden = isHidden
                }
            }
            else {
                view.isHidden = isHidden
            }
        }
    }
    
    static func roundViews(buttons: [UIButton], views: [UIView], cr: CGFloat) {
        for but in buttons {
            but.layer.cornerRadius = cr
        }
        for view in views {
            view.layer.masksToBounds = true
        }
    }
    
    static func setupUserTracking(locMan: CLLocationManager, distFilter: CLLocationDistance) {
        locMan.startUpdatingLocation()
        locMan.startMonitoringSignificantLocationChanges()
        locMan.distanceFilter = distFilter
        locMan.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    static func setViewFont(controls: [UIControl], font: UIFont?) {
        guard let font = font else { return }
        for control in controls {
            let attr = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
            (control as? UISegmentedControl)?.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        }
    }
    
    static func padTextField(tfs: [UITextField]) {
        for tf in tfs {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: tf.frame.width/7, height: tf.frame.height))
            tf.rightView = paddingView
            tf.rightViewMode = .always
        }
    }
    
    static func setupMapUI(locationManager: CLLocationManager, views: [UIView]) {
        setupUserTracking(locMan: locationManager, distFilter: Data.distFilter)
        roundViews(buttons: [views.first as! UIButton], views: [views[1] as! UILabel], cr: 3)
        setViewFont(controls: [UISegmentedControl.appearance()], font: UIFont(name: "HelveticaNeue-Light", size: 14.0))
        padTextField(tfs: [views[2] as! UITextField, views.last as! UITextField])
    }
    
    static func setupUser(locationManager: CLLocationManager, vc: UIViewController, views: [UIView]) {
        guard let vc = vc as? CLLocationManagerDelegate else { return }
        locationManager.delegate = vc
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        setupMapUI(locationManager: locationManager, views: views)
    }
}
