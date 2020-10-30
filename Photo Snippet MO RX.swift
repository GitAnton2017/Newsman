//
//  Photo Snippet MO RX.swift
//  Newsman
//
//  Created by Anton2016 on 16/07/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

extension SnippetDragItem
{
//****************************************************************************************************************
 func move(to snippet: BaseSnippet, to photoItem: Draggable?,
           to position: PhotoItemPosition?,  completion: ( () -> () )?)
//****************************************************************************************************************
 {
  
  let contextResultHandler: (Result<Notification, ContextError>) -> () =
  {result in
   switch result
   {
    case .success(let notification): NotificationCenter.default.post(notification)
    case .failure(let error):        error.log()
   }
   completion?()
  }
 
  switch (self.snippet, snippet, photoItem, position)
  {
   
   case let (source as PhotoSnippet, dest as PhotoSnippet, nil, position?):
    source.move(to: dest, to: position, with: contextResultHandler)
   
   // <<<<< FOLDER PHOTO SNIPPET INTO SNIPPET PHOTO FOLDER (.snippetItemDidFolder) >>>>>
   case let (source as PhotoSnippet, _ as PhotoSnippet, folderItem as PhotoFolderItem, position?):
    source.folder(to: folderItem.folder, to: position, with: contextResultHandler)
   
   
   case let (source as PhotoSnippet, _ as PhotoSnippet, photoItem as PhotoItem, nil):
    let allPhotos = source.allPhotos //fix all photos array before context moves!
    source.merge(with: photoItem.photo)
    {
     let userInfo: [PhotoItemMovedKey: Any] = [ .destPhoto : photoItem.photo ]
     NotificationCenter.default.post(name: .snippetItemDidMerge, object: allPhotos, userInfo: userInfo)
     completion?()
    }
   
   default: break
   
  }// switch (self.snippet, snippet, photoItem, position)...
 }//func move(to snippet: BaseSnippet, to photoItem: Draggable?...
//****************************************************************************************************************
 
 
}//extension SnippetDragItem...
//****************************************************************************************************************



