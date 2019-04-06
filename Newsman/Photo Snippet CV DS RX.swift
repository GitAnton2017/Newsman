//
//  Photo Snippet CV DS Reactive Extension.swift
//  Newsman
//
//  Created by Anton2016 on 27/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData


extension PhotoSnippetViewController: PhotoManagedObjectsContextChangeObservable
 
{
 
 func insertPhotoItem(with hostedManagedObject: NSManagedObject)
 {
  
 }
 
 func moveToFolder(after notification: Notification)
 {
  guard notification.name == .photoItemDidFolder else { return }
  guard let photoItem = notification.object as? PhotoItem else { return }
  guard let sourceIndexPath = photoItemIndexPath(photoItem: photoItem) else { return }
  photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
  photoCollectionView.deleteItems(at: [sourceIndexPath])
 }
 
 func moveFromFolder(after notification: Notification)
 {
  guard notification.name == .photoItemDidUnfolder else { return }
  guard let photoItem = notification.object as? PhotoItem else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let position = userInfo[.position] as? PhotoItemPosition else { return }
  insertItem(photoItem: photoItem, into: position)
  
 }
 
 func mergeIntoFolder(after notification: Notification)
 {
  guard notification.name == .photoItemDidMerge else { return }
  guard let photoItem = notification.object as? PhotoItem else { return }
  guard let sourceIndexPath = photoItemIndexPath(photoItem: photoItem) else { return }
  photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
  photoCollectionView.deleteItems(at: [sourceIndexPath])
 }
 
 
 func cellSection(with position: PhotoItemPosition) -> Int
 {
  guard let sectionName = position.sectionName else { return 0 }
  guard let titles = self.sectionTitles else { return 0 }
  return titles.index(of: sectionName) ?? 0
 }
 
 func cellIndexPath(with position: PhotoItemPosition) -> IndexPath
 {
  return IndexPath(row: Int(position.row), section: cellSection(with: position))
 }
 
 func insertItem(photoItem: PhotoItemProtocol, into position: PhotoItemPosition)
 {
  let destinationIndexPath = cellIndexPath(with: position)
  let sectionCount = photoItems2D[destinationIndexPath.section].count
  let maxSectionIndexPath = IndexPath(row: sectionCount, section: destinationIndexPath.section)
  let indexPath = min(destinationIndexPath, maxSectionIndexPath)
  photoItems2D[destinationIndexPath.section].insert(photoItem, at: indexPath.row)
  photoCollectionView.insertItems(at: [indexPath])
  
 }
 
 func moveItem(photoItem: PhotoItemProtocol, to position: PhotoItemPosition)
 {
  guard let sourceIndexPath = photoItemIndexPath(photoItem: photoItem) else { return }
  photoItems2D[sourceIndexPath.section].remove(at: sourceIndexPath.row)
  photoCollectionView.deleteItems(at: [sourceIndexPath])
  insertItem(photoItem: photoItem, into: position)
 }
 
 func moveItem(after notification: Notification)
 {
  guard notification.name == .photoItemDidMove else { return }
  guard let photoItem = notification.object as? PhotoItem else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  
  switch (userInfo[.destSnippet], userInfo[.position])
  {
   case let (_?,  position as PhotoItemPosition): insertItem(photoItem: photoItem, into: position)
   case let (nil, position as PhotoItemPosition): moveItem  (photoItem: photoItem, to:   position)
   default: break
  }
 }
 
 
 
 func cellWithHosted(object: NSManagedObject) -> PhotoSnippetCellProtocol?
 {
  return photoItems2D.joined().first{$0.hostedManagedObject === object}?.hostingCollectionViewCell
 }
 

 func cellSection(with photo: Photo) -> Int
 {
  guard let priority = photo.priorityFlag else { return 0 }
  guard let titles = self.sectionTitles else { return 0 }
  return titles.index(of: priority) ?? 0
 }
 
 func photoItemIndexPath(with hostedManagedObject: NSManagedObject) -> IndexPath?
 {
  return photoItems2D.enumerated().flatMap
  {s in
    s.1.enumerated().map{(indexPath: IndexPath(row: $0.0, section: s.0), element: $0.1)}
   }.first{ $0.1.hostedManagedObject === hostedManagedObject }?.indexPath
 }
 
 

 func cellIndexPath(with photo: Photo) -> IndexPath
 {
  let newRow = Int(photo.position)
  let newSection = cellSection(with: photo)
  return IndexPath(row: newRow, section: newSection)
 }
 
 
 func updateItem(with folder: PhotoFolder)
 {
  let pairs = folder.changedValuesForCurrentEvent()
  guard !pairs.isEmpty else { return }
  guard let cell = cellWithHosted(object: folder) else { return }
  guard cell.hostedItem?.hostedManagedObject === folder else { return }
  
  pairs.forEach
  {pair in
   switch pair.key
   {
    case #keyPath(PhotoFolder.isSelected):      cell.isPhotoItemSelected = folder.isSelected
    case #keyPath(PhotoFolder.isDragAnimating): cell.isDragAnimating     = folder.isDragAnimating
    default: break
   }
  }
 }
 
 func updateItem(with photo: Photo)
 {
  let pairs = photo.changedValuesForCurrentEvent()
  guard !pairs.isEmpty else { return }
  guard let cell = cellWithHosted(object: photo) else { return }
  guard cell.hostedItem?.hostedManagedObject === photo else { return }
  
  pairs.forEach
  {pair in
   switch pair.key
   {
    case #keyPath(Photo.isSelected):      cell.isPhotoItemSelected = photo.isSelected
    case #keyPath(Photo.isDragAnimating): cell.isDragAnimating     = photo.isDragAnimating
    default: break
   }
  }
 }
 
 
 
 func updatePhotoItem(with hostedManagedObject: NSManagedObject)
 {
  switch hostedManagedObject
  {
   case let photo  as Photo:        updateItem(with: photo )
   case let folder as PhotoFolder:  updateItem(with: folder)
   default: break
  }
  
  
 }
 

 
 func updateSectionFooter(for sectionIndex: Int)
 {
  let kind = UICollectionElementKindSectionFooter
  let indexPath = IndexPath(row: 0, section: sectionIndex)
  let itemsCount = photoItems2D[sectionIndex].count
 
  guard let footer = photoCollectionView.supplementaryView(forElementKind: kind, at: indexPath) as? PhotoSectionFooter else { return }
  
  footer.footerLabel.text = NSLocalizedString("Total photos in group", comment: "Total photos in group") + ": \(itemsCount)"
  
 }

 func deletePhotoItem(with hostedManagedObject: NSManagedObject)
 {
  guard let indexPath = photoItemIndexPath(with: hostedManagedObject) else { return }
  
  if ( photoItems2D[indexPath.section].count == 1 )
  {
   photoItems2D.remove(at: indexPath.section)
   photoCollectionView.deleteSections(IndexSet(integer: indexPath.section))
  }
  else
  {
   
   photoItems2D[indexPath.section].remove(at: indexPath.row)
   photoCollectionView.deleteItems(at: [indexPath])
   updateSectionFooter(for: indexPath.section)
  }
  
 }
 
 
 
}
