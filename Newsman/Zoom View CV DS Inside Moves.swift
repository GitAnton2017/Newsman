//
//  Zoom View CV DS Inside Moves.swift
//  Newsman
//
//  Created by Anton2016 on 15/07/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension ZoomView
{
 // <<<<<  MOVE INSIDE FOLDER (.foldredPhotoDidMove) >>>>>
 func moveInsideFolder(after notification: Notification)
 {
  guard notification.name == .folderedPhotoDidMove else { return }
  guard let photo = notification.object as? Photo else { return }
  movePhotoItem(with: photo)
  ddPublish.onNext(())
 }
 
 
 func movePhotoItem(with photo: Photo)
 {
  guard let oldIndexPath = photoItemIndexPath(with: photo) else { return }
  let newIndexPath = targetIndexPath(of: photo)
  movePhotoItemCell(from: oldIndexPath, to: newIndexPath)
 }//func movePhotoItem(photoItem: PhotoItemProtocol, to position: PhotoItemPosition,...

 
 func movePhotoItemCell(from oldIndexPath: IndexPath, to newIndexPath: IndexPath)
 {
  guard let photoCollectionView = presentSubview as? UICollectionView else { return }
  guard let moved = self.photoItems?.remove(at: oldIndexPath.row) else { return }
  photoItems?.insert(moved, at: newIndexPath.row)
  photoCollectionView.moveItem(at: oldIndexPath, to: newIndexPath)
  
 } //func movePhotoItemCell(from oldIndexPath: IndexPath, to newIndexPath: IndexPath)...
 
}
