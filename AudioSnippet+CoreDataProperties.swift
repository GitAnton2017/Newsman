//
//  AudioSnippet+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 21.10.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension AudioSnippet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioSnippet> {
        return NSFetchRequest<AudioSnippet>(entityName: "AudioSnippet")
    }

    @NSManaged public var audio: NSData?
    @NSManaged public var reports: NSSet?

}

// MARK: Generated accessors for reports
extension AudioSnippet {

    @objc(addReportsObject:)
    @NSManaged public func addToReports(_ value: Report)

    @objc(removeReportsObject:)
    @NSManaged public func removeFromReports(_ value: Report)

    @objc(addReports:)
    @NSManaged public func addToReports(_ values: NSSet)

    @objc(removeReports:)
    @NSManaged public func removeFromReports(_ values: NSSet)

}
