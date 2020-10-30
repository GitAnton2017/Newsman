//
//  PhotoFolder+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 09.02.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData

extension PhotoFolder: ManagedObjectContextObservable,
                       OptionallySnippetRepsentable,
                       OptionallyDateTimeRepsentable,
                       OptionallyIdentifiable,
                       AnyFolderEntity,
                       InternalDataManageable
{
 @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoFolder>
 {
  NSFetchRequest<PhotoFolder>(entityName: "PhotoFolder")
 }

 @NSManaged public var date: NSDate?
 @NSManaged public var id: UUID?
 
 @NSManaged public var isSelected: Bool
 //Managed and persisted state of folder visual selected state.
 
 @NSManaged public var isDragAnimating: Bool
 //Managed and persisted visual drag & drop waggle animation state of associted cell in photo CV.
 
 @NSManaged public var arrowMenuPosition: NSValue?
 @NSManaged public var arrowMenuTouchPoint: NSValue?
 @NSManaged public var isArrowMenuShowing: Bool
 
 @NSManaged public var position: Int16      //managed position used when photo items clamped into groups
 @NSManaged public var plainPosition: Int16 //managed position used when photoitems  not grouped
 @NSManaged public var positions: NSObject?
 
 @NSManaged public var priorityFlag: String?
 @NSManaged public var tag: String?
 
 @NSManaged public var photoSnippet: PhotoSnippet?
 @NSManaged public var photos: NSSet?
 
 @NSManaged public var ck_metadata: NSData?
 @NSManaged public var isClouded: Bool

}

// MARK: Generated accessors for photos
extension PhotoFolder
{

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

