//
//  Photo Folder MO RX.swift
//  Newsman
//
//  Created by Anton2016 on 14/06/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import RxSwift
import Combine


extension PhotoFolderItem
{
//***********************************************************************************************************
//Moves wrapped Photo MO asyncronously to the destination item that conforms to Draggable protocol
 final func move(to snippet: BaseSnippet, to photoItem: Draggable?,
                 to position: PhotoItemPosition?,  completion: ( () -> () )? = nil)
//***********************************************************************************************************
 {
  print(#function)
  
  let contextResultHandler: (Result<Notification, ContextError>) -> () =
  {result in
   switch result
   {
    case .success(let notification):  NotificationCenter.default.post(notification)
    case .failure(let error):         error.log()
   }
   completion?()
  }
  
  guard let destSnippet = snippet as? PhotoSnippet else { return }
  
  MAIN_SWITCH: switch (photoItem, position)
  {
   case (nil, let position?):
    switch destSnippet.photoGroupType
    {
     case .typeGroups where position.sectionName != PhotoItemsTypes.allFolders.rawValue:
      folder.unfolder(to: destSnippet, to: position, with: contextResultHandler)
      break MAIN_SWITCH
     
     case .makeGroups: folder.isDragMoved = true 
 
     default: break
    }
    
    folder.move(to: destSnippet, to: position, with: contextResultHandler)
   
   case (let folderItem as PhotoFolderItem, let position?):
    folder.folder(to: folderItem.folder, to: position, with: contextResultHandler)
   
   case (let photoItem as PhotoItem, nil):
    folder.merge(with: photoItem.photo, with: contextResultHandler)
   
   default: break
   
  }
 }//final func move(to snippet: BaseSnippet...
//***********************************************************************************************************
}//extension PhotoFolderItem...
//***********************************************************************************************************




extension PhotoFolder
{

//*************************************   MOVE (.photoItemDidMove)  *****************************************
 final func move(to destSnippet: PhotoSnippet,
                 to destSnippetPosition: PhotoItemPosition,
                 with completion: @escaping (Result<Notification, ContextError>) -> () )
  
 /* Moves async unfoldered folder from arbitrary PhotoSnippet into detination photo snippet.
   If destination snippet == source snippet just moves folder inside snippet. */
//***********************************************************************************************************
 {
  guard isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photoFolder, operation: .move)))
   return
  } // do not process if moved folder was marked as deleted in context!
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photoFolder, operation: .move)))
   return
  }//if folder has no context it was deleted in previous context save operation.
  
  guard destSnippet.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: destSnippet, entity: .destPhotoSnippet, operation: .move)))
   return
  }// do not move folder into photo snippets marked as deleted in context!
  
  guard destSnippet.managedObjectContext != nil else
  {
   completion(.failure(.noContext(object: destSnippet, entity: .destPhotoSnippet, operation: .move)))
   return
  }//if dest snippet has no context it was deleted in previous context save operation.
  
  guard let sourceSnippet = self.photoSnippet else
  {
   completion(.failure(.noSnippet(object: self, entity: .photoFolder, operation: .move)))
   return
  }//if folder has no parent photo snippet it might be deleted from context...
 
  guard let folderSourceURL = self.url else
  {
   completion(.failure(.noURL(object: self, entity: .photoFolder, operation: .move)))
   return
  }//if no URL moved folder might be marked deleted in context...
  
  let folderedPhotos = self.folderedPhotos.filter { $0.isDeleted == false && $0.ID != nil && $0.url != nil }
  //take initially foldred photos beforehand that are not marked deleted from context!
  
  guard folderedPhotos.count > 0 else
  {
   completion(.failure(.emptyFolder(object: self, entity: .photoFolder, operation: .move)))
   self.delete() //delete such folder entirely...
   return
  }//do not move empty folders between snippets.
 
  context.performChanges(block:
  {
   if ( sourceSnippet !== destSnippet )             // if we move between different snippets...
   {
    self.shiftRowPositionsBeforeDelete()           // shift left as for deleted folder from snippet
    sourceSnippet.removeFromPhotos(NSSet(array: folderedPhotos))
    // remove all foldered photos from source snippet
    
    destSnippet.addToPhotos(NSSet(array: folderedPhotos))
    // add all photos to dest snippet
    
    sourceSnippet.removeFromFolders(self)             // remove source folder from source snippet
    destSnippet.addToFolders(self)                    // add folder to dest snippet
    self.setMovedPhotoRowPositions()                  // set up moved folder positions in new snippet
   }
   else
   {
    self.shiftRowPositionsLeft() // otherwise just shift left row positions for current groupType
   }
   
   self.photoItemPosition = destSnippetPosition       // set folder position and section title if any
   self.shiftRowPositionsRight()                      // shift folder row positions right (+1)
   
  })
  {result in
   guard case .success() = result else { return }
   
   let userInfo: [PhotoItemMovedKey: Any] = [.sourceSnippet: sourceSnippet, .position: destSnippetPosition]
   let moveNotify = Notification(name: .photoItemDidMove, object: self, userInfo: userInfo)
   
   guard sourceSnippet !== destSnippet else //same snippet?
   {
    completion(.success(moveNotify))
    return // do not move folder files on disk.
   }
   
   // proceed with moving folder with its content ( all *.JPG files) on disk...
   guard let folderDestURL = self.url else
   {
    completion(.failure(.noURL(object: self, entity: .photoFolder, operation: .move)))
    return
    
   }// generate new destination folder URL.
   
   FileManager.moveItemOnDisk(from: folderSourceURL, to: folderDestURL)
   {result in
    
    switch result
    {
     case .success:
      
      guard (self.isDeleted == false && self.ID != nil && self.url != nil) else
      {
       print ("<<< FOLDER MOVE WARNING >>> PHOTO FOLDER IS INVALID AFTER DISK MOVE!")
       break
      }
      
      completion(.success(moveNotify))
     
     case .failure(let error):
      completion(.failure(.dataFileMoveFailure(to: folderDestURL, object: self,
                                               entity: .photoFolder, operation: .folder,
                                               description: error.localizedDescription)))
     
    }//switch result...
   }//FileManager.moveItemOnDisk.
  }//context...
 }//final func move(to destSnippet: PhotoSnippet...
 
 
 
 
 
