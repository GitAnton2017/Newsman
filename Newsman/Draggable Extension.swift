//
//  Draggable Extension.swift
//  Newsman
//
//  Created by Anton2016 on 14/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

extension Draggable
{
 var isDraggable: Bool
 {
  return !(isDragAnimating || isSetForClear || isFolderDragged)
 }
 
 
 func clear (with delays: (forDragAnimating: Int, forSelected: Int), completion: (()->())? = nil)
 {
  
  if isSetForClear { return }
  
  print (#function, self, self.dragSession ?? "No session")
  
  dragAnimationCancelWorkItem = nil
  
  isSetForClear = true //this flag is set when clear block is about to fire to avoid multiple calls of clear()
  
  DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delays.forDragAnimating))
  {
   self.isDragAnimating = false
   DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delays.forSelected))
   {
    self.isSelected = false
    self.isSetForClear = false  //unset flag after full completion
    self.removeFromDrags()
    completion?()               //fire completion handler for additional post animation actions if any needed
   }
  }
 }
 
 
 
 func moveToDrops(allNestedItems flag: Bool = false)
 {
  AppDelegate.globalDragItems.removeAll{$0.hostedManagedObject === self.hostedManagedObject}
  
  switch (self, flag)
  {
   case (_ , false): AppDelegate.globalDropItems.append(self)
   
   case let (folderItem as PhotoFolderItem, true ):
    folderItem.isSelected = false
    folderItem.isDragAnimating = false
    let singles = folderItem.singlePhotoItems
    singles.forEach
    {
     $0.isSelected = true
     $0.isDragAnimating = true
    }
    AppDelegate.globalDropItems.append(contentsOf: singles)
   
   case let (snippetItem as SnippetDragItem, true ):
    guard let allItems = (snippetItem.snippet as? PhotoSnippet)?.allItems else { break }
    allItems.forEach
    {
     $0.isSelected = true
     $0.isDragAnimating = true
    }
    AppDelegate.globalDropItems.append(contentsOf: allItems)
   
   default: break
  }
 }
 
 
 
 func removeFromDrags()
 {
  print (#function, self, self.dragSession ?? "No session")
  
  //remove drag item from drags personally if found...
  AppDelegate.globalDragItems.removeAll{$0.hostedManagedObject === self.hostedManagedObject}
  
  //remove drag item from drops personally if found...
  AppDelegate.globalDropItems.removeAll{$0.hostedManagedObject === self.hostedManagedObject}
 }
 
 
}//extension Draggable...
