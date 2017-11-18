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
