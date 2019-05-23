//
//  Location.swift
//  D05
//
//  Created by Artem KUPRIIANETS on 1/22/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import Foundation

class Location : CustomStringConvertible {
    var name : String
    var desc : String
    var latitude : Double
    var longitude : Double
    init(dataDictionary:Dictionary<String,String>) {
        print("Debug : ")
        print(dataDictionary["name"]!)
        print(dataDictionary["desc"]!)
        print(dataDictionary["latitude"]!)
        print(dataDictionary["longitude"]!)
            
        self.name = dataDictionary["name"]!
        self.desc = dataDictionary["desc"]!
        self.latitude = Double(dataDictionary["latitude"]!)!
        self.longitude = Double(dataDictionary["longitude"]!)!
    }
    var description : String {
        return "(\(name), \(desc), \(latitude), \(longitude))"
        // return "(\(name), \(desc))"
    }

    class func newLocationItem(_ dataDictionary:Dictionary<String,String>) -> Location {
        return Location(dataDictionary: dataDictionary)
    }
}

