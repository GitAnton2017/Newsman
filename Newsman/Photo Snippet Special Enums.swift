//
//  Photo Snippet Special Enums.swift
//  Newsman
//
//  Created by Anton2016 on 26.10.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum GroupPhotos: String, AllCasesSelectorRepresentable
{
 var localizedString: String {return NSLocalizedString(rawValue, comment: rawValue)}
 
 case byPriorityFlag    =  "By Priority Flag"
 case byTimeCreated     =  "By Time Created"
 case manually          =  "Manually"
 case makeGroups        =  "Make Groups by Priority Flag"
 
 static let sortDecritorsMap: [GroupPhotos : NSSortDescriptor] =
 [
   .byPriorityFlag: NSSortDescriptor(key: #keyPath(Photo.priorityFlag), ascending: true),
   .byTimeCreated : NSSortDescriptor(key: #keyPath(Photo.date),         ascending: true),
   .manually      : NSSortDescriptor(key: #keyPath(Photo.position),     ascending: true)
 ]
 
 static var ascending: Bool = true
 
 typealias SortPredicate = (PhotoItemProtocol, PhotoItemProtocol) -> Bool
 
 static let sortPredMap: [GroupPhotos : SortPredicate] =
 [
   .byPriorityFlag: {GroupPhotos.ascending ? $0.priority <= $1.priority : $0.priority >= $1.priority },
   .byTimeCreated:  {GroupPhotos.ascending ? $0.date     <= $1.date     : $0.date     >= $1.date     },
   .manually:       {GroupPhotos.ascending ? $0.position <= $1.position : $0.position >= $1.position }
 ]
 
 static let groupingTypes : [GroupPhotos] = [.byPriorityFlag, .byTimeCreated, .manually, .makeGroups]
 
 var sortDescriptor: NSSortDescriptor {return GroupPhotos.sortDecritorsMap[self]!}
 var sortPredicate: SortPredicate? {return GroupPhotos.sortPredMap[self]}
}




enum PhotoPriorityFlags: String, AllCasesSelectorRepresentable
{
 var localizedString: String {return NSLocalizedString(rawValue, comment: rawValue)}
 
 static let priorityColorMap : [PhotoPriorityFlags: UIColor] =
  [
   .hottest : UIColor.red,
   .hot     : UIColor.orange,
   .high    : UIColor.yellow,
   .normal  : UIColor.brown,
   .medium  : UIColor.blue,
   .low     : UIColor.green
 ]
 
 static let priorityFilters : [(title: String, predicate: (Photo) -> Bool)] =
 [
   (SnippetPriority.hottest.rawValue, {$0.priorityFlag == PhotoPriorityFlags.hottest.rawValue }),
   (SnippetPriority.hot.rawValue,     {$0.priorityFlag == PhotoPriorityFlags.hot.rawValue     }),
   (SnippetPriority.high.rawValue,    {$0.priorityFlag == PhotoPriorityFlags.high.rawValue    }),
   (SnippetPriority.normal.rawValue,  {$0.priorityFlag == PhotoPriorityFlags.normal.rawValue  }),
   (SnippetPriority.medium.rawValue,  {$0.priorityFlag == PhotoPriorityFlags.medium.rawValue  }),
   (SnippetPriority.low.rawValue,     {$0.priorityFlag == PhotoPriorityFlags.low.rawValue     })
 ]
 
 static let prioritySectionsMap: [PhotoPriorityFlags: Int] =
  [
   .hottest : 0, .hot : 1, .high : 2, .normal : 3, .medium : 4, .low : 5
 ]
 static let priorities: [PhotoPriorityFlags] =
  [
   .hottest , .hot, .high, .normal, .medium, .low
 ]
 
 var color: UIColor  {return PhotoPriorityFlags.priorityColorMap[self]!}
 var section: Int    {return PhotoPriorityFlags.prioritySectionsMap[self]!}
 var rateIndex: Int  {return PhotoPriorityFlags.prioritySectionsMap.count - 1 - section}
 
 
 static let strings: [String] =
 [
   PhotoPriorityFlags.hottest.rawValue,
   PhotoPriorityFlags.hot.rawValue,
   PhotoPriorityFlags.high.rawValue,
   PhotoPriorityFlags.normal.rawValue,
   PhotoPriorityFlags.medium.rawValue,
   PhotoPriorityFlags.low.rawValue,
 ]
 
 case hottest =  "Hottest"
 case hot     =  "Hot"
 case high    =  "High"
 case normal  =  "Normal"
 case medium  =  "Medium"
 case low     =  "Low"
 
}

