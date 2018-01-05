//
//  Photo+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 17.12.2017.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo
{

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo>
    {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var location: String?
    @NSManaged public var longitude: Double
    @NSManaged public var isSelected: Bool
    @NSManaged public var position: Int16
    @NSManaged public var priorityFlag: String?
    @NSManaged public var photoSnippet: PhotoSnippet?

}
