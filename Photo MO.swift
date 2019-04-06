//
//  Photo+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 17.12.2017.
//  Copyright © 2017 Anton2016. All rights reserved.


import Foundation
import CoreData
import UIKit


@objc(Photo) public class Photo: NSManagedObject
{
 //Photo MO unmanaged instance properties...
 static let videoFormatFile = ".mov" //Video data files require file extention specifier (*.MOV) in final URL!
 
 private var docFolder: URL   {return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!}
 
 final var snippetID: String  {return self.photoSnippet!.id!.uuidString}
 
 final var ID: String         {return self.id!.uuidString}
 
 final var folderID: String?  {return self.folder?.id?.uuidString}
 
 final var snippetURL: URL    {return docFolder.appendingPathComponent(snippetID)}
 //form current PhotoSnippet URL that owns this Photo MO and its PhotoFolder MO.
 
 final var type: SnippetType  {return SnippetType(rawValue: photoSnippet!.type!)!}
 
 private var fileName: String {return ID + (type == .video ? Photo.videoFormatFile : "")}
 
 final var folderedPhotos: [Photo] {return self.folder?.photos?.allObjects as? [Photo] ?? []}
 
 final var priorityIndex: Int {return PhotoPriorityFlags(rawValue: self.priorityFlag ?? "")?.rateIndex ?? -1}
 
 final var url: URL  //form underlying file URL based on PhotoFolder ID and Photo ID.
 {
  guard let folderID = self.folderID else
  {
   return snippetURL.appendingPathComponent(fileName) // Photo is not foldered yet!
  }
  
  return snippetURL.appendingPathComponent(folderID).appendingPathComponent(fileName) //Photo is foldred!
 }
 
 var movedInCurrentEvent: Bool = false
 
 var movedURL: URL?
 
 final var dragAndDropAnimationSetForClearanceState: Bool = false
 //Photo MO internal not persisted state of animation set for delayed clearance for PhotoItem wrapper dragged
 
 final var dragAndDropAnimationState: Bool = false
 //Photo MO internal not persisted current state of animation PhotoItem wrapper dragged
 
 final var zoomedPhotoItemState: Bool = false
 //Photo MO internal not persisted current state if its PhotoItem wrapper is currently presented in ZoomView
 
 
 

}


