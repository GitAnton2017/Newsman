//
//  Photo Item Wrapper Moves.swift
//  Newsman
//
//  Created by Anton2016 on 19/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import RxSwift


extension PhotoItem
{
//**************************************************************************************************************
//Moves wrapped Photo MO asyncronously to the destination item that conforms to Draggable protocol
 final func move(to snippet: BaseSnippet, to photoItem: Draggable?,
                 to position: PhotoItemPosition?, completion: ( () -> () )? = nil )
//**************************************************************************************************************
 {
  print (#function)
  
  let contextResultHandler: (Result<Notification, ContextError>) -> () =
  {result in
   switch result
   {
    case .success(let notification): NotificationCenter.default.post(notification)
    case .failure(let error):        error.log()
   }
   completion?()
  }
 
  guard let destSnippet = snippet as? PhotoSnippet else { return }
  
  MAIN_SWITCH: switch (self.folder, photoItem, position)
  {
   // <<<<< ------ REFOLDER (.photoItemDidRefolder) -------- >>>>>
   case let ( sourceFolder?,  destFolder as PhotoFolderItem, position? )
    where sourceFolder !== destFolder.folder:
     photo.refolder(to: destFolder.folder, to: position, with: contextResultHandler)
   
   // <<<<< ------ UNFOLDER (.photoItemDidUnfolder) -------- >>>>>
   case let ( _?,  nil, position? ):
     photo.unfolder(to: destSnippet, to: position, with: contextResultHandler)
 
   // <<<<< ------ FOLDER (.photoItemDidFolder) -------  >>>>>
   case let ( nil, destFolder as PhotoFolderItem, position? ):
    photo.folder(to: destFolder.folder, to: position, with: contextResultHandler)
  
   // <<<<< ------ MOVE BETWEEN SNIPPETS (.photoItemDidMove) -------  >>>>>
   case let ( nil, nil, position? ):
    switch destSnippet.photoGroupType
    {
     case .typeGroups
      where position.sectionName != PhotoItemsTypes.allPhotos.rawValue: completion?()
      break MAIN_SWITCH
     
     case .makeGroups:
      photo.isDragMoved = true
     
     default: break
    }
    
    photo.move(to: destSnippet, to: position, with: contextResultHandler)
   
   // <<<<< ------ MOVE INSIDE FOLDER (.foldredPhotoDidMove) -------  >>>>>
   case let ( sourceFolder?, destFolder as PhotoFolderItem, position? )
    where sourceFolder.objectID == destFolder.folder.objectID:
     photo.moveInsideFolder(to: position, with: contextResultHandler)
   
   
   // <<<<< ------ MERGE WITH PHOTO (.photoItemDidMerge) -------  >>>>>
   case let (_ , destPhoto as PhotoItem, nil):
    photo.merge(with: destPhoto.photo, with: contextResultHandler)
   
   default: break
  }//MAIN_SWITCH: switch ...
  
 }//final func move....
//**************************************************************************************************************
 
 
}//extension PhotoItem...
//**************************************************************************************************************






extension Photo
{
//***********************************  FOLDER (.photoItemDidFolder) ********************************************
 final func folder(to destFolder: PhotoFolder,
                   to destFolderPosition: PhotoItemPosition,
                   with completion: @escaping (Result<Notification, ContextError>) -> () )
//**************************************************************************************************************
/* Moves async unfoldered photo into the destionation folder and
   into specified row position in destination folder. */
 {
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photo, operation: .folder)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photo, operation: .folder)))
   return
  }
  
  guard destFolder.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: destFolder, entity: .destPhotoFolder, operation: .folder)))
   return
  }
  
  guard destFolder.managedObjectContext != nil else
  {
   completion(.failure(.noContext(object: destFolder, entity: .destPhotoFolder, operation: .folder)))
   return
  }
  
  if let folder = self.folder, folder === destFolder
  {
   completion(.failure(.inFolder(object: self, folder: folder, entity: .photo, operation: .folder)))
   return
  }
  
  guard let sourceSnippet = self.photoSnippet else //take the source snippet ref before move!!!
  {
   completion(.failure(.noSnippet(object: self, entity: .photo, operation: .folder)))
   return
  }
  
  guard let destSnippet = destFolder.photoSnippet else //take the dest snippet ref before move!!!
  {
   completion(.failure(.noSnippet(object: destFolder, entity: .photoFolder, operation: .folder)))
   return
  }
  
  guard let photoSourceURL = self.url else  //take photo source URL before move with context!
  {
   completion(.failure(.noURL(object: self, entity: .photoFolder, operation: .folder)))
   return
  }
  
  let userInfo: [PhotoItemMovedKey: Any] = [.destFolder: destFolder]
  NotificationCenter.default.post(name: .photoItemWillFolder, object: self, userInfo: userInfo)
  
  let sourceSnippetPosition = self.getPhotoItemPosition(for: sourceSnippet.photoGroupType)
  //take old position of photo for undo/redo events set-up...
  
  let unfolderOp = undoer.registerUndo(named: "FOLDER: [\(id?.uuidString ?? "")]", with: [self, destFolder])
  {[weak self] completion in
   self?.unfolder(to: sourceSnippet, to: sourceSnippetPosition)
   {result in
    defer { completion() }
    switch result
    {
     case .success(let notification): NotificationCenter.default.post(notification)
     case .failure(let error):        error.log()
    }
   }
  }
  
 
  let unfolderToken = NotificationCenter.default.addObserver(forName: .photoItemWillUnfolder,
                                                             object: self,
                                                             queue: .main)
  {[weak unfolderOp, weak destFolder] notification in
   guard let op = unfolderOp, let destFolder = destFolder else { return }
   if op.isExecuted { return }
   guard notification.name == .photoItemWillUnfolder else { return }
   guard let photo = notification.object as? Photo else { return }
   if photo.undoer.isLastOperation(op) { return }
   guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
   guard let sourceFolder = userInfo[.sourceFolder] as? PhotoFolder else { return }
   guard sourceFolder.objectID == destFolder.objectID else { return }

   op.isExecuted = true
   op.undo?.isExecuted = false //redo
   op.redo?.isExecuted = false //undo


   print ("<<<<<< SKIPPED >>>>>>: [\(op.name ?? "Unnamed")] for target: [\(String(describing: photo.ID))]")
  }

  undoOperationsTokens.insert(unfolderToken as! NSObject)

  let folderToken = NotificationCenter.default.addObserver(forName: .photoItemWillFolder, object: self, queue: .main)
  {[weak unfolderOp, weak destFolder] notification in
   guard let op = unfolderOp, let destFolder = destFolder else { return }
   if !op.isExecuted { return }
   guard notification.name == .photoItemWillFolder else { return }
   guard let photo = notification.object as? Photo else { return }
   if photo.undoer.isLastOperation(op) { return }
   guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
   guard let df = userInfo[.destFolder] as? PhotoFolder else { return }
   guard df.objectID == destFolder.objectID else { return }

   op.isExecuted = false
   op.undo?.isExecuted = true //redo
   op.redo?.isExecuted = true //undo

   print ("<<<<<< UNSKIPPED >>>>>>: [\(op.name ?? "Unnamed")] for target: [\(String(describing: photo.ID))]")
  }

  undoOperationsTokens.insert(folderToken as! NSObject)
  
 
  var dfp = destFolderPosition
  
  context.performChanges(block:                 //make changes in context async... NO SAVE CONTEXT!!
  {
   self.shiftRowPositionsBeforeDelete()         //shift left (-1) all positions as if we delete photo undoably...
   destFolder.addToPhotos(self)                 //move photo to destination folder...
  
   if ( destSnippet !== sourceSnippet )         //if we have different snippets!
   {
    sourceSnippet.removeFromPhotos(self)        //delete photo from old snippet ...
    destSnippet.addToPhotos(self)               //insert photo to new one ...
   
   }
   
   
   dfp.row = min(dfp.row, destFolder.count - 1) 
   self.photoItemPosition = dfp                  //set new row position in folder undoably...
   self.shiftFolderedRight()                    //shift right (+1) other foldered row positions undoably...
  
   
  })
  {result  in
   guard case .success = result else { return }
   
   guard let photoDestURL = self.url else
   {
    completion(.failure(.noURL(object: self, entity: .photoFolder, operation: .folder)))
    return
   }
   
   FileManager.moveItemOnDisk(from: photoSourceURL, to: photoDestURL)
   {result in
    DispatchQueue.main.async
    {
     switch result
     {
      case .success: //success(VOID)
    
       //prepare <.photoItemDidFolder> notfication to be posted to subscribers:
       //PhotoSnippetViewController .moveToFolder(after notification: Notification)...
       //PhotoFolderCell            .moveToFolder(after notification: Notification)...
       //ZoomView                   .moveToFolder(after notification: Notification)...
       
       guard (self.isDeleted == false && self.ID != nil && self.url != nil) else
       {
        print ("<<< PHOTO MOVE SUCCESS WARNING >>> PHOTO IS INVALID AFTER MOVE!")
        break
       }
       
       guard (destFolder.isDeleted == false && destFolder.ID != nil && destFolder.url != nil) else
       {
        print ("<<< PHOTO MOVE SUCCESS WARNING >>> PHOTO DESTINATION FOLDER IS INVALID AFTER MOVE!")
        break
       }
       
       let userInfo: [PhotoItemMovedKey: Any] = [.destFolder: destFolder, .position: dfp]
       completion(.success(Notification(name: .photoItemDidFolder, object: self, userInfo: userInfo)))
      
  
      case .failure(let error):
       completion(.failure(.dataFileMoveFailure(to: photoDestURL, object: self,
                                                entity: .photo, operation: .folder,
                                                description: error.localizedDescription)))
      
     }//switch result...
    }//DispatchQueue.main.async...
   }//FileManager.moveItemOnDisk...
  }//{persisted in...
 }//final func folder(to destination...
 //**************************************************************************************************************
 
 
 
 
