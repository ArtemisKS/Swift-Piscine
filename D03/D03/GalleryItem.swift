//
//  GalleryItem.swift
//  D03
//when you press this button, you have to geolocate and position the map on yourself by adjusting the zoom
//  Created by Artem KUPRIIANETS on 1/18/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import Foundation

class GalleryItem {
    
    var itemImage: String
    
    init(dataDictionary:Dictionary<String,String>) {
        itemImage = dataDictionary["itemImage"]!
    }
    
    class func newGalleryItem(_ dataDictionary:Dictionary<String,String>) -> GalleryItem {
        return GalleryItem(dataDictionary: dataDictionary)
    }
    
}
