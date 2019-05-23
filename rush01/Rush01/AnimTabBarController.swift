//
//  AnimTabBarController.swift
//  Rush01
//
//  Created by Artem KUPRIIANETS on 13/05/2019.
//  Copyright © 2019 Artem Kupriianets. All rights reserved.
//

import UIKit

class AnimTabBarController: UITabBarController {

    var itemImageView = [UIImageView]()
    var allItemsGood = true
    let itemsNum = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard tabBar.subviews.count >= itemsNum else { allItemsGood = false; return }
        let tbButtons = [self.tabBar.subviews[0], self.tabBar.subviews[1]]
        tbButtons.forEach {
//            $0.autoresizingMask = .flexibleBottomMargin
//            $0.layoutMargins = UIEdgeInsets(top: 7.0, left: 7.0, bottom: 7.0, right: 7.0)
            $0.subviews.forEach({
                if let iv = $0 as? UIImageView {
                    iv.contentMode = .center
                    // MARK: figure out how to resize TabBar image
//                    iv.autoresizingMask = .flexibleBottomMargin
//                    iv.superview?.bounds.size = CGSize(width: 35, height: 35)
//                    iv.insetsLayoutMarginsFromSafeArea = true
                    self.itemImageView.append(iv)
                    return
                }
            })
        }
//        for tabBarItem in tabBar.items! {
//            tabBarItem.imageInsets = UIEdgeInsetsMake(10, 10, 10, 10)
//        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let ind = item.tag
        guard allItemsGood, ind < itemImageView.count else {
            Utils.alert(title: "Oops", message: "Something wrong with your TabBar Controller", prefStyle: .alert, handler: nil, vc: self)
            return
        }
        let curIV = itemImageView[ind]
//        curIV.frame.origin = CGPoint(x: 0, y: 0)
        curIV.transform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { () -> Void in
            curIV.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }, completion: nil)
        curIV.transform = CGAffineTransform(rotationAngle: CGFloat(0))
    }
}
