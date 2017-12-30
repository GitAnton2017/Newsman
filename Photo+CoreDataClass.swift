//
//  Photo+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 17.12.2017.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Photo) public class Photo: NSManagedObject {}

public enum PhotoPriorityFlags: String
{
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
    
    var color: UIColor
    {
        get
        {
            return PhotoPriorityFlags.priorityColorMap[self]!
        }
    }
    
    var section: Int
    {
        get
        {
            return PhotoPriorityFlags.prioritySectionsMap[self]!
        }
    }
    
    
    
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
