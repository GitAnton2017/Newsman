//
//  Photo Snippet CV DS Insertions.swift
//  Newsman
//
//  Created by Anton2016 on 20/04/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

extension PhotoSnippetViewController
{
 func insertPhotoItem(with hostedManagedObject: NSManagedObject)
 {
  switch hostedManagedObject
  {
   case let folder as PhotoFolder:
    insertMergedFolder(folder: folder, with: BatchAnimationOptions.withSmallJump(0.5))
    {[ weak self ] in
     self?.dragAndDropDelegate?.ddDelegateSubject.onNext(.final)
    }
   default: break
  }
 }//func insertPhotoItem(with hostedManagedObject...
 
 
 
 func insertNewIndexPath(_ newPhotoItem: PhotoItemProtocol, into section: Int) -> IndexPath
 {
  
  let sectioned = photoCollectionView.photoGroupType?.isSectioned ?? false
  let positioned = photoCollectionView.photoGroupType?.isRowPositioned ?? false
  let ascending =  photoSnippet.ascendingPlain
  
  let count = photoItems2D[section].count
  
  if ( photoCollectionView.photoGroupType == .byPriorityFlag )
  {
   return IndexPath(row: ascending ? 0 : count, section: section)
  }
  
  switch (sectioned, positioned, ascending)
  {
   case (true,    _ ,    _  ) : fallthrough
   case (false, true,  true ) : return IndexPath(row: min(newPhotoItem.rowPosition, count) , section: section)
   case (false,   _ ,  false) : return IndexPath(row: 0, section: section)
   case (false, false, true ) : return IndexPath(row: count , section: section)

  }
 }//func insertNewIndexPath(_ newPhotoItem: PhotoItemProtocol...
 

 
 func insertMergedFolder(folder: PhotoFolder,
                         with batchAnimationOptions: AnimationOptionsRepresentable,
                         with completion: (() -> ())? = nil)
 {
  insertNewSectionIfNeeded(for: folder, with: batchAnimationOptions)
  {[ weak self ] _ in
   guard let self = self else { return }
   let section = self.cellSection(with: folder) ?? 0
   let folderItem = PhotoFolderItem(folder: folder)
   let insertIndexPath = self.targetIndexPath(of: folderItem , in: section)
   self.insertPhotoItem(folderItem, at: insertIndexPath, with: batchAnimationOptions)
   completion?()
  }
 }//func insertMergedFolder(folder: ...
 
 
 func insertPhotoItem(photoItem: PhotoItemProtocol,
                      into position: PhotoItemPosition,
                      with batchAnimationOptions: AnimationOptionsRepresentable,
                      with completion: (() -> ())? = nil)
 //insert new photo item into indicated position during drag & drop activities.
 {
  insertNewSectionIfNeeded(for: photoItem.photoManagedObject, with: batchAnimationOptions)
  {[ weak self ] section in
   guard let self = self else { return }
   let indexPath = self.targetIndexPath(of: photoItem, in: section)
   self.insertPhotoItem(photoItem, at: indexPath, with: batchAnimationOptions, with: completion)
  }
 }//func insertPhotoItem(photoItem: PhotoItemProtocol...
 
 
 func insertPhotoItems(photoItems: [PhotoItemProtocol],
                       into position: PhotoItemPosition,
                       with batchAnimationOptions: AnimationOptionsRepresentable,
                       with completion: (() -> ())? = nil)
 //insert new photos item into indicated position during drag & drop activities.
 {
  guard let firstItem = photoItems.first else { return }
  insertNewSectionIfNeeded(for: firstItem.photoManagedObject, with: batchAnimationOptions)
  { [ weak self ] section in
   guard let self = self else { return }
   let indexPath = self.targetIndexPath(of: firstItem, in: section)
   self.photoCollectionView.performAnimatedBatchUpdates(batchAnimationOptions,
   {
    self.photoItems2D[section].insert(contentsOf: photoItems, at: indexPath.row)
    let ips = Array(repeating: indexPath, count: photoItems.count)
    self.photoCollectionView.insertItems(at: ips)
   })
   { [ weak self ] _ in self?.updateSectionFooter(for: indexPath.section)
    completion?()
   }
  }
 }//func insertPhotoItem(photoItem: PhotoItemProtocol...
 
 
 
