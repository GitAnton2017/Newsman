//
//  Photo Folder D&D Extension.swift
//  Newsman
//
//  Created by Anton2016 on 14/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import protocol RxSwift.Disposable

extension PhotoFolderItem
{ 
 var isZoomed: Bool
 {
  get { folder.zoomedPhotoItemState }
  set
  {
   guard folder.managedObjectContext != nil else { return }
   guard folder.isDeleted == false else { return }
   folder.zoomedPhotoItemState = newValue
  }
 }
 
 func toggleSelection() { isSelected.toggle() }
 
 var isSelected: Bool
 {
  get { folder.isSelected }
  set
  {
   folder.managedObjectContext?.perform
   {
    guard self.folder.isDeleted == false else { return }
    guard self.folder.isSelected != newValue else { return }
    self.folder.isSelected = newValue
    self.folder.photos?
     .compactMap{ $0 as? Photo }
     .forEach { $0.isSelected = newValue }
   }
  }//set...
  
 }//var isSelected: Bool...
 
 
 var isDragAnimating: Bool
 {
  get { folder.isDragAnimating }
  set
  {
   
   folder.managedObjectContext?.perform
   {
    guard self.folder.isDeleted == false else { return }
    guard self.folder.isDragAnimating != newValue else { return }
    self.folder.isDragAnimating = newValue
    self.folder.photos?
     .compactMap{ $0 as? Photo }
     .forEach { $0.isDragAnimating = newValue }
   }
  }//set...
  
 }//var isDragAnimating: Bool...
 
 var isDropProceeding: Bool
 {
  get { folder.isDropProceeding }
  set
  {
   guard folder.managedObjectContext != nil else { return }
   guard folder.isDeleted == false else { return }
   folder.isDropProceeding = newValue
   folder.photos?
    .compactMap{ $0 as? Photo }
    .forEach { $0.isDropProceeding = newValue }
  }
 }
 
 var isDragProceeding: Bool
 {
  get { folder.isDragProceeding }
  set
  {
   guard folder.managedObjectContext != nil else { return }
   guard folder.isDeleted == false else { return }
   folder.isDragProceeding = newValue
   folder.photos?
    .compactMap{$0 as? Photo}
    .forEach { $0.isDragProceeding = newValue }
  }
 }
 
 var dragProceedLocation: CGPoint
 {
  get { folder.dragProceedLocation }
  set
  {
   guard folder.isDeleted == false else { return }
   guard folder.managedObjectContext != nil else { return }
   folder.dragProceedLocation = newValue
  }
 }
 
 var isJustCreated: Bool
 {
  get { folder.isJustCreated }
  set
  {
   guard folder.isDeleted == false else { return }
   guard folder.managedObjectContext != nil else { return }
   folder.isJustCreated = newValue
  }
 }
 
 var dragStateSubscription: Disposable?
 {
  get { folder.dragStateSubscription }
  set
  {
   guard folder.isDeleted == false else { return }
   guard folder.managedObjectContext != nil else { return }
   folder.dragStateSubscription = newValue
  }
 }
 
 var dragProceedSubscription: Disposable?
 {
  get { folder.dragProceedSubscription }
  set
  {
   guard folder.isDeleted == false else { return }
   guard folder.managedObjectContext != nil else { return }
   folder.dragProceedSubscription = newValue
  }
 }
 
} //extension PhotoFolderItem...