//*********************** FOLDERING ENTIRE FOLDER INTO NEW FOLDER(.photoItemDidFolder) *************************
 final func folder(to destFolder: PhotoFolder,
                   to destFolderPosition: PhotoItemPosition,
                   with completion: @escaping (Result<Notification, ContextError>) -> () )
//**************************************************************************************************************
 {
  guard self !== destFolder else { return } //no foldering folder into itself!
  
  guard isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photoFolder, operation: .folder)))
   return
  }// do not process foldering if folder was marked as deleted in context!
  
  guard destFolder.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: destFolder, entity: .destPhotoFolder, operation: .folder)))
   return
  }
  // do not process foldering if dest folder was marked as deleted in context!
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photoFolder, operation: .folder)))
   return
  }//if folder has no context it was deleted in previous context save operation.
  
  guard let sourceSnippet = self.photoSnippet else
  {
   completion(.failure(.noSnippet(object: self, entity: .photoFolder, operation: .folder)))
   return
  } //if folder has no parent photo snippet it might be deleted from context...
  
  guard let destSnippet = destFolder.photoSnippet else
  {
   completion(.failure(.noSnippet(object: destFolder, entity: .destPhotoFolder, operation: .folder)))
   return
  } //if dest folder photo snippet is NIL it might be marked deleted in context
  
  guard let destFolderURL = destFolder.url else
  {
   completion(.failure(.noURL(object: destFolder, entity: .destPhotoFolder, operation: .folder)))
   return
  }
  
  let folderedPhotos = self.folderedPhotos.filter { $0.isDeleted == false && $0.ID != nil && $0.url != nil }
  //take initially foldred photos beforehand!
  
  guard folderedPhotos.count > 0 else
  {
   completion(.failure(.emptyFolder(object: self, entity: .photoFolder, operation: .folder)))
   self.delete() //delete such folder entirely...
   return
  }
  
  let photoURLs = folderedPhotos.map{(from: $0.url!, to: destFolderURL.appendingPathComponent($0.ID!))}
  
  context.performChanges(block:
  {
   self.shiftRowPositionsBeforeDelete()  //1 - shift all folder row positions left (-1) in source snippet
   
   let count = folderedPhotos.count
   let index = destFolderPosition.row
   
   destFolder.folderedPhotos.forEach
   {photo in
    let pos = photo.getRowPosition(for: .manually)
    if ( pos >= index ) { photo.setGroupTypePosition(newPosition: pos + count, for: .manually) }
   }
   
   if index > 0 // if (0) we insert all foldered photos from 0 we do not make shift as we use photos row positions
   {
    self.folderedPhotos.forEach
    {photo in
     let pos = photo.getRowPosition(for: .manually)
     photo.setGroupTypePosition(newPosition: index + pos, for: .manually)
    }
   }
   
   self.removeFromPhotos(NSSet(array: folderedPhotos))
   destFolder.addToPhotos(NSSet(array: folderedPhotos))
   
   if ( destSnippet !== sourceSnippet )
   {
    sourceSnippet.removeFromPhotos(NSSet(array: folderedPhotos))
    destSnippet.addToPhotos(NSSet(array: folderedPhotos))
   }
   
  })
  {result  in
   guard case .success() = result else { return }
  
   FileManager.batchMoveItemsOnDisk(using: photoURLs)
   {result in
    
    let movedPhotos = folderedPhotos.filter { $0.isDeleted == false && $0.ID != nil && $0.url != nil }
    // check all moved in context after async file op if valid for further processing...
    
    let userInfo: [PhotoItemMovedKey: Any] = [ .destFolder: destFolder, .position : destFolderPosition ]
    switch result
    {
     case .failure(.batchMoveFailures(_)) where movedPhotos.isEmpty:
      print("<<< BATCH FAILURE WARNING >>> NO VALID PHOTOS ENCOUNTERED TO POST AFTER PARTIAL BATCH MOVE!")
     
     case .success where movedPhotos.isEmpty:
      print("<<< BATCH SUCCESS WARNING >>> NO VALID PHOTOS ENCOUNTERED TO POST AFTER FULL BATCH MOVE!")
     
     case .success where !movedPhotos.isEmpty :
      completion(.success(Notification(name: .photoItemDidFolder, object: movedPhotos, userInfo: userInfo)))
      self.delete()// delete empty folder finally after all succesfull moves...
     
     case .failure(.batchMoveFailures(let errorDict)) where !movedPhotos.isEmpty:
      let errorIDs = errorDict.keys.map{ $0.lastPathComponent }
      let partMoved = movedPhotos.filter{ !errorIDs.contains($0.ID!) }
      if partMoved.isEmpty
      {
       print("<<< BATCH FAILURE WARNING >>> NO PARTTIALY MOVED PHOTOS TO POST AFTER PARTIAL BATCH MOVE!")
       break
      }
      completion(.success(Notification(name: .photoItemDidFolder, object: partMoved, userInfo: userInfo)))
     
     default: break
     
    }//switch result...
   }//FileManager.batchMoveItemsOnDisk...
  }//{persisted  in
 }//final func folder(to destFolder: PhotoFolder...
 
 
 
 
 