//**************************************************************************************************************
 final func moveOnDisk(from sourceFolder: PhotoFolder,
                       from photoSourceURL: URL, to photoDestURL: URL,
                       with notification: Notification) -> Result<Notification, ContextError>
//**************************************************************************************************************
 {
  switch FileManager.moveItemOnDisk(from: photoSourceURL, to: photoDestURL) as Result<Void, Error>//sync move...
  {
   case .success: //success(Void) of FileManager...
    if ( sourceFolder.isEmpty ) { sourceFolder.delete() }
    else if ( sourceFolder.count == 1 )
    {
     sourceFolder.processSinglePhoto {result in
      switch result
      {
       case .success(let singlePhoto):
        NotificationCenter.default.post(name: .singleItemDidUnfolder, object: singlePhoto)
       
       case .failure(let error): error.log() //otherwise log an error message...
      }
     }
    }//if sourceFolder.isEmpty...
   
    return .success(notification)
   
   case .failure(let error):
    return .failure(.dataFileMoveFailure(to: photoDestURL, object: self,
                                        entity: .photo, operation: .refolder,
                                        description: error.localizedDescription))
   
  }//switch result...
 }//final func moveOnDisk...
//**************************************************************************************************************
 
 
 
 
//**************************************************************************************************************
 final func moveOnDisk(from sourceFolder: PhotoFolder,
                       from photoSourceURL: URL, to photoDestURL: URL,
                       with notification: Notification,
                       with completion: @escaping (Result<Notification, ContextError>) -> () )
