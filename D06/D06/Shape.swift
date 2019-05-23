//
//  Shape.swift
//  D06
//
//  Created by Artem KUPRIIANETS on 1/23/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit

enum ShapeType {
    case square, circle
}

extension Array {
    func randomElement() -> Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(count)))]
    }
}

class Shape: UIView {
    let type: ShapeType
    var size : CGFloat = 100
    init(point: CGPoint, maxwidth: CGFloat, maxheight: CGFloat ) {
        var x = point.x
        var y = point.y
        
        type = [ShapeType.square, .circle].randomElement()!
        
        if x+size/2 > maxwidth {
            x -= size/2
        }
        if y+size/2 > maxheight {
            y -= size/2
        }
        
        let frame = CGRect(x: x, y: y, width: size, height: size)
        super.init(frame: frame)
        
        if type == .circle {
            self.layer.cornerRadius = size/2
        }
        
        self.backgroundColor = getRandomColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("required init?(coder aDecoder: NSCoder) has not been implemented")
    }
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType { return type == .circle ? .ellipse : .rectangle }
 
    func getRandomColor() -> UIColor {
        let randomRed:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomGreen:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        let randomBlue:CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