extension PhotoSnippet
{
 
//********************** FOLDER INTO SNIPPET PHOTO FOLDER (.snippetItemDidFolder) ********************************
 final func folder(to destSnippetFolder: PhotoFolder,
                   to destFolderPosition: PhotoItemPosition,
                   with completion: @escaping (Result<Notification, ContextError>) -> () )
//****************************************************************************************************************
 {
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photoSnippet, operation: .folder)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photoSnippet, operation: .folder)))
   return
  }
  
  guard destSnippetFolder.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: destSnippetFolder, entity: .destPhotoFolder, operation: .folder)))
   return
  }
  
  guard destSnippetFolder.managedObjectContext != nil else 
  {
   completion(.failure(.noContext(object: destSnippetFolder, entity: .destPhotoFolder, operation: .folder)))
   return
  }
  
  guard let destSnippet = destSnippetFolder.photoSnippet else
  {
   completion(.failure(.noSnippet(object: destSnippetFolder, entity: .destPhotoFolder, operation: .folder)))
   return
  }
  
  guard let destSnippetFolderURL = destSnippetFolder.url else
  {
   completion(.failure(.noURL(object: destSnippetFolder, entity: .destPhotoFolder, operation: .folder)))
   return
  }
  
  let insideMoves = (destSnippet.objectID == self.objectID)
  
  let allSnpPhotos  = insideMoves ? allPhotos .filter{$0.folder !== destSnippetFolder} : allPhotos
  let allSnpFolders = insideMoves ? allFolders.filter{$0        !== destSnippetFolder} : allFolders
  
  let validAllSnpPhotos  = allSnpPhotos.filter  { $0.isDeleted == false && $0.ID != nil && $0.url != nil }
  let validAllSnpFolders = allSnpFolders.filter { $0.isDeleted == false && $0.ID != nil && $0.url != nil }
  
  if validAllSnpPhotos.isEmpty { return }
  
  let photoURLs = validAllSnpPhotos.map{(from: $0.url!, to: destSnippetFolderURL.appendingPathComponent($0.ID!))}
  
  let count = validAllSnpPhotos.count
  let rowIndex = destFolderPosition.row
  
  context.performChanges(block:
  {
   destSnippetFolder.folderedPhotos.forEach
   {photo in
    let pos = photo.getRowPosition(for: .manually)
    if ( pos >= rowIndex ) { photo.setGroupTypePosition(newPosition: pos + count, for: .manually) }
   }
   
   validAllSnpPhotos.enumerated().forEach
   {(index, photo) -> () in
    photo.clearAllRowPositions()
    photo.setGroupTypePosition(newPosition: index + rowIndex, for: .manually)
   }
  
   destSnippetFolder.addToPhotos(NSSet(array: validAllSnpPhotos))
   
   validAllSnpFolders.forEach {folder in
    if let foldered = folder.photos { folder.removeFromPhotos(foldered) }
   }
   
   if insideMoves { destSnippetFolder.setAllRowPositions(to: 0) }
   else
   {
    self.removeFromPhotos(NSSet(array: validAllSnpPhotos))
    destSnippet.addToPhotos(NSSet(array: validAllSnpPhotos))
   }
   
  })
  {result  in
   guard case .success() = result else { return }//guard persisted...
   
   FileManager.batchMoveItemsOnDisk(using: photoURLs)
   {result in
    
    let movedValid = validAllSnpPhotos.filter{ $0.isDeleted == false && $0.ID != nil && $0.url != nil }
   
    let userInfo: [PhotoItemMovedKey: Any] = [ .position  : destFolderPosition,
                                               .destFolder : destSnippetFolder,
                                               .isSelfFolderedSnippet : insideMoves ]
    
    switch result
    {
     case .failure(.batchMoveFailures(_)) where movedValid.isEmpty:
      print ("<<< BATCH FAILURE WARNING >>> NO VALID PHOTOS TO POST AFTER PARTIAL BATCH MOVE")
     
     case .success where movedValid.isEmpty:
      print ("<<< BATCH SUCCESS WARNING >>> NO VALID PHOTOS TO POST AFTER FULL BATCH MOVE")
     
     case .success where !movedValid.isEmpty:
      completion(.success(Notification(name: .snippetItemDidFolder, object: movedValid, userInfo: userInfo)))
      if insideMoves { validAllSnpFolders.forEach{ $0.delete() } } else { self.delete() }
     
     case .failure(.batchMoveFailures(let errorDict)) where !movedValid.isEmpty:
      let IDs = errorDict.keys.map{$0.lastPathComponent}
      let partMoved = movedValid.filter{ !IDs.contains($0.ID!) }
      if partMoved.isEmpty
      {
       print ("<<< BATCH FAILURE WARNING >>> NO VALID MOVED PHOTOS TO POST AFTER PARTIAL BATCH MOVE")
       break
      }
      completion(.success(Notification(name: .snippetItemDidFolder, object: partMoved, userInfo: userInfo)))
    
     default: break
     
    }//switch result...
   }//FileManager.batchMoveItemsOnDisk...
  }//{perform context changes in...
 }//final func folder(to destSnippetFolder: PhotoFolder,...
//****************************************************************************************************************
 
 
 
//************************** MERGE WITH SNIPPET PHOTO ITEM (.snippetItemDidMerge) ********************************
 final func merge(with destSnippetPhoto: Photo, with completion: ( () -> () )? = nil)
//****************************************************************************************************************
 {
  guard let context = self.managedObjectContext else
  {
   print ("<<<PHOTO SNIPPET MERGING ERROR!>>> \(self.description) has no associated context!")
   return
  }
  
  context.persist(block:
  {
    
    
   // to do...
  })
  {persisted in
   guard persisted else { return } // if there is context save error comletion is not called!
  }
  
 }
//****************************************************************************************************************
 
 
 
 
//******************** MOVE SNIPPET CONTENT INTO ANOTHER ONE (.snippetItemDidMove) *******************************

 final func move(to destSnippet: PhotoSnippet,
                 to destSnippetPosition: PhotoItemPosition,
                 with completion: @escaping (Result<Notification, ContextError>) -> ())
  