//**************************************************************************************************************
 {
  let moveFileResultHandler: ( Result <Void, Error>, (() -> ())? ) -> () =
  {result, finalSuccessAction in
   switch result
   {
   case .success:
    completion(.success(notification))
    DispatchQueue.main.async { finalSuccessAction?() }
    
   case .failure(let error):
    completion(.failure(.dataFileMoveFailure(to: photoDestURL, object: self,
                                             entity: .photo, operation: .unfolder,
                                             description: error.localizedDescription)))
    
   }//switch result...
  }
  
  switch sourceFolder.count //take foldered photos count sync here...
  {
   case 0: //we have empty folder in context and one photo left to move on disk...
    FileManager.moveItemOnDisk(from: photoSourceURL, to: photoDestURL)
    {result in
     moveFileResultHandler(result){ sourceFolder.delete() }
    }
   
   case 1:
    let result: Result<Void, Error> = FileManager.moveItemOnDisk(from: photoSourceURL, to: photoDestURL)
    moveFileResultHandler(result)
    {
     sourceFolder.processSinglePhoto
     {result in
      switch result
      {
       case .success(let singlePhoto):
        NotificationCenter.default.post(name: .singleItemDidUnfolder, object: singlePhoto)
   
       case .failure(let error): error.log() //otherwise log an error message...
      }
     }//sourceFolder.processSinglePhoto...
    }
   
   
   default:
    FileManager.moveItemOnDisk(from: photoSourceURL, to: photoDestURL)
    {result in
     moveFileResultHandler(result, nil)
    }
   
  }//switch sourceFolder.count...
    
 }//final func moveOnDisk(from sourceFolder
