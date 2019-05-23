//
//  Data.swift
//  Rush01
//
//  Created by Artem KUPRIIANETS on 23/04/2019.
//  Copyright © 2019 Artem Kupriianets. All rights reserved.
//

import Foundation
import MapKit

struct Data {
    static let distFilter: CLLocationDistance = 300
    static let layoutAnimTime = 0.5
}

enum trType {
    case auto
    case walk
}

enum Location {
    case depLocation
    case destLocation
}
