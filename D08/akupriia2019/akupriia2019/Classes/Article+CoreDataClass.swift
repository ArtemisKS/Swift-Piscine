//
//  Article+CoreDataClass.swift
//  
//
//  Created by Artem Kupriianets on 1/25/19.
//
//

import Foundation
import CoreData

@objc(Article)
public class Article: NSManagedObject {

    override public var description : String {
        return "Article '\(title!)' was created"
    }
}