//**************************************************************************************************************
 
 
 

 
//********************************** REFOLDER (.photoItemDidRefolder) ******************************************
 final func refolder(to destFolder: PhotoFolder,
                     to destFolderPosition: PhotoItemPosition,
                     with completion: @escaping (Result<Notification, ContextError>) -> () )
//**************************************************************************************************************
  /* Moves async foldered photo to the destionation folder.
   If source folder has 1 Photo after this operation the single photo is unfoldered into its photo snippet.
   Empty source folder is deleted. */
 {
  
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photo, operation: .refolder)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photo, operation: .refolder)))
   return
  }
  
  guard let sourceSnippet = self.photoSnippet else //take the source snippet ref before move!!!
  {
   completion(.failure(.noSnippet(object: self, entity: .photo, operation: .refolder)))
   return
  }
  
  guard destFolder.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: destFolder, entity: .destPhotoFolder, operation: .refolder)))
   return
  }
  
  guard destFolder.managedObjectContext != nil else
  {
   completion(.failure(.noContext(object: destFolder, entity: .destPhotoFolder, operation: .refolder)))
   return
  }
  
  guard let destSnippet = destFolder.photoSnippet else //take the dest snippet ref before move!!!
  {
   completion(.failure(.noSnippet(object: destFolder, entity: .photoFolder, operation: .refolder)))
   return
  }
  
  guard let sourceFolder = self.folder else //Photo must be foldered at this stage!
  {
   completion(.failure(.noFolder(object: self, entity: .photo, operation: .refolder)))
   return
  }
  
  guard sourceFolder !== destFolder else { return } //Photo must be in different source folder!!!
  
  guard let photoSourceURL = self.url else //take photo source URL before move!
  {
   completion(.failure(.noURL(object: self, entity: .photo, operation: .refolder)))
   return
  }
  
  context.performChanges(block:   //make changes in context async.
  {
   self.shiftFolderedLeft()              // shift row positions left (-1) in source folder...
   destFolder.addToPhotos(self)          // move photo to new folder...
   
   if ( destSnippet !== sourceSnippet )  // if we have different snippets...
   {
    sourceSnippet.removeFromPhotos(self) // delete photo from old snippet ...
    destSnippet.addToPhotos(self)        // insert photo to new one ...
   }
   
   sourceFolder.removeFromPhotos(self)          // remove from old folder undoably...
   self.photoItemPosition = destFolderPosition  // set new row position in new folder ...
   self.shiftFolderedRight()                    // shift row positions right (+1) in new folder...
    
  })
  {result in
   
   guard  case .success = result else { return }
   
   guard let photoDestURL = self.url else //generate moved photo new dest URL...
   {
    completion(.failure(.noURL(object: self, entity: .photo, operation: .refolder)))
    return
   }
   
   //prepare <.photoItemDidRefolder> notfication to be posted to subscribers:
   //PhotoFolderCell .moveBetweenFolders(after notification: Notification)...
   //ZoomView        .moveBetweenFolders(after notification: Notification)...
   
   let userInfo: [PhotoItemMovedKey: Any] = [.sourceFolder : sourceFolder,
                                             .destFolder   : destFolder,
                                             .position     : destFolderPosition]
   
   let notify = Notification(name: .photoItemDidRefolder, object: self, userInfo: userInfo)
   
   completion(self.moveOnDisk(from: sourceFolder, from: photoSourceURL, to: photoDestURL, with: notify))
   
  }//{persisted in
 }//final func refolder(to destination...
//**************************************************************************************************************


 
 
 
//********************************** UNFOLDER (.photoItemDidUNfolder) ******************************************
 final func unfolder(to destSnippet: PhotoSnippet,
                     to destSnippetPosition: PhotoItemPosition,
                     with completion: @escaping (Result<Notification, ContextError>) -> () )
