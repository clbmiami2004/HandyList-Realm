//
//  Item.swift
//  HandyList
//
//  Created by Christian Lorenzo on 6/9/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation
import RealmSwift


class Item: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    //This is the reverse relationship that goes back to the Category file, which is the owning model object. 
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
