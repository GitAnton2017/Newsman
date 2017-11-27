//
//  Photo+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 27.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var url: NSURL?
    @NSManaged public var date: NSDate?
    @NSManaged public var location: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photoSnippet: PhotoSnippet?

}
