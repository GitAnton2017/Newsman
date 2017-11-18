//
//  BaseSnippet+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 16.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension BaseSnippet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BaseSnippet> {
        return NSFetchRequest<BaseSnippet>(entityName: "BaseSnippet")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var logitude: Double
    @NSManaged public var priority: String?
    @NSManaged public var status: String?
    @NSManaged public var tag: String?
    @NSManaged public var type: String?

}
