//
//  Category.swift
//  HandyList
//
//  Created by Christian Lorenzo on 6/9/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name: String = ""
    
    
    //Relationships: From Category to Items. And from the Items file we have to point back to the Category file. 
    
    let items = List<Item>()  //This is same as writing: "var items: Array<Int>()" or "var: [Int] = [1, 2, 3]". We're just saying that the array is type Int.
    
    
}