//**************************************************************************************************************
 /* Moves async photo to destSnippet to destSnippetPosition from current folder.
 If photo folder has only 1 photo after the move the single one is unfoldered into its snippet.
 Empty source folder is deleted. */
 {
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photo, operation: .refolder)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photo, operation: .unfolder)))
   return
  }
  
  guard let sourceSnippet = self.photoSnippet else //take the source snippet ref before move!!!
  {
   completion(.failure(.noSnippet(object: self, entity: .photo, operation: .unfolder)))
   return
  }
  
  guard let sourceFolder = self.folder else
  {
   completion(.failure(.noFolder(object: self, entity: .photo, operation: .unfolder)))
   return
  }
  
  guard let photoSourceURL = self.url else //Make copy of Photo MO URL before moving!
  {
   completion(.failure(.noURL(object: self, entity: .photo, operation: .unfolder)))
   return
  }
  
  let userInfo: [PhotoItemMovedKey: Any] = [.sourceFolder: sourceFolder]
  NotificationCenter.default.post(name: .photoItemWillUnfolder, object: self, userInfo: userInfo)
 
  let sourceFolderPosition = self.getPhotoItemPosition(for: .manually)
  //take old position of photo for undo/redo events set-up...
  
  let folderOp = undoer.registerUndo(named: "UNFOLDER: [\(id?.uuidString ?? "")]", with: [self, sourceFolder])
  {[weak self] completion in
   self?.folder(to: sourceFolder, to: sourceFolderPosition)
   {result in
    defer { completion() }
    switch result
    {
     case .success(let notification): NotificationCenter.default.post(notification)
     case .failure(let error):        error.log()
    }
   }
  }
  
  let folderToken = NotificationCenter.default.addObserver(forName: .photoItemWillFolder,
                                                           object: self,
                                                           queue: .main)
  {[weak folderOp, weak sourceFolder] notification in
   guard let op = folderOp, let sourceFolder = sourceFolder else { return }
   if op.isExecuted { return }
   guard notification.name == .photoItemWillFolder else { return }
   guard let photo = notification.object as? Photo else { return }
   if photo.undoer.isLastOperation(op) { return }
   guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
   guard let destFolder = userInfo[.destFolder] as? PhotoFolder else { return }
   guard sourceFolder.objectID == destFolder.objectID else { return }

   op.isExecuted = true
   op.undo?.isExecuted = false //redo
   op.redo?.isExecuted = false //undo

   print ("<<<<<< SKIPPED >>>>>>: [\(op.name ?? "Unnamed")] for target: [\(String(describing: photo.ID))]")
  }

  undoOperationsTokens.insert(folderToken as! NSObject)

  let unfolderToken = NotificationCenter.default.addObserver(forName: .photoItemWillUnfolder,
                                                             object: self,
                                                             queue: .main)
  {[weak folderOp, weak sourceFolder] notification in
   guard let op = folderOp, let sourceFolder = sourceFolder else { return }
   if !op.isExecuted { return }
   guard notification.name == .photoItemWillUnfolder else { return }
   guard let photo = notification.object as? Photo else { return }
   if photo.undoer.isLastOperation(op) { return }
   guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
   guard let sf = userInfo[.sourceFolder] as? PhotoFolder else { return }
   guard sourceFolder.objectID == sf.objectID else { return }

   op.isExecuted = false
   op.undo?.isExecuted = true //redo
   op.redo?.isExecuted = true //undo


   print ("<<<<<< UNSKIPPED >>>>>>: [\(op.name ?? "Unnamed")] for target: [\(String(describing: photo.ID))]")
  }

  undoOperationsTokens.insert(unfolderToken as! NSObject)
  
  var dsp = destSnippetPosition
  
  context.performChanges(block:     //make changes in context async.
  {
   // if we have different snippet to unfolder into we move photo between snippets as well!
   if ( destSnippet !== sourceSnippet )
   {
    self.shiftRowPositionsBeforeDelete() 
    sourceFolder.removeFromPhotos(self)
    sourceSnippet.removeFromPhotos(self)         // delete photo from old snippet
    destSnippet.addToPhotos(self)                // insert photo to new one
    self.setMovedPhotoRowPositions()
   }
   else
   {
    self.setUnfolderingPhotoRowPositions()        // set up all positions for all positioned group types
    sourceFolder.removeFromPhotos(self)           // remove from source folder
   }
   
   
   let sectionCount = destSnippet.numberOfphotoObjects(with: dsp.sectionName) - 1
   dsp.row = min(dsp.row, sectionCount)
   self.photoItemPosition = dsp                   // set new row postion and section
   self.shiftRowPositionsRight()                  // move positions right after insert
   
  })
  {result in
   
   guard case .success = result else { return }
   
   guard let photoDestURL = self.url else //generate moved photo new dest URL...
   {
    completion(.failure(.noURL(object: self, entity: .photo, operation: .unfolder)))
    return
   }
   
   //prepare <.photoItemDidUnfolder> notfication to be posted to subscribers:
   //PhotoSnippetViewController .moveFromFolder(after notification: Notification)...
   //PhotoFolderCell            .moveFromFolder(after notification: Notification)...
   //ZoomView                   .moveFromFolder(after notification: Notification)...
   
   let userInfo: [PhotoItemMovedKey: Any] = [.sourceFolder: sourceFolder, .position: dsp]
   let notify = Notification(name: .photoItemDidUnfolder, object: self, userInfo: userInfo)
   let result = self.moveOnDisk(from: sourceFolder, from: photoSourceURL,to: photoDestURL, with: notify)
   completion(result)
   
  }//{persisted in
  
 }//final func unfolder(to itemPosition: PhotoItemPosition,...