//******************************************  MERGE WITH PHOTO   ********************************************
 final func merge(with destPhoto: Photo,
                  with completion: @escaping (Result<Notification, ContextError>) -> () )
  
/* Merges async self with destPhoto in one PhotoFolder MO creating one in the current MOC */
//***********************************************************************************************************
 {
  
  guard destPhoto.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: destPhoto, entity: .destPhoto, operation: .mergeWith)))
   return
  }
  
  guard destPhoto.managedObjectContext != nil else
  {
   completion(.failure(.noContext(object: destPhoto, entity: .destPhoto, operation: .mergeWith)))
   return
  }
  
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photoFolder, operation: .mergeWith)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photoFolder, operation: .mergeWith)))
   return
  }
  
  guard self.photoSnippet != nil else
  {
   completion(.failure(.noSnippet(object: self, entity: .photoFolder, operation: .mergeWith)))
   return
  }
  
  guard destPhoto.photoSnippet != nil else
  {
   completion(.failure(.noSnippet(object: destPhoto, entity: .destPhoto, operation: .mergeWith)))
   return
  }
  
  //otherwise we create new empty folder and move self and destination into it
  let newFolderID = UUID()
  var newFolder: PhotoFolder?
  
  context.performChanges(block:  //make changes in context async
  {
   newFolder = PhotoFolder(context: context)
   newFolder?.id = newFolderID
   newFolder?.photoSnippet = destPhoto.photoSnippet
   newFolder?.date = Date() as NSDate
   newFolder?.isSelected = false
   newFolder?.photos = NSSet()
   
   GroupPhotos.rowPositioned.forEach //setting new merged folder row positions
   {type in
    if type.isFixedPositioned //if fixed positioned sections we take position == section count for group type
    {
     let title = newFolder?.sectionTitle(for: type)
     let row = newFolder?.otherUnfoldered(for: type).count ?? 0
     let kp = type.sectionKeyPath
     let newFolderPosition = PhotoItemPosition(sectionName: title, row: row, for: kp)
     newFolder?.setPhotoItemPosition(newPosition: newFolderPosition , for: type)
    }
    else // otherwise set position == dest photo position for group type
    {
     let destPhotoPosition = destPhoto.getPhotoItemPosition(for: type)
     newFolder?.setPhotoItemPosition(newPosition: destPhotoPosition , for: type)
     newFolder?.shiftRowPositionsRight(for: type)
    }
   }
   
  })
  {result  in
   guard  case .success = result else { return }
   
   guard let newFolderURL = newFolder!.url else
   {
    completion(.failure(.noURL(object: newFolder!, entity: .photoFolder, operation: .mergeWith)))
    return
   }
   
   FileManager.createDirectoryOnDisk(at: newFolderURL)
   {result in
    switch result
    {
     case .success:
      /* In some particular cases for instance we drag 1 folder + 1 photo + N other folders into <.allFolders> section (Photo Snippet current group type is set to <.typeGroups>) we have to merge folder into PhotoItem and this photo (destPhoto here) item may be foldered in some other folder, so we select context method (folder/refolder) based on this fact for destPhoto as well... */
      (destPhoto.folder == nil ? destPhoto.folder : destPhoto.refolder)(newFolder!, .zero)
      {result in
       switch result
       {
        case .success(let notification):
         NotificationCenter.default.post(notification)
         self.folder(to: newFolder!, to: .zero)
         {result in
          switch result
          {
           case .success(let notification):
            NotificationCenter.default.post(notification)
            completion(.success(Notification(name: .photoItemDidMerge, object: newFolder!, userInfo: nil)))
           
           case .failure(let error): completion(.failure(error))
          }//switch result...
         }//(self.folder == nil ? self.folder : self.refolder)...
        
       case .failure(let error): completion(.failure(error))
      }//switch result...
     }//destPhoto.folder(to: newFolder!, to: .zero)...
     
    case .failure(let error):
     completion(.failure(.dataFolderCreateFailure(at: newFolderURL,
                                                  object: self,
                                                  entity: .photoFolder,
                                                  operation: .mergeWith,
                                                  description: error.localizedDescription)))
    }//switch result...
    
   }//FileManager.createDirectoryOnDisk...
  }
 } //final func merge (sync)
