//
//  Settings+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 23.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var grouping: String?
}
