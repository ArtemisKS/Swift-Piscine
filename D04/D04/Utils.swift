//
//  Utils.swift
//  D04
//
//  Created by Artem KUPRIIANETS on 19/05/2019.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import MapKit

extension UISearchBar {
	public func setTextColor(color: UIColor) {
		let subvws = subviews.flatMap { $0.subviews }
		guard let subvwstf = (subvws.filter { $0 is UITextField }).first as? UITextField else { return }
		subvwstf.textColor = color
	}
}

extension Double {
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
//			let outputExtent = outputImage.extent
//			assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
			
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
	//        return white > 0.2
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

extension String {
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
	
	static func displayViews(views: [UIView] ,isHidden: Bool) {
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
}
