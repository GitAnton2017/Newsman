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


extension Photo
{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: UUID?
    @NSManaged public var isSelected: Bool
    @NSManaged public var position: Int16
    @NSManaged public var priorityFlag: String?
    @NSManaged public var photoSnippet: PhotoSnippet?
    @NSManaged public var folder: PhotoFolder?

}


