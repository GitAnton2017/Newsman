//
//  Zoom View CV DS Helpers.swift
//  Newsman
//
//  Created by Anton2016 on 25/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension ZoomView
{

 func targetIndexPath(of photo: Photo) -> IndexPath
 {
  let sortPred = GroupPhotos.manually.sortPredicate!
  let asc = true
  var sa = photoItems ?? []
  let photoItem = PhotoItem(photo: photo)
  sa += (sa.contains{ $0.photo.objectID == photo.objectID } ? [] : [photoItem])
  let rowIndex = sa.sorted{sortPred($0, $1, asc)}.firstIndex { $0.photo.objectID == photo.objectID }
  return IndexPath(row: rowIndex!, section: 0)
 }
 
 func photoItemPosition(for destinationIndexPath: IndexPath) -> PhotoItemPosition
 {
  let row = destinationIndexPath.row
  return PhotoItemPosition(sectionName: nil, row: row, for: nil)
 }//func photoItemPosition(for...
 
 
 func cellWithPhoto(photo: Photo) -> PhotoSnippetCellProtocol?
 {
  photoItems?.first{ $0.photo.objectID == photo.objectID }?.hostingZoomedCollectionViewCell
 }//func cellWithPhoto(photo: Photo)...
 
 
 
 func photoItemIndexPath(with photo: Photo) -> IndexPath?
 {
  photoItems?.firstIndex{$0.hostedManagedObject.objectID == photo.objectID}.map{IndexPath(row: $0, section: 0)}
 }//func photoItemIndexPath(with photo: Photo)...
 
 
 
 func photoItemIndexPath(photoItem: PhotoItem) -> IndexPath?
 {
  guard let path = photoItems?.enumerated().first(where: {$0.element.id == photoItem.id}) else {return nil}
  return IndexPath(row: path.offset, section: 0)
 }//func photoItemIndexPath(photoItem: PhotoItem)...
 
 
 func repositionItemsIfNeeded(after delay: Int = 1, with completion: (() -> ())? = nil)
 {
  guard let photoCollectionView = self.presentSubview as? UICollectionView else { return }
  let sortPred = GroupPhotos.manually.sortPredicate!
  let asc = true
 
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(delay))
  {[weak self] in
   photoCollectionView.performAnimatedBatchUpdates(BatchAnimationOptions.withSmallJump(1),
   {[weak self] in
    guard let photoItems = self?.photoItems else { return }
    let s_cnt = photoItems.count
    let sorted = photoItems.enumerated().sorted{sortPred($0.1, $1.1, asc)}
    self?.photoItems?.sort{sortPred($0, $1, asc)}
    
    sorted.map
    {
     (from: IndexPath(row: $0.0                                                 , section: 0),
      to:   IndexPath(row: asc ? $0.1.rowPosition : s_cnt - 1 - $0.1.rowPosition, section: 0))
    }.forEach { photoCollectionView.moveItem(at: $0.from, to: $0.to) }
    
   })
   {_ in
    completion?()
   }
  }
 }//func repositionItemsIfNeeded(after delay: Int = 1)...
 
 
}//func photoItemIndexPath(photoItem: PhotoItem)...
