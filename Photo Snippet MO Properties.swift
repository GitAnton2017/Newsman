//
//  PhotoSnippet+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 09.02.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoSnippet
{
 @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoSnippet>
 {
   return NSFetchRequest<PhotoSnippet>(entityName: "PhotoSnippet")
 }

 @NSManaged public var ascending: Bool       //sort order of sections by section titles rateIndex
 @NSManaged public var ascendingPlain: Bool  //sort order for unsectioned state with one section!
 @NSManaged public var grouping: String?

 @NSManaged public var nphoto: Int32
 @NSManaged public var photos: NSSet?
 @NSManaged public var reports: NSSet?
 @NSManaged public var folders: NSSet?
}

// MARK: Generated accessors for photos
extension PhotoSnippet
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

// MARK: Generated accessors for reports
extension PhotoSnippet {

    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: Report)

    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: Report)

    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)

    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)

}

// MARK: Generated accessors for folders
extension PhotoSnippet {

    @objc(addFoldersObject:)
    @NSManaged public func addToFolders(_ value: PhotoFolder)

    @objc(removeFoldersObject:)
    @NSManaged public func removeFromFolders(_ value: PhotoFolder)

    @objc(addFolders:)
    @NSManaged public func addToFolders(_ values: NSSet)

    @objc(removeFolders:)
    @NSManaged public func removeFromFolders(_ values: NSSet)

}