//***********************************************************************************************************
 
 
 
 
 
//***********************  UN:FOLDER ALL FOLDER PHOTOS(.folderItemDidUNfolder)  *****************************
 final func unfolder(to destSnippet: PhotoSnippet,
                     to destSnippetPosition: PhotoItemPosition,
                     with completion: @escaping (Result<Notification, ContextError>) -> () )
  
//unfolder async all foldered photos into destSnippetPosition and delete emtified folder
//***********************************************************************************************************
 {
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photoFolder, operation: .unfolder)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photoFolder, operation: .unfolder)))
   return
  }
  
  guard let sourceSnippet = self.photoSnippet else //take the source snippet ref before move!!!
  {
   completion(.failure(.noSnippet(object: self, entity: .photoFolder, operation: .unfolder)))
   return
  }
  
  guard destSnippet.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: destSnippet, entity: .destPhotoSnippet, operation: .unfolder)))
   return
  }
  
  guard destSnippet.managedObjectContext != nil  else
  {
   completion(.failure(.noContext(object: destSnippet, entity: .destPhotoSnippet, operation: .unfolder)))
   return
  }
  
  guard let destSnippetURL = destSnippet.url else //take the source snippet ref before move!!!
  {
   completion(.failure(.noURL(object: destSnippet, entity: .destPhotoSnippet, operation: .unfolder)))
   return
  }
  
  let folderedPhotos = self.folderedPhotos.filter{ $0.isDeleted == false && $0.ID != nil && $0.url != nil }
  //take initially foldred photos beforehand!
  
  let photoURLs = folderedPhotos.map{(from: $0.url!, to: destSnippetURL.appendingPathComponent($0.ID!))}
 
  context.performChanges(block: //make changes in context async...
  {
   folderedPhotos.forEach
   {photo in
    // if we have different snippet to unfolder into we move photo between snippets as well!
    if ( destSnippet !== sourceSnippet )
    {
     self.removeFromPhotos(photo)
     sourceSnippet.removeFromPhotos(photo)          // delete photo from old snippet
     destSnippet.addToPhotos(photo)                 // insert photo to new one
     photo.setMovedPhotoRowPositions()
    }
    else
    {
     photo.setUnfolderingPhotoRowPositions()        // set up all positions for all positioned group types
     self.removeFromPhotos(photo)                   // remove from source folder
    }
   
    photo.photoItemPosition = destSnippetPosition   // set new row postion and section
    photo.shiftRowPositionsRight()                  // shift row positions right (+1) after insert
   }//self.folderedPhotos.forEach...
  
  })//context
  {result in
   guard case .success = result else { return }
   
   FileManager.batchMoveItemsOnDisk(using: photoURLs)
   {result in
    
    let movedPhotos = folderedPhotos.filter { $0.isDeleted == false && $0.ID != nil && $0.url != nil }
    let userInfo: [PhotoItemMovedKey: Any] = [ .position : destSnippetPosition ]
   
    switch result
    {
     case .failure(.batchMoveFailures(_)) where movedPhotos.isEmpty:
      print("<<< BATCH FAILURE WARNING >>> NO VALID PHOTOS ENCOUNTERED TO POST AFTER PARTIAL BATCH MOVE!")
     
     case .success where movedPhotos.isEmpty:
      print("<<< BATCH SUCCESS WARNING >>> NO VALID PHOTOS ENCOUNTERED TO POST AFTER FULL BATCH MOVE!")
     
     case .success where !movedPhotos.isEmpty:
      completion(.success(Notification(name: .folderItemDidUnfolder, object: movedPhotos, userInfo: userInfo)))
      self.delete()// delete empty folder finally after all succesful moves...
     
     case .failure(.batchMoveFailures(let errorDict)) where !movedPhotos.isEmpty:
      let errorIDs = errorDict.keys.map{$0.lastPathComponent}
      let partMoved = movedPhotos.filter{ !errorIDs.contains($0.ID!) }
      if partMoved.isEmpty
      {
       print("<<< BATCH FAILURE WARNING >>> NO PARTTIALY MOVED PHOTOS TO POST AFTER PARTIAL BATCH MOVE!")
       break
      }
      completion(.success(Notification(name: .folderItemDidUnfolder, object: partMoved, userInfo: userInfo)))
     default : break
    }//switch result...
   }//FileManager.batchMoveItemsOnDisk...
  }//{persisted in
 }//final func unfolder(to itemPosition: PhotoItemPosition,...
