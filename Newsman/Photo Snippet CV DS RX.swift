//
//  Photo Snippet CV DS Reactive Extension.swift
//  Newsman
//
//  Created by Anton2016 on 27/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData
import GameplayKit


extension PhotoSnippetViewController
{

 // <<<<< ---------- FOLDER (.photoItemDidFolder) ----------------- >>>>>
 func moveToFolder(after notification: Notification)
 {
  //find photoItem boxing photo MO and delete it from photoItems2D and corresponding CV cell!
  guard notification.name == .photoItemDidFolder else { return }
  guard let photo = notification.object as? Photo else { return }
  deletePhotoItem(with: photo)
  
 }//func moveToFolder(after notification: Notification)...

 
 // <<<<< ------ UNFOLDER (.photoItemDidUnfolder) -------- >>>>>
 func moveFromFolder(after notification: Notification)
 {
  guard notification.name == .photoItemDidUnfolder else { return }
  guard let photo = notification.object as? Photo else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let position = userInfo[.position] as? PhotoItemPosition else { return }
  
  let photoItem = PhotoItem(photo: photo)
  
  insertPhotoItem(photoItem: photoItem, into: position, with: BatchAnimationOptions.withSmallJump(0.25))
  {[weak self] in
   self?.dragAndDropDelegate?.ddDelegateSubject.onNext(.final)
  }
 }//func moveFromFolder(after notification: Notification)...
 
 
 
 func unfolderEntireFolder(after notification: Notification)
 {
  guard notification.name == .folderItemDidUnfolder else { return }
  guard let photos = notification.object as? [Photo] else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let position = userInfo[.position] as? PhotoItemPosition else { return }
  
  let photoItems = photos.sorted{$0.rowPosition < $1.rowPosition}.map{PhotoItem(photo: $0)}
  insertPhotoItems(photoItems: photoItems, into: position, with: BatchAnimationOptions.withSmallJump(0.25))
  {[weak self] in
   self?.dragAndDropDelegate?.ddDelegateSubject.onNext(.final)
  }
 }//func unfolderEntireFolder(after notification: Notification)...
 
 
 
 func folderPhotoSnippet(after notification: Notification)
 {
  guard notification.name == .snippetItemDidFolder else { return }
  guard let photos = notification.object as? [Photo] else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let selfFolder = userInfo[.isSelfFolderedSnippet] as? Bool, selfFolder else { return }
  
  photos.forEach{ deletePhotoItem(with: $0) }
  
 }//func folderPhotoSnippet(after notification: Notification)...
 
 
 
 func mergeIntoFolder(after notification: Notification)
 {
  guard notification.name == .photoItemDidMerge else { return }
  //????....
 }//func mergeIntoFolder(after notification: Notification)...
 

 
 func updateItem(with photo: Photo)
 {
  let pairs = photo.changedValuesForCurrentEvent()
  guard !pairs.isEmpty else { return }
  guard let cell = cellWithHosted(object: photo) else { return }
  guard cell.hostedItem?.hostedManagedObject.objectID == photo.objectID else { return }
  
  pairs.forEach
  {pair in
   switch pair.key
   {
    case Photo.kp.isSelected:
     //print("CELL SELECTION STATE [\(cell.debugDescription)] IS SET TO [\(photo.isSelected)] ")
     allPhotosSelected = photoSnippet.allPhotosSelected
     cell.isPhotoItemSelected = photo.isSelected
    
    case Photo.kp.isDragAnimating:
    // print("CELL DRAG ANIMATION STATE [\(cell.debugDescription)] IS SET TO [\(photo.isDragAnimating)] ")
    cell.isDragAnimating = photo.isDragAnimating
    case Photo.kp.positions          :  cell.refreshRowPositionMarker()
    case Photo.kp.isArrowMenuShowing
     where photo.isArrowMenuShowing  : cell.showArrowMenu(); dismissArrowMenu(for: photo)
    
    case Photo.kp.isArrowMenuShowing
     where !photo.isArrowMenuShowing : cell.dismissArrowMenu()
     
    default: break
   }
  }
 }//func updateItem(with photo: Photo)...
 
