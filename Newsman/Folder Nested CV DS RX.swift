//
//  Folder Nested CV DS Reactive Extension.swift
//  Newsman
//
//  Created by Anton2016 on 03/04/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension PhotoFolderCell
{
 
 
 // <<<<< -------- FOLDER (.photoItemDidFolder) ----------- >>>>>
 func moveToFolder(after notification: Notification)
 {
  guard notification.name == .photoItemDidFolder else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let position = userInfo[.position] as? PhotoItemPosition else { return }
  guard let destFolder = userInfo[.destFolder] as? PhotoFolder else { return }
  guard destFolder.objectID == hostedItem?.hostedManagedObject.objectID else { return }
  
  switch notification.object
  {
   case let photo as Photo: insertSinglePhoto(photo: photo, at: position.row)
   case let photos as [Photo]: insertPhotos(photos: photos, at: position.row)
   default: break
  }
  
 }//func moveToFolder(after notification: Notification)...
 
 
 
 // <<<<< ------ FOLDER ENTIRE PHOTO SNIPPET (.snippetItemDidFolder) ------- >>>>>
 func folderPhotoSnippet(after notification: Notification)
 {
  guard notification.name == .snippetItemDidFolder else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let position = userInfo[.position] as? PhotoItemPosition else { return }
  guard let destFolder = userInfo[.destFolder] as? PhotoFolder else { return }
  guard destFolder.objectID == hostedItem?.hostedManagedObject.objectID else { return }
  
  switch notification.object
  {
   case let photos as [Photo]: insertPhotos(photos: photos, at: position.row)
   default: break
  }
  
 }//func folderPhotoSnippet(after notification: Notification)...
 
 
 // <<<<< -----------REFOLDER (.photoItemDidREFolder) ------------ >>>>>
 func moveBetweenFolders(after notification: Notification)
 {
  guard notification.name == .photoItemDidRefolder else { return }
  guard let photo = notification.object as? Photo else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let destFolder = userInfo[.destFolder] as? PhotoFolder else { return }
  guard let sourceFolder = userInfo[.sourceFolder] as? PhotoFolder else { return }
  guard sourceFolder !== destFolder else { return }
  
  switch hostedItem?.hostedManagedObject
  {
   case sourceFolder: deletePhotoItem(with: photo)
   case destFolder:
    guard let position = userInfo[.position] as? PhotoItemPosition else { break }
    insertSinglePhoto(photo: photo, at: position.row)
   default: break
  }

  
 }//func moveBetweenFolders....
 
 
 // <<<<< ------ UNFOLDER (.photoItemDidUnfolder) -------- >>>>>
 func moveFromFolder(after notification: Notification)
 {
  guard notification.name == .photoItemDidUnfolder else { return }
  guard let photo = notification.object as? Photo else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let sourceFolder = userInfo[.sourceFolder] as? PhotoFolder else { return }
  guard hostedItem?.hostedManagedObject.objectID == sourceFolder.objectID else { return }
  
  deletePhotoItem(with: photo)
  
 }//func moveFromFolder(after notification...
 
 
 func moveItem(after notification: Notification)
 {
  guard notification.name == .photoItemDidMove else { return }
  guard let photos = notification.object as? [Photo] else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let destSnippet = userInfo[.destSnippet] as? PhotoSnippet else { return }
  guard destSnippet.objectID == photoSnippet?.objectID else { return }
  guard let destFolder = userInfo[.destFolder] as? PhotoFolder else { return }
  guard hostedItem?.hostedManagedObject.objectID == destFolder.objectID else { return }
  guard let position = userInfo[.position] as? PhotoItemPosition else { return }
  
  insertPhotos(photos: photos, at: position.row)
  
 }//func moveItem(after notification: Notification)
 
 
 func updatePhotoItem(with hostedMangedObject: NSManagedObject)
 {
  guard let photo = hostedMangedObject as? Photo else { return }
  let pairs = photo.changedValuesForCurrentEvent()
  guard !pairs.isEmpty else { return }
  guard let cell = cellWithPhoto(photo: photo) as? PhotoFolderCollectionViewCell else { return }
  guard cell.hostedItem?.hostedManagedObject.objectID == photo.objectID else { return }
  
  pairs.forEach
  {pair in
   switch pair.key
   {
    case Photo.kp.isSelected:
     photoSnippetVC?.allPhotosSelected = photoSnippet?.allPhotosSelected ?? false
     cell.isPhotoItemSelected = photo.isSelected
    
    case Photo.kp.isDragAnimating:      cell.isDragAnimating = photo.isDragAnimating
    case Photo.kp.positions:            cell.refreshRowPositionMarker()
    //case Photo.kp.priorityFlag:         cell.refreshFlagMarker()
    case Photo.kp.isArrowMenuShowing where photo.isArrowMenuShowing:
      cell.showArrowMenu()
      dismissArrowMenu(for: photo)
    
    case Photo.kp.isArrowMenuShowing where !photo.isArrowMenuShowing: cell.dismissArrowMenu()
     
    default: break
     
     
   }
  }
 }//func updatePhotoItem(with hostedMangedObject....

 func dismissArrowMenu(for hostedPhoto: Photo)
 {
  hostedPhoto.managedObjectContext?.perform //NO SAVE CONTEXT!
  {
   if let showingPhoto = (hostedPhoto.otherFolderedPhotos.first{ $0.isArrowMenuShowing })
   {
    showingPhoto.isArrowMenuShowing = false
   }
   
   if ( hostedPhoto.folder?.isArrowMenuShowing ?? false )
   {
    hostedPhoto.folder?.isArrowMenuShowing = false
   }
   
  } as Void?
 }//func dismissArrowMenu(for hostedPhoto: Photo)...
 
}//extension PhotoFolderCell...

