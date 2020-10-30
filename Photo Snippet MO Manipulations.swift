//
//  Photo Snippet MO Manipulations.swift
//  Newsman
//
//  Created by Anton2016 on 25/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData

extension PhotoSnippet
{
 final func move(into destination: PhotoSnippet)
 {
  guard let context = self.managedObjectContext else { return }
  guard destination.managedObjectContext != nil else { return }
  
  guard let sourceURL = self.url else { return }
  guard let destURL = destination.url else { return }
  
  let photoURLs = self.unfolderedPhotos
   .filter {$0.ID != nil && $0.url != nil }
   .map{(from: $0.url!, to: destURL.appendingPathComponent($0.ID!))}
  
  let folderURLs = self.allFolders
   .filter {$0.ID != nil && $0.url != nil}
   .map{(from: $0.url!, to: destURL.appendingPathComponent($0.ID!))}
  
  context.persistAndWait(block:
  {
   if let photos = self.photos
   {
    destination.addToPhotos(photos)
    self.removeFromPhotos(photos)
   }
   
   if let folders = self.folders
   {
    destination.addToFolders(folders)
    self.removeFromFolders(folders)
   }
   
   context.delete(self)
  })
  {success in
   guard success else { return }
   photoURLs.forEach  { PhotoItem.movePhotoItemOnDisk(from: $0.from, to: $0.to) }
   folderURLs.forEach { PhotoItem.movePhotoItemOnDisk(from: $0.from, to: $0.to) }
   PhotoItem.deletePhotoItemFromDisk(at: sourceURL)
  }
 }
 

}

