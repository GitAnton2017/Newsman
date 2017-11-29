//
//  PhotoSnippet+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 27.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoSnippet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoSnippet> {
        return NSFetchRequest<PhotoSnippet>(entityName: "PhotoSnippet")
    }

    @NSManaged public var reports: NSSet?
    @NSManaged public var photos: NSSet?

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

// MARK: Generated accessors for photos
extension PhotoSnippet {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
