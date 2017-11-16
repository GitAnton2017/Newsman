//
//  VideoSnippet+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 16.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension VideoSnippet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoSnippet> {
        return NSFetchRequest<VideoSnippet>(entityName: "VideoSnippet")
    }

    @NSManaged public var video: NSData?
    @NSManaged public var reports: NSSet?

}

// MARK: Generated accessors for reports
extension VideoSnippet {

    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: Report)

    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: Report)

    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)

    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)

}
