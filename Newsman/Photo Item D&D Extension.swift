//
//  Photo Item D&D Extension.swift
//  Newsman
//
//  Created by Anton2016 on 14/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import protocol RxSwift.Disposable


extension PhotoItem
{
 var isFoldered: Bool { photo.isFoldered }
 
 var isZoomed: Bool
 {
  get { photo.zoomedPhotoItemState }
  set
  {
   guard photo.isDeleted == false else { return }
   guard photo.managedObjectContext != nil else { return }
   photo.zoomedPhotoItemState = newValue
  }
 }
 

  
 func toggleSelection() { isSelected.toggle() }
 
 var isSelected: Bool
 {
  get { photo.isSelected }
  set
  {
   photo.managedObjectContext?.perform
   {
    guard self.photo.isDeleted == false else { return }
    guard newValue != self.photo.isSelected else { return }
    self.photo.isSelected = newValue
    guard let folder = self.photo.folder else  { return }
    guard folder.managedObjectContext != nil else { return }
    guard folder.isDeleted == false else  { return }
    folder.isSelected = folder.areAllPhotosSelected
   }
  }
 }//var isSelected: Bool...
 

 var isDragAnimating: Bool
 {
  get { photo.isDragAnimating }
  set
  {
   photo.managedObjectContext?.perform
   {
    guard self.photo.isDeleted == false else { return }
    guard newValue != self.photo.isDragAnimating else { return }
    self.photo.isDragAnimating = newValue
   }
  }
 }//var isDragAnimating: Bool
 
 var isDropProceeding: Bool
 {
  get { photo.isDropProceeding }
  set
  {
   guard photo.isDeleted == false else { return }
   guard photo.managedObjectContext != nil else { return }
   photo.isDropProceeding = newValue
  }
 }
 
 var isDragProceeding: Bool
 {
  get { photo.isDragProceeding }
  set
  {
   guard photo.isDeleted == false else { return }
   guard photo.managedObjectContext != nil else { return }
   photo.isDragProceeding = newValue
  }
 }
 
 var dragProceedLocation: CGPoint
 {
  get { photo.dragProceedLocation }
  set
  {
   guard photo.isDeleted == false else { return }
   guard photo.managedObjectContext != nil else { return }
   photo.dragProceedLocation = newValue
  }
 }
 
 var isJustCreated: Bool
 {
  get { photo.isJustCreated }
  set
  {
   guard photo.isDeleted == false else { return }
   guard photo.managedObjectContext != nil else { return }
   photo.isJustCreated = newValue
  }
 }
 
 var dragStateSubscription: Disposable?
 {
  get { photo.dragStateSubscription }
  set
  {
   guard photo.isDeleted == false else { return }
   guard photo.managedObjectContext != nil else { return }
   photo.dragStateSubscription = newValue
  }
 }
 var dragProceedSubscription: Disposable?
 {
  get { photo.dragProceedSubscription }
  set
  {
   guard photo.isDeleted == false else { return }
   guard photo.managedObjectContext != nil else { return }
   photo.dragProceedSubscription = newValue
  }
 }
 
 
} //extension PhotoItem
