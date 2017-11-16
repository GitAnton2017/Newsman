//
//  PhotoSnippet+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 16.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoSnippet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoSnippet> {
        return NSFetchRequest<PhotoSnippet>(entityName: "PhotoSnippet")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var reports: NSSet?

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
