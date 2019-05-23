//
//  Page.swift
//  D02
//
//  Created by Artem KUPRIIANETS on 1/17/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import Foundation

class Page {
    var name : String = ""
    var desc : String
    var deathDate : Date
    init?(name: String, desc: String, deathDate: Date) {
        
        guard !name.isEmpty else { return nil }
        
        self.name = name
        self.desc = desc
        self.deathDate = deathDate
    }
}