//**************************************************************************************************************

 

 
//************************************** MOVE (.photoItemDidMove) **********************************************
 final func move(to destSnippet: PhotoSnippet,
                 to destSnippetPosition: PhotoItemPosition,
                 with completion: @escaping (Result<Notification, ContextError>) -> () )
//**************************************************************************************************************
 /* Moves async unfoldered photo from arbitrary source snippet into detination snippet.
 If destination snippet is the same as the source snippet (===) the method moves inside snippet */

 {
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photo, operation: .move)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photo, operation: .move)))
   return
  }
  
  guard destSnippet.isDeleted == false  else
  {
   completion(.failure(.isDeleted(object: destSnippet, entity: .destPhotoSnippet, operation: .move)))
   return
  }
  
  guard destSnippet.managedObjectContext != nil  else
  {
   completion(.failure(.isDeleted(object: destSnippet, entity: .destPhotoSnippet, operation: .move)))
   return
  }
  
  guard  let sourceSnippet = self.photoSnippet else //take the source snippet ref before move!!!
  {
   completion(.failure(.noSnippet(object: self, entity: .photo, operation: .move)))
   return
  }
  
  guard let photoSourceURL = self.url else //Make copy of Photo MO URL before moving...
  {
   completion(.failure(.noURL(object: self, entity: .photo, operation: .move)))
   return
  }
  
  
  context.performChanges(block:  //make changes in context async.
  {
   if ( sourceSnippet !== destSnippet )   // if we move between different snippets...
   {
    self.shiftRowPositionsBeforeDelete()      // 1 - shift left as for deleted from snippet
    sourceSnippet.removeFromPhotos(self)      // 2 - remove photo from source snippet
    destSnippet.addToPhotos(self)             // 3 - add to destination snippet
    self.setMovedPhotoRowPositions()          // 4 - set up moved photo all positions in new snippet
   }
   else
   {
    self.shiftRowPositionsLeft() // otherwise just shift left row positions for current groupType
   }
   
   self.photoItemPosition = destSnippetPosition // 5 - set new photo position and section title if any
   self.shiftRowPositionsRight()                // 6 - shift row positions right (+1)
   
  })
  {result in
   
   guard  case .success = result else { return }
   
   //prepare <.photoItemDidMove> notfication to be posted to subscribers:
   //PhotoSnippetViewController .moveItem(after notification: Notification)...
   
   let userInfo: [PhotoItemMovedKey: Any] = [.sourceSnippet: sourceSnippet, .position: destSnippetPosition]
   let moveNotify = Notification(name: .photoItemDidMove, object: self, userInfo: userInfo)
   
   guard sourceSnippet !== destSnippet else //same snippet???
   {
    completion(.success(moveNotify))
    return // do not move file on disk and just return here.
   }
   
   // proceed with moving photo *.JPG file on disk...
   guard let photoDestURL = self.url else //generate new photo dest url...
   {
    completion(.failure(.noURL(object: self, entity: .photo, operation: .move)))
    return
   }
   
   FileManager.moveItemOnDisk(from: photoSourceURL, to: photoDestURL)
   {result in
    switch result
    {
     case .success:
      guard (self.isDeleted == false && self.ID != nil && self.url != nil) else
      {
       print ("<<< PHOTO MOVE SUCCESS WARNING >>> PHOTO IS INVALID AFTER MOVE!")
       break
      }
      
      guard (destSnippet.isDeleted == false && destSnippet.id != nil && destSnippet.url != nil) else
      {
       print ("<<< PHOTO MOVE SUCCESS WARNING >>> PHOTO DESTINATION FOLDER IS INVALID AFTER MOVE!")
       break
      }
      
      completion(.success(moveNotify))
     
     case .failure(let error):
      completion(.failure(.dataFileMoveFailure(to: photoDestURL,
                                               object: self,
                                               entity: .photo,
                                               operation: .folder,
                                               description: error.localizedDescription)))
     
    }//switch result...
   }//FileManager.moveItemOnDisk.
  }//{persisted in
 }//final func move(to destSnippet...
