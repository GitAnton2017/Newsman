//
//  Photo Snippet CV DS Single Items.swift
//  Newsman
//
//  Created by Anton2016 on 21/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension PhotoSnippetViewController
{
 
 func unfolderSingleItem(after notification: Notification)
 {
  guard notification.name == .singleItemDidUnfolder else { return }
  guard let singlePhoto = notification.object as? Photo else { return }
  guard singlePhoto.photoSnippet?.objectID == self.photoSnippet.objectID else
  {
   dragAndDropDelegate?.ddDelegateSubject.onNext(.final)
   return
  }
  
  insertFolderSinglePhoto(singlePhoto: singlePhoto, with: BatchAnimationOptions.withSmallJump(0.5))
  {[ weak self ] in
   self?.dragAndDropDelegate?.ddDelegateSubject.onNext(.final)
  }
  
 }//func unfolderSingleItem(...)
 
 
 
 func insertFolderSinglePhoto(singlePhoto: Photo,
                              with batchAnimationOptions: AnimationOptionsRepresentable,
                              with completion: ( () -> () )? = nil)
 {
  insertNewSectionIfNeeded(for: singlePhoto, with: batchAnimationOptions)
  {[ weak self ] section in
   let singlePhotoItem = PhotoItem(photo: singlePhoto)
   guard let indexPath = self?.targetIndexPath(of: singlePhotoItem, in: section) else { return }
   self?.insertPhotoItem(singlePhotoItem, at: indexPath, with: batchAnimationOptions, with: completion)
 
  }
 }//func insertFolderSinglePhoto(...)
 
 
 func insertSingleFolderItem(item singlePhotoItem: PhotoItem,
                             with batchAnimationOptions: AnimationOptionsRepresentable)
 {
  var singleItemSection = 0

  defer //finally insert single item of deleted folder into proper CV section...
  {
   insertNewPhotoItem(singlePhotoItem, with: batchAnimationOptions, into: singleItemSection)
  }

  guard photoCollectionView.photoGroupType?.isSectioned ?? false else { return }

  if let index = sectionTitles?.firstIndex(of: singlePhotoItem.sectionTitle ?? "")
  {
   singleItemSection = index
  }
  else
  {
   singleItemSection = photoItems2D.filter
   {section in
    photoSnippet.ascending ? (section.first?.sectionIndex ?? -1) < singlePhotoItem.sectionIndex:
                             (section.first?.sectionIndex ?? -1) > singlePhotoItem.sectionIndex
   }.count

   photoItems2D.insert([], at: singleItemSection)
   sectionTitles?.insert(singlePhotoItem.sectionTitle ?? "", at: singleItemSection)
   photoCollectionView.insertSections([singleItemSection])
  }


 } //func insertSingleFolderItem...
 
 
}
