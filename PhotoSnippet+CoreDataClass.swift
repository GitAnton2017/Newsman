//
//  PhotoSnippet+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 17.12.2017.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PhotoSnippet) public class PhotoSnippet: BaseSnippet, SnippetImagesPreviewProvidable
{
 
 
 
 final var allFolders:           [PhotoFolder]  {return folders?.allObjects as? [PhotoFolder] ?? []}
 final var allPhotos:            [Photo]        {return photos?.allObjects  as? [Photo]       ?? []}
 
 final var emptyFolders:         [PhotoFolder]  {return allFolders.filter{($0.photos?.count ?? 0) == 0}}
 
 final var selectedFolders:      [PhotoFolder]  {return allFolders.filter{$0.isSelected}}
 final var unselectedFolders:    [PhotoFolder]  {return allFolders.filter{!$0.isSelected}}
 
 final var selectedPhotos:             [Photo]  {return allPhotos.filter{$0.isSelected}}
 final var unselectedPhotos:           [Photo]  {return allPhotos.filter{!$0.isSelected}}
 
 final var folderedPhotos:             [Photo]  {return allPhotos.filter{$0.folder != nil}}
 final var unfolderedPhotos:           [Photo]  {return allPhotos.filter{$0.folder == nil}}
 
 final var folderedSelectedPhotos:     [Photo]  {return allPhotos.filter{$0.folder != nil && $0.isSelected}}
 final var unfolderedSelectedPhotos:   [Photo]  {return allPhotos.filter{$0.folder == nil && $0.isSelected}}
 
 final var folderedUnselectedPhotos:   [Photo]  {return allPhotos.filter{$0.folder != nil && !$0.isSelected}}
 final var unfolderedUnselectedPhotos: [Photo]  {return allPhotos.filter{$0.folder == nil && !$0.isSelected}}

 final func removeEmptyFolders ()
 {
  emptyFolders.forEach{managedObjectContext?.delete($0)}
 }
 
 
 lazy var imageProvider: SnippetPreviewImagesProvider = SnippetImagesProvider(photoSnippet: self, number: 30)
 
 
 override func initStorage()
 {
  guard let SID = self.id?.uuidString, let stype = self.type else
  {
   print ("INIT STORAGE ERROR Snippet_ID = NIL! Snippet Type = NIL")
   return
  }

  let fileManager = FileManager.default
  let docFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
  let newSnippetURL = docFolder.appendingPathComponent(SID)
  
  do
  {
   try fileManager.createDirectory(at: newSnippetURL, withIntermediateDirectories: false, attributes: nil)
   print ("\(stype) DIRECTORY IS SUCCESSFULLY CREATED AT PATH:\(newSnippetURL.path)")
  }
  catch
  {
   print ("ERROR OCCURED WHEN CREATING \(stype) DIRECTORY: \(error.localizedDescription)")
  }
  
 }
 
 
// lazy var imageProvider: SnippetPreviewImagesProvider =
// {
//  let provider = SnippetImagesProvider(photoSnippet: self, number: 30)
//  return provider
//
// }()
}