 func dismissArrowMenu(for hostedObject: PhotoItemManagedObjectProtocol)
 {
  hostedObject.managedObjectContext?.perform //NO SAVE CONTEXT!
  {
   if let showingObject = (hostedObject.otherAllUnfoldered.first{$0.isArrowMenuShowing})
   {
    showingObject.isArrowMenuShowing = false
   }
   
   if let folder = hostedObject as? PhotoFolder,
      let showingFoldered = (folder.folderedPhotos.first{$0.isArrowMenuShowing})
   {
    showingFoldered.isArrowMenuShowing = false
   }
   
  } as Void?
  
 }
 
 func updateItem(with folder: PhotoFolder)
 {
  let pairs = folder.changedValuesForCurrentEvent()
  guard !pairs.isEmpty else { return }
  guard let cell = cellWithHosted(object: folder) else { return }
  guard cell.hostedItem?.hostedManagedObject.objectID == folder.objectID else { return }
  
  pairs.forEach
  {pair in
   switch pair.key
   {
    case PhotoFolder.kp.isSelected:
      cell.isPhotoItemSelected = folder.isSelected
      allPhotosSelected = photoSnippet.allPhotosSelected
     
    case PhotoFolder.kp.isDragAnimating    : cell.isDragAnimating = folder.isDragAnimating
    case PhotoFolder.kp.positions          : cell.refreshRowPositionMarker()
    case PhotoFolder.kp.isArrowMenuShowing where folder.isArrowMenuShowing: cell.showArrowMenu()
     dismissArrowMenu(for: folder)
    
    case PhotoFolder.kp.isArrowMenuShowing where !folder.isArrowMenuShowing : cell.dismissArrowMenu()
   
    default: break
   }
  }
  
 }//func updateItem(with folder: PhotoFolder)...
 
 
 func refreshFlagMakers(for hostedManagedObjects: [NSManagedObject])
 {
  hostedManagedObjects.compactMap{ cellWithHosted(object: $0) }.forEach
  {
   $0.refreshFlagMarker()
  }
 }//func refreshFlagMakers...
 
 
 
 func updatePhotoItemsFlag(with hostedManagedObjects: [NSManagedObject])
 {
  print (#function)
  
  defer {
  
   let dragMovedObjects = hostedManagedObjects
    .compactMap{$0 as? PhotoItemManagedObjectProtocol}.filter{$0.isDragMoved}
   
   //refreshFlagMakers(for: dragMovedObjects)
   
   dragMovedObjects.forEach{ $0.isDragMoved = false }
   
  }
  
  
  guard photoSnippet?.photoGroupType == .makeGroups else
  {
   //refreshFlagMakers(for: hostedManagedObjects)
   allPhotosSelected = false
   return
  }//guard photoSnippet?.photoGroupType...
  
  if GKRandomDistribution(forDieWithSideCount: 2).nextBool()
  {
   chainedCellsMoves(with: hostedManagedObjects) { self.allPhotosSelected = false }
  }
  else
  {
   batchedCellsMoves(with: hostedManagedObjects)
   {
    //self.refreshFlagMakers(for: hostedManagedObjects)
    self.allPhotosSelected = false
   }
  }
  
 }//func updatePhotoItemsFlag(...
 

 
 func updatePhotoItem(with hostedManagedObject: NSManagedObject)
 {
  switch hostedManagedObject
  {
   case let photo  as Photo                                        :  updateItem(with: photo)
   case let folder as PhotoFolder                                  :  updateItem(with: folder)
   case let snippet as PhotoSnippet
    where snippet.objectID == photoSnippet.objectID :  updateSnippet()
   default: break
  }
 }//func updatePhotoItem...

 
}//extension PhotoSnippetViewController...
