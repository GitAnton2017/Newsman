//
//  Photo Snippet CV DS Deletions.swift
//  Newsman
//
//  Created by Anton2016 on 04/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension PhotoSnippetViewController
{

 func deleteEmptySectionIfNeeded(at sectionIndex: Int, with completion: ( () -> () )? = nil)
 {
  guard sectionIndex < photoItems2D.count else { return }
  guard self.photoItems2D[sectionIndex].isEmpty else { completion?(); return }

  photoCollectionView.performAnimatedBatchUpdates(BatchAnimationOptions.withAverageJump(0.5),
  {
   self.photoItems2D.remove(at: sectionIndex)
   self.sectionTitles?.remove(at: sectionIndex)
   self.photoCollectionView.deleteSections(IndexSet(integer: sectionIndex))
  })
  { _ in completion?() }
  

 }//func deleteSection(at index: Int...
 
 
 func deleteEmptySections(at indexes: [Int], with completion: ( () -> () )? = nil)
 {
  UIView.animate(withDuration: 0.25, delay: 0,
                 usingSpringWithDamping: 0.9,
                 initialSpringVelocity: 15,
                 options: [.curveEaseInOut],
                 animations:
   {
    self.photoCollectionView.performBatchUpdates(
    {
     let emptySections = indexes.filter{self.photoItems2D[$0].isEmpty }.sorted(by: >)
     emptySections.forEach
     {index in
      self.photoItems2D.remove(at: index)
      self.sectionTitles?.remove(at: index)
     }
     self.photoCollectionView.deleteSections(IndexSet(emptySections))
    })
    {_ in
     completion?()
    }
  })
 }//func deleteEmptySections(at indexes: [Int]...
 

 
 func deleteFolderItem(with folder: PhotoFolder, with completion: ( () -> () )? = nil)
 {
  guard let indexPath = photoItemIndexPath(with: folder) else
  {
   completion?()
   return
  }
  
  guard let folderCell = photoCollectionView.cellForItem(at: indexPath) as? PhotoFolderCell else
  {
   deleteGenericItem(with: folder, with: completion)
   return
  }
  
  
  folderCell.photoCollectionView.performBatchUpdates(
  {
   let deleteIndexPath = folderCell.photoItemsIndexPaths
   folderCell.photoItems.removeAll()
   folderCell.photoCollectionView.deleteItems(at: deleteIndexPath)
  })
  {_ in
   self.deleteGenericItem(with: folder, with: completion)
  }
  
 }//func deleteFolderItem(at indexPath: IndexPath...
 
 
 
 func deleteGenericItem(with object: NSManagedObject, with completion: ( () -> () )? = nil)
 {
  guard let indexPath = photoItemIndexPath(with: object) else
  {
   completion?()
   return
  }
  
  photoItems2D[indexPath.section].remove(at: indexPath.row)
  photoCollectionView.deleteItems(at: [indexPath])
  updateSectionFooter(for: indexPath.section)
  deleteEmptySectionIfNeeded(at: indexPath.section, with: completion)
 }//func deletePhotoItem(at indexPath...
 

 
 func deletePhotoItem(with hostedManagedObject: NSManagedObject)
 {
  
  switch hostedManagedObject
  {
   case let photo as Photo:
    deleteGenericItem(with: photo) { [weak self] in
     self?.dragAndDropDelegate?.ddDelegateSubject.onNext(.final) }
   
   case let folder as PhotoFolder:
    deleteFolderItem(with: folder) { [weak self] in
     self?.dragAndDropDelegate?.ddDelegateSubject.onNext(.final) }
   
   default: break
  }
  
 }//func deletePhotoItem(with hostedManagedObject...
 
}
