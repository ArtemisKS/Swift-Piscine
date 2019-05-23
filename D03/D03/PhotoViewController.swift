//
//  PhotoViewController.swift
//  D03
//
//  Created by Artem KUPRIIANETS on 1/18/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    var photo : UIImage!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imageView: UIImageView!
//    var initWidth: CGFloat = 0
//    var initHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = photo
//        initWidth = imageView.bounds.width
//        initHeight = imageView.bounds.height
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateMinZoomScaleForSize(size: view.bounds.size)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func updateMinZoomScaleForSize(size: CGSize) {
//
//        let widthScale = size.width / imageView.bounds.width
//        let heightScale = size.height / imageView.bounds.height
//        let minScale = min(widthScale, heightScale)
//        print("minScale=\(minScale)")
//        scrollView.minimumZoomScale = minScale
//        scrollView.zoomScale = minScale
//        if imageView.frame.height < initHeight || imageView.frame.width < initWidth {
//            print("imageView.frame.height: \(imageView.frame.height); imageView.frame.width: \(imageView.frame.width)")
//            scrollView.zoomScale = 1
//        }
//        else {
//            scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
//        }
    }
    
    func updateConstraintsForSize(size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
}

extension PhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(size: view.bounds.size)
    }
}