//***********************************************************************************************************
 
 
 
 
 
//***********************************************************************************************************
 final func processSinglePhoto() -> Completable
//***********************************************************************************************************
 {
  //undoer.removeAllOperations(for: self) as Void
 
  Observable.combineLatest(MOC$, SINGLE$, URL$, ID$, DATE$, SNIPPET$)
   .map{ ($0, $1, $1.url, $2, $3, $4, $5) }
   .flatMap {context, singlePhoto, singlePhotoURL, folderURL, folderID, folderDate, folderSnippet -> Completable in
   
    let moveToRoot = Observable.just(singlePhoto)
     .map { $0.url }
     .flatMap {toURL -> Completable in
       guard let fromURL = singlePhotoURL else { return .empty() }
       guard let toURL = toURL else { return .empty() }
       return FileManager.moveItemOnDisk(from: fromURL, to: toURL)
     }
     .do(onCompleted: { NotificationCenter.default.post(name: .singleItemDidUnfolder, object: singlePhoto) })
     .asCompletable()
    
    return context.performCnangesCompletable
    {
     singlePhoto.setSinglePhotoRowPositions()     // while in folder set all new row positions undoably!
     self.removeFromPhotos(singlePhoto)           // remove single photo from source folder!
     folderSnippet.removeFromFolders(self)
     context.delete(self)
    }
    .andThen(moveToRoot)
    .andThen(FileManager.removeItemFromDisk(at: folderURL))
    .andThen(self.undoer.removeAllOperations(for: self))
    
  }.asCompletable()
  
 }
 //***********************************************************************************************************
 
//***********************************************************************************************************
 final func processSinglePhoto() -> AnyPublisher<Void, ManagedObjectError>
