//
//  Photo Folder D&D Extension.swift
//  Newsman
//
//  Created by Anton2016 on 14/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

extension PhotoFolderItem
{
 var isFolderDragged: Bool
 {
  return singlePhotoItems.contains{$0.isDragAnimating}
 }
 
 var isSetForClear: Bool
 {
  get
  {
   return folder.dragAndDropAnimationSetForClearanceState
  }
  set
  {
   folder.dragAndDropAnimationSetForClearanceState = newValue
  }
 }
 
 var isZoomed: Bool
 {
  get
  {
   return folder.zoomedPhotoItemState
  }
  set
  {
   folder.zoomedPhotoItemState = newValue
  }
 }
 
 func toggleSelection()
 {
  isSelected.toggle()
 }
 
 var isSelected: Bool
 {
  get {return self.folder.isSelected}
  set
  {
   folder.photoSnippet?.currentFRC?.deactivateDelegate()
   folder.managedObjectContext?.persistAndWait(block:
    {
     self.folder.isSelected = newValue
     self.folder.photos?.forEach {($0 as! Photo).isSelected = newValue}
   })
   {flag in
    if flag
    {
     //self.hostingCollectionViewCell?.isPhotoItemSelected = newValue
     // if folder dragged we update all the underlying zoom view single photo items selection state.
//     self.zoomView?.photoItems.compactMap{$0.hostingZoomedCollectionViewCell}.forEach
//      {
//       $0.isPhotoItemSelected = newValue
//     }
     self.folder.photoSnippet?.currentFRC?.activateDelegate()
    }
   }
  }
 }
 
 var isDragAnimating: Bool
 {
  get {return folder.dragAndDropAnimationState}
  set
  {
   folder.dragAndDropAnimationState = newValue
   hostingCollectionViewCell?.isDragAnimating = newValue
   folder.folderedPhotos.forEach { $0.dragAndDropAnimationState = newValue }
   // if folder dragged we update all the underlying zoom view single photo items drag animation state.
   zoomView?.photoItems.compactMap{$0.hostingZoomedCollectionViewCell}.forEach
   {
     $0.isDragAnimating = newValue
   }
  }
 }

} //extension PhotoFolderItem...
