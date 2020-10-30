//
//  Zoom View CV DS Insertions.swift
//  Newsman
//
//  Created by Anton2016 on 27/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension ZoomView
{
 func insertPhotoItem(with hostedMangedObject: NSManagedObject)
 {
  
 }
 
 
 func insertSinglePhoto(photo: Photo, into collectionView: UICollectionView, at position: Int)
 {
  collectionView.performBatchUpdates({
   let item = PhotoItem(photo: photo)
   photoItems?.insert(item, at: position)
   let indexPath = IndexPath(row: position, section: 0)
   collectionView.insertItems(at: [indexPath])
  })
 }
 
 
 
 func insertPhotos(photos: [Photo], into collectionView: UICollectionView,
                   at position: Int, with completion: ( () -> () )? = nil)
 {
  collectionView.performBatchUpdates(
  {
   let items = photos.sorted{$0.rowPosition < $1.rowPosition}.map{ PhotoItem(photo: $0) }
   self.photoItems?.insert(contentsOf: items, at: position)
   let indexPath = IndexPath(row: position, section: 0)
   let indexPaths = Array<IndexPath>(repeating: indexPath, count: items.count)
   collectionView.insertItems(at: indexPaths)
  })
  {_ in
   completion?()
  }
  
 }
}
