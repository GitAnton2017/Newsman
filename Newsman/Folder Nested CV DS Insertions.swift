//
//  Folder Nested CV DS Insertions.swift
//  Newsman
//
//  Created by Anton2016 on 24/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension PhotoFolderCell
{

 func insertPhotoItem(with hostedManagedObject: NSManagedObject)
 {
  //to do later...
 }
 
 func insertPhotos(photos: [Photo], at position: Int)
 {
  guard photoItems != nil else { return }
  
  let items = photos
   .filter{ photo in !photoItems.contains{ $0.photo.objectID == photo.objectID } }
   .sorted{ $0.rowPosition < $1.rowPosition }
   .map{ PhotoItem(photo: $0) }
  
  if items.isEmpty { return }
  
  photoCollectionView.performBatchUpdates({
   photoItems.insert(contentsOf: items, at: position)
   let indexPath = IndexPath(row: position, section: 0)
   let indexPaths = Array<IndexPath>(repeating: indexPath, count: items.count)
   photoCollectionView.insertItems(at: indexPaths)
  })

 }
 
 func insertSinglePhoto(photo: Photo, at position: Int)
 {
  guard photoItems != nil else { return }
  
  if (photoItems.contains{ $0.photo.objectID == photo.objectID }) { return }
  
  photoCollectionView.performBatchUpdates({
   let item = PhotoItem(photo: photo)
   photoItems.insert(item, at: position)
   let indexPath = IndexPath(row: position, section: 0)
   photoCollectionView.insertItems(at: [indexPath])
  })
 }
 
}
