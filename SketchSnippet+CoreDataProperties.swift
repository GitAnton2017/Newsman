//
//  SketchSnippet+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 16.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension SketchSnippet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SketchSnippet> {
        return NSFetchRequest<SketchSnippet>(entityName: "SketchSnippet")
    }

    @NSManaged public var sketch: NSData?
    @NSManaged public var reports: NSSet?

}

// MARK: Generated accessors for reports
extension SketchSnippet {

    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: Report)

    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: Report)

    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)

    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)

}
