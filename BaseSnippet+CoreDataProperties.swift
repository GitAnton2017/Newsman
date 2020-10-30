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

 @NSManaged var id: UUID?
 // unique UUID ID of the snippets
 
 @NSManaged private var hiddenSection: Bool
 //Managed and persisted visibility (if hidden or not) state of associted cell in TV.
 
 @NSManaged var disclosedCell: Bool
 //Managed and persisted visual disclosure state of associted cell in TV.
 
 @NSManaged var isSelected: Bool
 //Managed and persisted visual selected state of associted cell in TV.
 
 @NSManaged var isDragAnimating: Bool
 //Managed and persisted visual drag & drop waggle animation state of associted cell in TV.
 
 @NSManaged public var ck_metadata: NSData?
 //Managed and persiste archived metadata of corresponding CKRecord in cloud DB after last save operation.
 
 @NSManaged public var isClouded: Bool
 //Managed and persisted state that indicates if the last MO changes are saved in cloud DB.
 

 

}
