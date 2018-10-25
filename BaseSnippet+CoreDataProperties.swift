//
//  BaseSnippet+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 19.10.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension BaseSnippet
{
 @nonobjc public class func fetchRequest() -> NSFetchRequest<BaseSnippet>
 {
   return NSFetchRequest<BaseSnippet>(entityName: "BaseSnippet")
 }

 @NSManaged public var id: UUID?
 @NSManaged public var location: String?
 
}
