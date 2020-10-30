//
//  Folder Cell D&D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 09/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class FolderCellDropViewDelegate: PhotoItemCellDragAndDropBaseDelegate
{
 override final func performDrop(in interaction: UIDropInteraction, with session: UIDropSession) -> Int
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  
  if session.localDragSession != nil
  {
   return mergeWithInAppItems(interaction, performDrop: session)
  }
  
  return 0
 }
 
 final private func mergeWithInAppItems(_ interaction: UIDropInteraction,
                                          performDrop session: UIDropSession) -> Int
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  
  let draggedItems = self.draggedItems
  
  guard draggedItems.count > 0 else { return 0 }
  guard let destSnippet = snippet as? PhotoSnippet else { return 0 }
  guard let destFolderItem = hosted as? PhotoFolderItem else { return 0 }
  
  let group = DispatchGroup()

  group.performBatchTask(batch: draggedItems, asyncTask:
  {
   $0.move(to: destSnippet, to: destFolderItem, to: .zero, completion: $1)
  })
  

  return dragEventsCount
  
 } //func moveInAppItemsRx....
 
 
 
}