//**************************************************************************************************************
 
 
 
 
//****************************** MOVE INSIDE FOLDER (.folderedPhotoDidMove)  ***********************************
 final func moveInsideFolder(to destPosition: PhotoItemPosition,
                             with completion: @escaping (Result<Notification, ContextError>) -> () )
//**************************************************************************************************************
 /* Moves foldered photo async inside its own folder */
 {
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photo, operation: .moveInside)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photo, operation: .moveInside)))
   return
  }
  
  context.performChanges(block:  //make changes in context async...
  {
   self.shiftFolderedLeft()
   self.photoItemPosition = destPosition
   self.shiftFolderedRight()
  })
  {result in
   guard case .success = result else { return }
  
   //prepare <.folderedPhotoDidMove> notfication to be posted to subscribers:
   //PhotoFolderCell .moveInsideFolder(after notification: Notification)...
   //ZoomView        .moveInsideFolder(after notification: Notification)...
   
   let userInfo: [PhotoItemMovedKey: Any] = [ .position : destPosition ]
   completion(.success(Notification(name: .folderedPhotoDidMove, object: self, userInfo: userInfo)))
  }
 }//final func moveInsideFolder...
 
 
 
//************************************** MERGE (.photoItemDidMerge) ********************************************
 final func merge(with destPhoto: Photo,
                  with completion: @escaping (Result<Notification, ContextError>) -> () )
//**************************************************************************************************************
 /* Merges async self with destPhoto in one PhotoFolder MO creating one in the current MOC. */
 {
  
  guard self !== destPhoto else { return } //prevent merging with itself!!!
  
  guard self.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: self, entity: .photo, operation: .mergeWith)))
   return
  }
  
  guard destPhoto.isDeleted == false else
  {
   completion(.failure(.isDeleted(object: destPhoto, entity: .destPhoto, operation: .mergeWith)))
   return
  }
  
  guard destPhoto.managedObjectContext != nil  else
  {
   completion(.failure(.noContext(object: destPhoto, entity: .destPhoto, operation: .mergeWith)))
   return
  }
  
  guard let context = self.managedObjectContext else
  {
   completion(.failure(.noContext(object: self, entity: .photo, operation: .mergeWith)))
   return
  }
 
 
  let newFolderID = UUID()
  var newFolder: PhotoFolder?
  
  context.performChanges(block:  //make changes in context async.
  {
   newFolder = PhotoFolder(context: context)
   newFolder?.id = newFolderID
   newFolder?.recordName = newFolderID.uuidString
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
  {result in
   guard case .success = result else { return }
   
   guard let newFolderURL = newFolder!.url else
   {
    completion(.failure(.noURL(object: newFolder!, entity: .photo, operation: .mergeWith)))
    return
   }
   
   FileManager.createDirectoryOnDisk(at: newFolderURL) { result in
    switch result
    {
     case .success:
      /* In some particular cases for instance we drag multiple photos into <.allFolders> section
       (Photo Snippet current group type is set to <.typeGroups>) we have to merge photos into new folder with first photo dragged in this set of draggable items and this first photo (destPhoto here) dragged item may be foldered in some other folder, so we select context method (folder/refolder) based on this fact for destPhoto as well as the case with self (photo) below here...  */
      (destPhoto.folder == nil ? destPhoto.folder : destPhoto.refolder)(newFolder!, .zero) { result in
       switch result
       {
        case .success(let notification):
         NotificationCenter.default.post(notification)
         (self.folder == nil ? self.folder : self.refolder)(newFolder!, .zero)
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
                                                   entity: .photo,
                                                   operation: .mergeWith,
                                                   description: error.localizedDescription)))
    }//switch result...
   }//FileManager.createDirectoryOnDisk...
  }//{persisted in...
 }//final func merge (async)
//**************************************************************************************************************
 
 
} //Photo Managed Object extension...
//**************************************************************************************************************
