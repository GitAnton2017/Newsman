//
//  PhotoSnippet+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 17.12.2017.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PhotoSnippet)
public class PhotoSnippet: BaseSnippet {}


enum GroupPhotos: String
{
    case byPriorityFlag    =  "By Priority Flag"
    case byTimeCreated     =  "By Time Created"
    case manually          =  "Manually"
    //case byLocation        =  "By Photo Location"
    //case byCustomCategory  =  "By Custom Category"
    
    static let sortDecritorsMap: [GroupPhotos : NSSortDescriptor] =
    [
     .byPriorityFlag: NSSortDescriptor(key: #keyPath(Photo.priorityFlag), ascending: true),
     .byTimeCreated : NSSortDescriptor(key: #keyPath(Photo.date),         ascending: true),
     .manually      : NSSortDescriptor(key: #keyPath(Photo.position),     ascending: true)
    ]
    
    var sortDescriptor: NSSortDescriptor
    {
     return GroupPhotos.sortDecritorsMap[self]!
    }
}
