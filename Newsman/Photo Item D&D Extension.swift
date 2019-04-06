//
//  Photo Item D&D Extension.swift
//  Newsman
//
//  Created by Anton2016 on 14/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

extension PhotoItem
{
 
 var isZoomed: Bool
 {
  get { return photo.zoomedPhotoItemState }
  set { photo.zoomedPhotoItemState = newValue }
 }
 
 var isFolderDragged: Bool
 {
  guard let folder = self.folder else { return false }
  return folder.dragAndDropAnimationState
 }
 
 var isSetForClear: Bool
 {
  get { return photo.dragAndDropAnimationSetForClearanceState }
  set { photo.dragAndDropAnimationSetForClearanceState = newValue }
 }
 
 func toggleSelection()
 {
  isSelected.toggle()
 }
 
 var isSelected: Bool
 {
  get { return self.photo.isSelected }
  set
  {
   photo.photoSnippet?.currentFRC?.deactivateDelegate()
   photo.managedObjectContext?.persistAndWait(block: { self.photo.isSelected = newValue })
   {flag in
    if flag
    {
//     self.hostingCollectionViewCell?.isPhotoItemSelected = newValue
//     self.hostingZoomedCollectionViewCell?.isPhotoItemSelected = newValue
     self.photo.photoSnippet?.currentFRC?.activateDelegate()
    }
   }
  }
 }
 
 
 var isDragAnimating: Bool
 {
  get
  {
    return photo.isDragAnimating
//   return photo.dragAndDropAnimationState
  }
  
  set
  {
   
   photo.managedObjectContext?.persist{ self.photo.isDragAnimating = newValue }
   
//   photo.dragAndDropAnimationState = newValue
//   self.hostingCollectionViewCell?.isDragAnimating = newValue
//   self.hostingZoomedCollectionViewCell?.isDragAnimating = newValue
  }
 }
 
 
 
}
