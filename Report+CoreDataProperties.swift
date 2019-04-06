//
//  Report+CoreDataProperties.swift
//  Newsman
//
//  Created by Anton2016 on 16.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData


extension Report {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Report>
    {
        return NSFetchRequest<Report>(entityName: "Report")
    }

    @NSManaged public var category: String?
    @NSManaged public var name: String?
    @NSManaged public var audios: NSSet?
    @NSManaged public var photos: NSSet?
    @NSManaged public var sketches: NSSet?
    @NSManaged public var texts: NSSet?
    @NSManaged public var videos: NSSet?

}

// MARK: Generated accessors for audios
extension Report {

    @objc(addAudiosObject:)
    @NSManaged public func addToAudios(_ value: AudioSnippet)

    @objc(removeAudiosObject:)
    @NSManaged public func removeFromAudios(_ value: AudioSnippet)

    @objc(addAudios:)
    @NSManaged public func addToAudios(_ values: NSSet)

    @objc(removeAudios:)
    @NSManaged public func removeFromAudios(_ values: NSSet)

}

// MARK: Generated accessors for photos
extension Report {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: PhotoSnippet)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: PhotoSnippet)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

// MARK: Generated accessors for sketches
extension Report {

    @objc(addSketchesObject:)
    @NSManaged public func addToSketches(_ value: SketchSnippet)

    @objc(removeSketchesObject:)
    @NSManaged public func removeFromSketches(_ value: SketchSnippet)

    @objc(addSketches:)
    @NSManaged public func addToSketches(_ values: NSSet)

    @objc(removeSketches:)
    @NSManaged public func removeFromSketches(_ values: NSSet)

}

// MARK: Generated accessors for texts
extension Report {

    @objc(addTextsObject:)
    @NSManaged public func addToTexts(_ value: TextSnippet)

    @objc(removeTextsObject:)
    @NSManaged public func removeFromTexts(_ value: TextSnippet)

    @objc(addTexts:)
    @NSManaged public func addToTexts(_ values: NSSet)

    @objc(removeTexts:)
    @NSManaged public func removeFromTexts(_ values: NSSet)

}

// MARK: Generated accessors for videos
extension Report {

    @objc(addVideosObject:)
    @NSManaged public func addToVideos(_ value: VideoSnippet)

    @objc(removeVideosObject:)
    @NSManaged public func removeFromVideos(_ value: VideoSnippet)

    @objc(addVideos:)
    @NSManaged public func addToVideos(_ values: NSSet)

    @objc(removeVideos:)
    @NSManaged public func removeFromVideos(_ values: NSSet)

}
