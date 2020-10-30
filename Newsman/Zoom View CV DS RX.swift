//
//  Zoom View CV DS RX.swift
//  Newsman
//
//  Created by Anton2016 on 06/04/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension ZoomView
{
 
 
 // <<<<< FOLDER (.photoItemDidFolder) >>>>>
 func moveToFolder(after notification: Notification)
 {
  guard notification.name == .photoItemDidFolder else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let position = userInfo[.position] as? PhotoItemPosition else { return }
  guard let destFolder = userInfo[.destFolder] as? PhotoFolder else { return }
  
  switch (notification.object, presentSubview, zoomedPhotoItem?.hostedManagedObject)
  {
   case (let photo as Photo, let cv as UICollectionView, destFolder):
    insertSinglePhoto(photo: photo, into: cv, at: position.row)
   
   case (let folderPhotos as [Photo], let cv as UICollectionView, destFolder):
    insertPhotos(photos: folderPhotos, into: cv, at: position.row)
    
   case (let photo as Photo, is UIImageView, let zoomed as Photo)
    where photo.objectID == zoomed.objectID: removeZoomView()
   
   case (let folderPhotos as [Photo], is UICollectionView, is PhotoFolder)
    where Set(folderPhotos) == Set(photoItems.map{$0.photo}): removeZoomView()
   
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
  
  switch (notification.object, presentSubview, zoomedPhotoItem?.hostedManagedObject)
  {
   case (let allSnippetPhotos as [Photo], let cv as UICollectionView, destFolder):
    insertPhotos(photos: allSnippetPhotos, into: cv, at: position.row)
    {[weak self] in
     self?.ddPublish.onNext(())
    }
   
   default: removeZoomView()
  }
  
 }//func folderPhotoSnippet(after notification: Notification)...
 
 
 
 func moveBetweenFolders(after notification: Notification)
 {
  guard notification.name == .photoItemDidRefolder else { return }
  guard let zoomViewCV = presentSubview as? UICollectionView else { return }
  guard let photo = notification.object as? Photo else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let position = userInfo[.position] as? PhotoItemPosition else { return }
  guard let destFolder = userInfo[.destFolder] as? PhotoFolder else { return }
  guard let sourceFolder = userInfo[.sourceFolder] as? PhotoFolder else { return }
  guard sourceFolder !== destFolder else { return }
  
  switch zoomedPhotoItem?.hostedManagedObject
  {
   case sourceFolder: deleteSinglePhoto(photo: photo, from: zoomViewCV)
   case destFolder:   insertSinglePhoto(photo: photo, into: zoomViewCV, at: position.row)
   default: break
  }
  
 }//func moveBetweenFolders....
 
 
 // <<<<< ------ UNFOLDER (.photoItemDidUnfolder) -------- >>>>>
 func moveFromFolder(after notification: Notification)
 {
  guard notification.name == .photoItemDidUnfolder else { return }
  guard let zoomViewCV = presentSubview as? UICollectionView else { return }
  guard let photo = notification.object as? Photo else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let sourceFolder = userInfo[.sourceFolder] as? PhotoFolder else { return }
  guard zoomedPhotoItem?.hostedManagedObject.objectID == sourceFolder.objectID else { return }
  
  deleteSinglePhoto(photo: photo, from: zoomViewCV)
 
 }//func moveFromFolder(after notification...
 
 
 
 func updatePhotoItem(with hostedMangedObject: NSManagedObject)
 {
  guard let photo = hostedMangedObject as? Photo else { return }
  let pairs = photo.changedValuesForCurrentEvent()
  guard !pairs.isEmpty else { return }
  guard let cell = cellWithPhoto(photo: photo) as? ZoomViewCollectionViewCell else { return }
  guard cell.hostedItem?.hostedManagedObject.objectID == photo.objectID else { return }
  
  pairs.forEach
  {pair in
   switch pair.key
   {
    case Photo.kp.isSelected:
     photoSnippetVC.allPhotosSelected = photoSnippet.allPhotosSelected
     cell.isPhotoItemSelected = photo.isSelected
    case Photo.kp.isDragAnimating:      cell.isDragAnimating = photo.isDragAnimating
    case Photo.kp.positions :           cell.refreshRowPositionMarker()
    //case Photo.kp.priorityFlag:         cell.refreshFlagMarker()
    case Photo.kp.isArrowMenuShowing where photo.isArrowMenuShowing : cell.showArrowMenu()
     dismissArrowMenu(for: photo)
    case Photo.kp.isArrowMenuShowing where !photo.isArrowMenuShowing : cell.dismissArrowMenu()
    default: break
   }
  }
 }
 
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

 }//func dismissArrowMenu(for hostedPhoto: Photo)
 
 
 
 

}

