//
//  PhotoFolder+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 09.02.2018.
//  Copyright © 2018 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PhotoFolder) public class PhotoFolder: NSManagedObject
{
 //PhotoFolder MO unmanaged instance properties...
 private var docFolder: URL        {return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!}
 
 final var ID: String              {return self.id!.uuidString}
 
 final var snippetID: String       {return self.photoSnippet!.id!.uuidString}
 
 final var snippetURL: URL         {return docFolder.appendingPathComponent(snippetID)}
 
 final var url: URL                {return snippetURL.appendingPathComponent(ID)}
 
 final var type: SnippetType       {return SnippetType(rawValue: photoSnippet!.type!)!}
 
 final var folderedPhotos: [Photo] {return self.photos?.allObjects as? [Photo] ?? []}
 
 final var count: Int              {return self.folderedPhotos.count}
 
 final var isEmpty: Bool           {return self.folderedPhotos.isEmpty}
 
 final var priorityIndex: Int      {return PhotoPriorityFlags(rawValue: self.priorityFlag ?? "")?.rateIndex ?? -1}
 
 final var dragAndDropAnimationSetForClearanceState: Bool = false
 //PhotoFolder MO internal not persisted state of animation set for delayed clearance for PhotoFolderItem wrapper dragged
 
 final var dragAndDropAnimationState: Bool = false
 //PhotoFolder MO internal not persisted current state of animation PhotoFolderItem wrapper dragged
 
 final var zoomedPhotoItemState: Bool = false
 //PhotoFolder MO internal not persisted current state if its PhotoFolderItem wrapper is currently presented in ZoomView
 
} //@objc(PhotoFolder) public class PhotoFolder: NSManagedObject...


