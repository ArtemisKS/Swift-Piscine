//
//  ViewController.swift
//  D06
//
//  Created by Artem KUPRIIANETS on 1/23/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var animator: UIDynamicAnimator!
    var gravity = UIGravityBehavior()
    var collision = UICollisionBehavior(items: [])
    var itemBehaviour = UIDynamicItemBehavior(items: [])
    var behaviorArr = [UIDynamicBehavior]()
    let motionManager = CMMotionManager()
	var shapes = [Shape]()
	let gravityMagnitude = 5

    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = UIDynamicAnimator(referenceView: view)
        behaviorArr.append(contentsOf: [gravity, collision, itemBehaviour])
        behaviorArr.forEach { animator.addBehavior($0) }
		
        collision.translatesReferenceBoundsIntoBoundary = true
        itemBehaviour.elasticity = 0.7
        
    }
	
	//MARK: playing with traits here, because of some reason doesn't work
    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        if let view = tapGestureRecognizer.view {
//            coordinator.animateAlongsideTransition(in: view, animation: { (context) in
//                if UIApplication.shared.statusBarOrientation.isLandscape {
//                    self.gravity.gravityDirection = .init(dx: -4, dy: 0)
//                }
//                else {
//                    self.gravity.gravityDirection = .init(dx: 0, dy: 5)
//                }
//            })
//        }
//    }
//
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if UIApplication.shared.statusBarOrientation.isLandscape {
//            self.gravity.gravityDirection = .init(dx: -4, dy: 0)
//        }
//        else {
//            self.gravity.gravityDirection = .init(dx: 0, dy: 5)
//        }
//    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        if UIDevice.current.orientation.isLandscape {
//            gravity.gravityDirection = .init(dx: -4, dy: 0)
//        }
//        else {
//            gravity.gravityDirection = .init(dx: 0, dy: 5)
//        }
//    }
	
	//MARK: main tap func with all gesture recognizers
	
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
		
		setGravityDirection()
		
		let loc = sender.location(in: view)
		for shape in shapes {
			guard !shape.frame.contains(loc) else { return }
		}
		
        let shape = Shape(point: sender.location(in: view), maxwidth: self.view.bounds.width, maxheight: self.view.bounds.height)
		shapes.append(shape)
        view.addSubview(shape)
		handleItem(gravity: gravity, collision: collision, itemBehavior: itemBehaviour, item: shape, add: true)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        shape.addGestureRecognizer(pinch)
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(gesture:)))
        shape.addGestureRecognizer(rotate)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(gesture:)))
        shape.addGestureRecognizer(gesture)
    }
	
	//MARK: UIPanGestureRecognizer func
    
    @objc func panGesture (gesture: UIPanGestureRecognizer) {
        if let view = gesture.view {
            switch gesture.state {
            case .began:
				handleItem(gravity: gravity, collision: collision, itemBehavior: nil, item: view, add: false)
            case .changed:
                view.center = gesture.location(in: view.superview)
                animator.updateItem(usingCurrentState: view)
            case .ended:
                handleItem(gravity: gravity, collision: collision, itemBehavior: nil, item: view, add: true)
            default:
                break
            }
        }
    }
	
	//MARK: UIPinchGestureRecognizer func

    @objc func handlePinch(gesture : UIPinchGestureRecognizer) {
        if let view = gesture.view {
            switch gesture.state {
            case .began:
				handleItem(gravity: gravity, collision: collision, itemBehavior: itemBehaviour, item: view, add: false)
            case.changed:
                view.layer.bounds.size.height *= gesture.scale
                view.layer.bounds.size.width *= gesture.scale
                if let tmp = view as? Shape {
                    if (tmp.type == .circle) {
                        view.layer.cornerRadius *= gesture.scale
                    }
                }
                gesture.scale = 1
            case .ended:
                if let shape = view as? Shape {
                    if shape.frame.height > min(self.view.bounds.height, self.view.bounds.width) {
                        if let ind = shapes.index(of: shape) {
                            shapes.remove(at: ind)
                        }
                        shape.removeFromSuperview()
                    } else {
                    }
                }
            default:
                break
            }
        }
    }
	
	//MARK: UIRotationGestureRecognizer func
    
    @objc func handleRotate(gesture : UIRotationGestureRecognizer) {
        if let view = gesture.view {
            switch gesture.state {
            case .began:
				handleItem(gravity: gravity, collision: nil, itemBehavior: nil, item: view, add: false)
            case.changed:
                view.transform = view.transform.rotated(by: gesture.rotation)
                animator.updateItem(usingCurrentState: view)
                gesture.rotation = 0
            case .ended:
				handleItem(gravity: gravity, collision: nil, itemBehavior: nil, item: view, add: true)
            default:
                break
            }
        }
    }
	
	//MARK: accHandler func
    
    private func accHandler(data: CMAccelerometerData?, error: Error?) {
        if let myData = data {
            let x = CGFloat(myData.acceleration.x);
            let y = CGFloat(myData.acceleration.y);
            let v = CGVector(dx: x, dy: -y);
            gravity.gravityDirection = v;
        }
    }
	
	//MARK: func to add|remove behaviors to|from item
	
	private func handleItem(gravity: UIGravityBehavior?, collision: UICollisionBehavior?, itemBehavior: UIDynamicItemBehavior?, item: UIDynamicItem, add: Bool) {
		if add {
			gravity?.addItem(item); collision?.addItem(item); itemBehavior?.addItem(item)
		} else {
			gravity?.removeItem(item); collision?.removeItem(item); itemBehavior?.removeItem(item)
		}
	}
	
	//MARK: set gravity direction depending on device orientation
	
	private func setGravityDirection() {
		let orient = UIDevice.current.orientation
		if orient.isLandscape {
			gravity.gravityDirection = CGVector(dx: gravityMagnitude - 1, dy: 0)
			if orient == UIDeviceOrientation.landscapeLeft {
				gravity.gravityDirection = .init(dx: -(gravityMagnitude - 1), dy: 0)
			}
		} else {
			gravity.gravityDirection = .init(dx: 0, dy: gravityMagnitude)
			if orient == UIDeviceOrientation.portraitUpsideDown {
				gravity.gravityDirection = .init(dx: 0, dy: -gravityMagnitude)
			}
		}
	}
	
	//MARK: view delegate methods(viewWillAppear, viewWillDisappear) override for accelerometer setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1
            let queue = OperationQueue.main
            motionManager.startAccelerometerUpdates(to: queue, withHandler: accHandler )
        }
        else {
            print("sorry, there is no accelerometer!")
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if motionManager.isAccelerometerAvailable {
            motionManager.stopAccelerometerUpdates()
        }
    }
}

