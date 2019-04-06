//
//  Zoom View CV DS RX.swift
//  Newsman
//
//  Created by Anton2016 on 06/04/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension ZoomView: PhotoManagedObjectsContextChangeObservable
{
 func cellWithPhoto(photo: Photo) -> PhotoSnippetCellProtocol?
 {
  return photoItems?.first{ $0.photo === photo }?.hostingZoomedCollectionViewCell
 }
 
 func updatePhotoItem(with hostedMangedObject: NSManagedObject)
 {
  guard let photo = hostedMangedObject as? Photo else { return }
  let pairs = photo.changedValuesForCurrentEvent()
  guard !pairs.isEmpty else { return }
  guard let cell = cellWithPhoto(photo: photo) as? ZoomViewCollectionViewCell else { return }
  guard cell.hostedItem?.hostedManagedObject === photo else { return }
  
  pairs.forEach
  {pair in
   switch pair.key
   {
    case #keyPath(Photo.isSelected):      cell.isPhotoItemSelected = photo.isSelected
    case #keyPath(Photo.isDragAnimating): cell.isDragAnimating = photo.isDragAnimating
    default: break
   }
  }
 }
 
 func insertPhotoItem(with hostedMangedObject: NSManagedObject)
 {
  
 }
 
 func deletePhotoItem(with hostedMangedObject: NSManagedObject)
 {
  
 }
 
 
 func moveItem(after notification: Notification)
 {
  
 }
 
 
 func moveBetweenFolders(after notification: Notification)
 {
  
 }
 
 
 
 
}

