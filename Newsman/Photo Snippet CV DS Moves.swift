//
//  Photo Snippet CV DS Moves.swift
//  Newsman
//
//  Created by Anton2016 on 04/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension PhotoSnippetViewController
{
 
 func moveItem(after notification: Notification)
 {
  guard notification.name == .photoItemDidMove else { return } // right notification name?
  guard let moved = notification.object as? PhotoItemManagedObjectProtocol else { return }
  guard let userInfo = notification.userInfo as? [PhotoItemMovedKey: Any] else { return }
  guard let sourceSnippet = userInfo[.sourceSnippet] as? PhotoSnippet else { return }
  guard let position = userInfo[.position] as? PhotoItemPosition else { return }
  guard let photoItem = moved.photoItem else { return } // wrap up moved photo MO into new PhotoItem object
  
  if ( sourceSnippet.objectID == self.photoSnippet.objectID ) // move in the same snippet
  {
   movePhotoItem (photoItem: photoItem, to: position, with: BatchAnimationOptions.withAverageJump(0.25))
   { [ weak self ] in
    
    self?.dragAndDropDelegate?.ddDelegateSubject.onNext(.final)
   }
   // use move method and reposition item inside section [0] if needed after move
  }
  else
  {
   insertPhotoItem (photoItem: photoItem, into: position, with: BatchAnimationOptions.withAverageJump(0.25))
   { [ weak self ] in
    self?.dragAndDropDelegate?.ddDelegateSubject.onNext(.final)
   }
   // use insert into new snippet method and reposition item inside section [0] if needed
  }
  
  
  
 }//func moveItem(after notification: Notification)
 
 
 func movePhotoItem(photoItem: PhotoItemProtocol, to position: PhotoItemPosition)
 {
  let object = photoItem.photoManagedObject
  guard let oldIndexPath = photoItemIndexPath(with: object) else { return }
  
  let section = cellSection(with: position)
  
  let newIndexPath = targetIndexPath(of: photoItem, in: section)
  
  movePhotoItemCell(from: oldIndexPath, to: newIndexPath)
  updateSectionFooter(for: oldIndexPath.section)
  updateSectionFooter(for: newIndexPath.section)
  deleteEmptySectionIfNeeded(at: oldIndexPath.section, with: nil)
  

 }//func movePhotoItem(photoItem: PhotoItemProtocol, to position: PhotoItemPosition,...
 
 func movePhotoItem(photoItem: PhotoItemProtocol, to position: PhotoItemPosition,
                    with batchAnimationOptions: AnimationOptionsRepresentable,
                    with completion: ( () -> () )? = nil)
 {
  let object = photoItem.photoManagedObject
  guard let oldIndexPath = photoItemIndexPath(with: object) else { return }
  let section = cellSection(with: position)
  
  let newIndexPath = targetIndexPath(of: photoItem, in: section)
  
  movePhotoItem(from: oldIndexPath, to: newIndexPath, with: batchAnimationOptions)
  {[weak self] in
    guard let self = self else { return }
    self.updateSectionFooter(for: oldIndexPath.section)
    self.updateSectionFooter(for: newIndexPath.section)
    self.deleteEmptySectionIfNeeded(at: oldIndexPath.section, with: completion)
    
//    guard let cell = self.photoCollectionView.cellForItem(at: newIndexPath) as? PhotoSnippetCellProtocol else { return }
//    self.bringOverlayFolderCellsToFront(self.photoCollectionView, cell: cell, forItemAt: newIndexPath)
  }
 
  
 }//func movePhotoItem(photoItem: PhotoItemProtocol, to position: PhotoItemPosition,...
 
 
 
 
 
 func movePhotoItemCell(from oldIndexPath: IndexPath, to newIndexPath: IndexPath)
 {
  let moved = photoItems2D[oldIndexPath.section].remove(at: oldIndexPath.row)
  photoItems2D[newIndexPath.section].insert(moved, at: newIndexPath.row)
  photoCollectionView.moveItem(at: oldIndexPath, to: newIndexPath)
  
  
  
 } //func movePhotoItemCell(from oldIndexPath: IndexPath, to newIndexPath: IndexPath)...
 
 
 
 func movePhotoItem(from oldIndexPath: IndexPath, to newIndexPath: IndexPath,
                    with batchAnimationOptions: AnimationOptionsRepresentable,
                    with completion: ( () -> () )? = nil)
 {
  guard newIndexPath != oldIndexPath else { return }
 
  photoCollectionView.performAnimatedBatchUpdates(batchAnimationOptions,
  {[weak self] in
   self?.movePhotoItemCell(from: oldIndexPath, to: newIndexPath)
  })
  {_ in completion?() }
 
  
 }//func movePhotoItem(from oldIndexPath: IndexPath,...
 
 
 func movePhotoItem(with object: PhotoItemManagedObjectProtocol,
                    to newSection: Int,
                    with batchAnimationOptions: AnimationOptionsRepresentable,
                    with completion: ( () -> () )? = nil)
 {
  guard let oldIndexPath = photoItemIndexPath(with: object) else { return }
  let newIndexPath = IndexPath(row: object.rowPosition, section: newSection)
 
  movePhotoItem(from: oldIndexPath, to: newIndexPath, with: batchAnimationOptions)
  {[weak self] in
   self?.updateSectionFooter(for: oldIndexPath.section)
   self?.updateSectionFooter(for: newSection)
   self?.deleteEmptySectionIfNeeded(at: oldIndexPath.section, with: completion)
  }
  
 }//func movePhotoItem(with object: PhotoItemManagedObjectProtocol,...
 
 
 
 func movePhotoItems(with objects: [PhotoItemManagedObjectProtocol],
                    to newSection: Int,
                    with batchAnimationOptions: AnimationOptionsRepresentable,
                    with completion: ( () -> () )? = nil)
 {
  
  let fromIndexPaths = objects.compactMap{photoItemIndexPath(with: $0)}.sorted(by: >)
  let fromSections = Array(Set(fromIndexPaths.map{ $0.section }))
  var toIndexPaths = [IndexPath]()
  
  photoCollectionView.performAnimatedBatchUpdates(batchAnimationOptions,
  {[weak self] in
   
   var deleted = [PhotoItemProtocol]()
   
   fromIndexPaths.forEach
   {
    guard let moved = self?.photoItems2D[$0.section].remove(at: $0.row) else { return }
    deleted.append(moved)
   }
   
   deleted.sorted{ $0.rowPosition < $1.rowPosition }.forEach
   {moved in
    let newIndexPath = IndexPath(row: moved.rowPosition, section: newSection)
    toIndexPaths.append(newIndexPath)
    self?.photoItems2D[newSection].insert(moved, at: moved.rowPosition)
   }
   
   zip(fromIndexPaths, toIndexPaths).forEach {
    self?.photoCollectionView.moveItem(at: $0.0, to: $0.1)
   }
   
  })
  { [weak self] _ in
   self?.reloadCellsIfNeeded(at: toIndexPaths)
   {
    self?.deleteEmptySections(at: fromSections)
    {
     self?.updateSectionsFooters(for: fromSections + [newSection])
     completion?()
    }
   }
  }
  
 }//func movePhotoItems(with objects: [PhotoItemManagedObjectProtocol],...
 
 
 func movePhotoItem(with object: PhotoItemManagedObjectProtocol,
                    with batchAnimationOptions: AnimationOptionsRepresentable,
                    with completion: ( () -> () )? = nil)
 {
  insertNewSectionIfNeeded(for: object, with: batchAnimationOptions)
  { [ weak self ] section in
   self?.movePhotoItem(with: object, to: section, with: batchAnimationOptions, with: completion)
  }
 }//func movePhotoItem(with object: PhotoItemManagedObjectProtocol,...
 
 
 
 func chainedCellsMoves(with hostedManagedObjects: [ NSManagedObject ], completion: ( () -> () )? = nil )
 {
  let photoItems = hostedManagedObjects
   .compactMap{ $0 as? PhotoItemManagedObjectProtocol }
   .filter{ $0.isDragMoved == false }
   .sorted { $0.rowPosition < $1.rowPosition }
  
  if photoItems.isEmpty { return }
 
  var count = 0
  let jumpDuration = max(0.01, min(0.25, 1.0 / TimeInterval(photoItems.count)))
  
  func move(_ item: PhotoItemManagedObjectProtocol)
  {
   movePhotoItem(with: item, with: BatchAnimationOptions.withSmallJump(jumpDuration))
   {[ weak self ] in
    //self?.cellWithHosted(object: item)?.refreshFlagMarker()
    count += 1
    if count < photoItems.count { move(photoItems[count]) } else { completion?() }
   }
  }
  
  move(photoItems[0])
  
 }//func chainedCellsMoves(with hostedManagedObjects: [NSManagedObject]...
 
 
 func batchedCellsMoves(with hostedManagedObjects: [NSManagedObject], completion: ( () -> () )? = nil )
 {
  let photoItems = hostedManagedObjects
   .compactMap{ $0 as? PhotoItemManagedObjectProtocol }.filter{ $0.isDragMoved == false }
  
  guard let firstItem = photoItems.first else { return }
  
  insertNewSectionIfNeeded(for: firstItem, with: BatchAnimationOptions.withAverageJump(0.5))
  {[weak self] section in
   self?.movePhotoItems(with: photoItems, to: section,
                        with: BatchAnimationOptions.withAverageJump(0.75),
                        with: completion)
  }
  
 }//func batchedCellsMoves(with hostedManagedObjects: [NSManagedObject]...
 
}//extension PhotoSnippetViewController...
