//
//  Photo+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 09.02.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo: ManagedObjectContextObservable,
                 OptionallySnippetRepsentable,
                 OptionallyIdentifiable,
                 OptionallyDateTimeRepsentable,
                 Folderable,
                 InternalDataManageable
 
{
 @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo>
 {
  NSFetchRequest<Photo>(entityName: "Photo")
 }

 @NSManaged public var date: NSDate?
 @NSManaged public var id: UUID?

 @NSManaged public var isSelected: Bool
 //Managed and persisted state of single photo visual selected state.

 @NSManaged public var isDragAnimating: Bool
 //Managed and persisted visual drag & drop waggle animation state of associted cell in photo CV.
 
 @NSManaged public var arrowMenuPosition: NSValue?
 @NSManaged public var arrowMenuTouchPoint: NSValue?
 
 @NSManaged public var isArrowMenuShowing: Bool

 @NSManaged public var position: Int16      //managed position used when photo items clamped into group
 
 @NSManaged public var plainPosition: Int16 //managed position used when photoitems  not grouped
 @NSManaged public var positions: NSObject?
 

 @NSManaged public var priorityFlag: String?
 @NSManaged public var tag: String?
 
 @NSManaged public var photoSnippet: PhotoSnippet?
 @NSManaged public var folder: PhotoFolder?
 
 @NSManaged public var ck_metadata: NSData?
 @NSManaged public var isClouded: Bool 

}