//Moves async the whole photo snippet content into detination photo snippet.
//****************************************************************************************************************
 {
  guard self !== destSnippet else { return } // we cannot move photo snippet content into itself!
  
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photoSnippet, operation: .move)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photoSnippet, operation: .move)))
   return
  }
  
  guard destSnippet.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: destSnippet, entity: .destPhotoSnippet, operation: .move)))
   return
  }
  
  guard destSnippet.managedObjectContext != nil else
  {
   completion(.failure(.noContext(object: destSnippet, entity: .destPhotoSnippet, operation: .move)))
   return
  }
  
  guard let snippetDestURL = destSnippet.url else
  {
   completion(.failure(.noURL(object: destSnippet, entity: .destPhotoSnippet, operation: .move)))
   return
  }
  
  let validAll = unfoldered.filter { $0.isDeleted == false && $0.ID != nil && $0.url != nil }
  //we use only valid children, which are not deleted from context at the time of this operation!
  
  if validAll.isEmpty { return }
  
  let unfolderedURLs = validAll.map{ (from: $0.url!, to: snippetDestURL.appendingPathComponent($0.ID!)) }
  
  context.performChanges(block:
  {
   self.unfolderedPhotos.forEach     //move all photos one by one with row positions adjustment...
   {photo in
    self.removeFromPhotos(photo)
    destSnippet.addToPhotos(photo)
    photo.setMovedPhotoRowPositions()
    photo.photoItemPosition = destSnippetPosition
    photo.shiftRowPositionsRight()
   }//self.unfolderedPhotos...
   
   self.allFolders.forEach           //move all folders one by one with row positions adjustment...
   {folder in 
    self.removeFromFolders(folder)
    destSnippet.addToFolders(folder)
    if let foldered = folder.photos  // move foldered photos into dest snippet for each folder
    {
     destSnippet.addToPhotos(foldered)
     self.removeFromPhotos(foldered)
    }//if let foldered...
    folder.setMovedPhotoRowPositions()
    folder.photoItemPosition = destSnippetPosition
    folder.shiftRowPositionsRight()
   }//self.allFolders...
   
   
  })//context.persist(block:...
  {result in
   guard case .success = result else { return }
   
   // proceed with moving photo snippet content ( all *.JPG files & folders) on disk...
   FileManager.batchMoveItemsOnDisk(using: unfolderedURLs)
   {result in
    let movedValid = validAll.filter { $0.isDeleted == false && $0.ID != nil && $0.url != nil }
    
    if movedValid.isEmpty { return }
    
    let userInfo: [PhotoItemMovedKey: Any] = [ .position : destSnippetPosition ]
   
    switch result
    {
     case .failure(.batchMoveFailures(_)) where movedValid.isEmpty:
      print ("<<< BATCH FAILURE WARNING >>> NO VALID PHOTOS TO POST AFTER PARTIAL BATCH MOVE")
     
     case .success where  movedValid.isEmpty:
      print ("<<< BATCH SUCCESS WARNING >>> NO VALID PHOTOS TO POST AFTER FULL BATCH MOVE")
     
     case .success where !movedValid.isEmpty:
      completion(.success(Notification(name: .snippetItemDidMove, object: movedValid, userInfo: userInfo)))
      self.delete()
     
     case .failure(.batchMoveFailures(let errorDict)) where !movedValid.isEmpty:
      let IDs = errorDict.keys.map{$0.lastPathComponent}
      let partMoved = movedValid.filter{ !IDs.contains($0.ID!) }
      if partMoved.isEmpty
      {
       print ("<<< BATCH FAILURE WARNING >>> NO VALID MOVED PHOTOS TO POST!")
       break
      }
      completion(.success(Notification(name: .snippetItemDidFolder, object: partMoved, userInfo: userInfo)))
     
     default: break
     
    }//switch result...
   }//FileManager.batchMoveItemsOnDisk...
 
  }//{persisted in...
 }//final func move(to destSnippet: PhotoSnippet...
//****************************************************************************************************************
 

}//extension PhotoSnippet...
//****************************************************************************************************************


