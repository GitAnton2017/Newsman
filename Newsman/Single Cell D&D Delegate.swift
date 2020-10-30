//
//  Single Cell D&D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 14/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class SingleCellDropViewDelegate: PhotoItemCellDragAndDropBaseDelegate
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
  guard let destPhotoItem = hosted as? PhotoItem else { return 0 }
  
  let group = DispatchGroup()
   
  group.performBatchTask(batch: draggedItems[0...0], asyncTask:
  {
   $0.move(to: destSnippet, to: destPhotoItem, to: nil, completion: $1)
  })
  {
   guard let newFolder = destPhotoItem.folder.map({ PhotoFolderItem(folder: $0) }) else { return }
   
   group.performBatchTask(batch: draggedItems[1...], asyncTask:
   {
    $0.move(to: destSnippet, to: newFolder, to: .zero, completion: $1)
   })
   
  }
  
  return dragEventsCount
 
 } //func moveInAppItemsRx....
 
 
}//extension PhotoSnippetCell: UIDragInteractionDelegate, UIDropInteractionDelegate....
