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
    case makeGroups        =  "Make Groups by Priority Flag"
    //case byLocation        =  "By Photo Location"
    //case byCustomCategory  =  "By Custom Category"
    
    static let sortDecritorsMap: [GroupPhotos : NSSortDescriptor] =
    [
     .byPriorityFlag: NSSortDescriptor(key: #keyPath(Photo.priorityFlag), ascending: true),
     .byTimeCreated : NSSortDescriptor(key: #keyPath(Photo.date),         ascending: true),
     .manually      : NSSortDescriptor(key: #keyPath(Photo.position),     ascending: true)
    ]
    
    static var ascending: Bool = true
    
    typealias SortPredicate = (PhotoItem, PhotoItem) -> Bool
    static let sortPredMap: [GroupPhotos : SortPredicate] =
    [
     .byPriorityFlag:
        {let f1 = $0.photo.priorityFlag ?? ""; let i1 = PhotoPriorityFlags(rawValue: f1)?.rateIndex ?? -1
         let f2 = $1.photo.priorityFlag ?? ""; let i2 = PhotoPriorityFlags(rawValue: f2)?.rateIndex ?? -1
         return GroupPhotos.ascending ? i1 <= i2 : i1 >= i2
        },
     
     .byTimeCreated:  {GroupPhotos.ascending ? (($0.photo.date! as Date) <= ($1.photo.date! as Date)) :
                                               (($0.photo.date! as Date) >= ($1.photo.date! as Date))},
     
     .manually:       {GroupPhotos.ascending ? ($0.photo.position <= $1.photo.position) :
                                               ($0.photo.position >= $1.photo.position)}
    
    ]
    
    static let groupingTypes : [GroupPhotos] = [.byPriorityFlag, .byTimeCreated, .manually, .makeGroups]
    
    var sortDescriptor: NSSortDescriptor
    {
     return GroupPhotos.sortDecritorsMap[self]!
    }
    
    var sortPredicate: SortPredicate?
    {
     return GroupPhotos.sortPredMap[self]
    }
}