//***********************************************************************************************************
 {
  undoer.removeAllOperations(for: self) as Void
  
  return Publishers.CombineLatest4(MOC$$, SINGLE$$, URL$$, ID$$).combineLatest(DATE$$, SNIPPET$$)
  .print("Single Process -->>> Combine Latest 6")
  .map{ ($0.0, $0.1, $0.1.url, $0.2, $0.3, $1, $2) }
  .flatMap {[unowned self] moc, single, singleURL, FURL, FID, FD, FS -> AnyPublisher<Void, ManagedObjectError> in
   
   let moveToRoot = Just<Photo>(single)
    .mapError{_ in ManagedObjectError.unknown}
    .flatMap{ single -> AnyPublisher<Void, ManagedObjectError> in
     guard let fromURL = singleURL else { return Empty().eraseToAnyPublisher() }
     guard let toURL = single.url else { return Empty().eraseToAnyPublisher() }
     return FileManager.moveItemOnDisk(from: fromURL, to: toURL)
     .mapError{ ManagedObjectError.moveFailure(from: fromURL, to: toURL, description: $0.localizedDescription) }
     .eraseToAnyPublisher()
   }
   .handleEvents(receiveCompletion:
    {_ in NotificationCenter.default.post(name: .singleItemDidUnfolder, object: single)})
   .eraseToAnyPublisher()
   
   
   let deleteFolder = Deferred {
    FileManager.removeItemFromDisk(at: FURL)
    .mapError{ ManagedObjectError.deleteFailure(at: FURL, description: $0.localizedDescription) }
    .print("Single --->>> Proccess: <Delete Folder>")
   }.eraseToAnyPublisher()
    
   let singleMove = Deferred {
    moc.persist {[unowned self] in
     single.setSinglePhotoRowPositions()     // while in folder set all new row positions undoably!
     self.removeFromPhotos(single)           // remove single photo from source folder!
     moc.delete(self)
    }.mapError { ManagedObjectError.contextSaveFailure(description: $0.localizedDescription) }
    .print("Single Proccess: --->>>> <MOVE IN MOC>")
   }.eraseToAnyPublisher()
   
   return singleMove.append(moveToRoot).append(deleteFolder).eraseToAnyPublisher()
   
  }.eraseToAnyPublisher()
  
 }//processSinglePhoto Combine Publisher...
//***********************************************************************************************************
 
 
 
 
 
 
//***********************************************************************************************************
 final func processSinglePhoto(with completion: @escaping (Result<Photo, ContextError>) -> ())
//***********************************************************************************************************
 {
  print(#function)
  
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .singlePhotoFolder, operation: .unfolder)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .singlePhotoFolder, operation: .unfolder)))
   return
  }
  
  guard let singlePhoto = self.folderedPhotos.first else
  {
   completion(.failure(.emptyFolder(object: self, entity: .singlePhotoFolder, operation: .unfolder)))
   return
  }
  
  guard singlePhoto.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: singlePhoto, entity: .singlePhoto, operation: .unfolder)))
   return
  }
  
  guard singlePhoto.managedObjectContext != nil  else
  {
   completion(.failure(.noContext(object: singlePhoto, entity: .singlePhoto, operation: .unfolder)))
   return
  }
  
  guard let singlePhotoSourceURL = singlePhoto.url else //take single photo URL before move!!!
  {
   completion(.failure(.noURL(object: singlePhoto, entity: .singlePhoto, operation: .unfolder)))
   return
  }
  
  if singlePhoto.isDragAnimating { return }
  
  context.performChanges(block: //make changes in context async.
  {
   singlePhoto.setSinglePhotoRowPositions()     // while in folder set all new row positions undoably!
   self.removeFromPhotos(singlePhoto)           // remove single photo from source folder!
  })
  {result in
   guard  case .success = result else { return }
   
   guard let singlePhotoDestURL = singlePhoto.url else
   {
    completion(.failure(.noURL(object: singlePhoto, entity: .singlePhotoFolder, operation: .unfolder)))
    return
   }
   
   FileManager.moveItemOnDisk(from: singlePhotoSourceURL, to: singlePhotoDestURL)
   {result in
    switch result
    {
     case .success():
      defer
      {
       self.isSingleElementFolder = true
       self.delete()
      }
      
      guard (singlePhoto.isDeleted == false && singlePhoto.ID != nil && singlePhoto.url != nil) else
      {
       print ("<<< SINGLE MOVE WARNING >>> SINGLE PHOTO IS INVALID AFTER DISK MOVE AND NOT POSTED!")
       break
      }
      completion(.success(singlePhoto))
      
     case .failure(let error):
 
      completion(.failure(.dataFileMoveFailure(to: singlePhotoDestURL,
                                               object: singlePhoto, entity: .photo,
                                               operation: .unfolder,
                                               description: error.localizedDescription)))
    }
   }//FileManager.moveItemOnDisk(...
  }//{persisted in...
 } //final func manageSinglePhoto
//***********************************************************************************************************
 

}//extension PhotoFolder...
//***********************************************************************************************************
