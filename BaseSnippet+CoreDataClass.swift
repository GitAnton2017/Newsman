//
//  BaseSnippet+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 16.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(BaseSnippet)
public class BaseSnippet: NSManagedObject
{

}

public enum SnippetType: String
{
    case text   = "TextSnippet"
    case photo  = "PhotoSnippet"
    case video  = "VideoSnippet"
    case audio  = "AudioSnippet"
    case sketch = "SketchSnippet"
    case report = "Report"
}

public enum SnippetPriority: String
{
    static let priorityColorMap : [SnippetPriority: UIColor] =
    [
        .hottest : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 1.00),
        .hot     : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.80),
        .high    : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.70),
        .normal  : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.30),
        .medium  : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.20),
        .low     : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.10),
    ]
    
    var color: UIColor
    {
        get
        {
          return SnippetPriority.priorityColorMap[self]!
        }
    }
    
    case hottest =  "Hottest"
    case hot     =  "Hot"
    case high    =  "High"
    case normal  =  "Normal"
    case medium  =  "Medium"
    case low     =  "Low"
    
}

public enum SnippetStatus: String
{
    
    case new         =   "New"
    case old         =   "Old"
    case archived    =   "Archived"
   
    
}