 func insertPhotoItem(_ newPhotoItem: PhotoItemProtocol,
                      at indexPath: IndexPath,
                      with batchAnimationOptions: AnimationOptionsRepresentable,
                      with completion: (() -> ())? = nil)
 {
  photoCollectionView.performAnimatedBatchUpdates(batchAnimationOptions,
  {[ weak self ] in
   guard let self = self else { return }
   self.photoItems2D[indexPath.section].insert(newPhotoItem, at: indexPath.row)
   self.photoCollectionView.insertItems(at: [indexPath])
  })
  {[ weak self ] _ in
   self?.updateSectionFooter(for: indexPath.section)
   completion?()
  }
  
 }//func insertPhotoItem(_ newPhotoItem: PhotoItemProtocol...
 
 
 
 func insertNewPhotoItem(_ newPhotoItem: PhotoItemProtocol,
                           with batchAnimationOptions: AnimationOptionsRepresentable,
                           into section: Int)
 {
  let indexPath = insertNewIndexPath(newPhotoItem, into: section)
  insertPhotoItem(newPhotoItem, at: indexPath, with: batchAnimationOptions)
 }
 

 
 func insertDefaultSection()
 //tries to insert default [0] section for cuurent group type when photo is taken in new empty photo snippet
 //this is performed whiout any animation block
 {
  guard photoItems2D.isEmpty else { return }
  guard let groupType = photoCollectionView.photoGroupType else { return }
  photoItems2D.append([])
  
  if groupType.isSectioned
  {
   let title = groupType.defaultSectionTitle! // insert default section name!
   sectionTitles = [title]
  }
  
  photoCollectionView.insertSections([0])
  
 }
 
 
 

 func insertNewPhotoItem(_ newPhotoItem: PhotoItem,
                           with batchAnimationOptions: AnimationOptionsRepresentable)
  //insert new photo item when photo is taken with photo picker controller...
 {
  guard let groupType = photoCollectionView.photoGroupType else { return }
  
  var newItemSection = 0
  
  defer { insertNewPhotoItem(newPhotoItem, with: batchAnimationOptions, into: newItemSection) }
  
  insertDefaultSection()
  
  guard groupType.isSectioned else { return }
  
  let title = groupType.defaultSectionTitle!
  
  if let section = sectionTitles?.firstIndex(of: title) { newItemSection = section }
  else
  {
   newItemSection = photoSnippet.ascending ? 0 : photoItems2D.count
   photoItems2D.insert([], at: newItemSection )
   sectionTitles?.insert(title, at: newItemSection )
   photoCollectionView.insertSections([newItemSection])
  }
 
  
  
 }// func insertNewPhotoItem(_:)...
 
 
 func insertNewSection(with title: String, at index: Int,
                       with batchAnimationOptions: AnimationOptionsRepresentable,
                       with completion: ( () -> () )? = nil)
 {
  photoCollectionView.performAnimatedBatchUpdates(batchAnimationOptions,
  { [ weak self ] in
   guard let self = self else { return }
   self.photoItems2D.insert([], at: index)
   self.sectionTitles?.insert(title, at: index)
   self.photoCollectionView.insertSections([index])
  })
  {_ in
   completion?()
  }

 }
 
 func newSectionIndex(for object: PhotoItemManagedObjectProtocol) -> Int?
 {
  let rate = object.sectionIndex
  return photoItemsSections?.filter
  {title in
   photoSnippet.ascending ? title.rateIndex < rate: title.rateIndex > rate
  }.count
  
 }
 
 func insertNewSectionIfNeeded(for object: PhotoItemManagedObjectProtocol,
                               with batchAnimationOptions: AnimationOptionsRepresentable,
                               with completion: @escaping (Int) -> () )
 {
  
  //if we have absolutely empty photo snippet we insert very first section at 0
  //if group type is sectioned and sectionTitles != nil
  //the section title will be the one of insreted object!
  
  if photoItems2D.isEmpty
  {
   insertNewSection(with: object.sectionTitle ?? "", at: 0, with: batchAnimationOptions)
   completion(0)
   return
  }
  
  // if there is only one sigle section with zero index since snippet is unsectioned
  if sectionTitles == nil { completion(0); return }
  
  //the snippet is sectioned and we check if threre exists section with object section title
  
  if let oldSection = cellSection(with: object) { completion(oldSection); return }
  
  //we obtain its new index based on sectionTitles array current state...
  guard let newSectionIndex = newSectionIndex(for: object) else { return }
  
  insertNewSection(with: object.sectionTitle ?? "", at: newSectionIndex, with: batchAnimationOptions)
  {
   completion(newSectionIndex)
  }
  
 }
 
} //extension PhotoSnippetViewController...
