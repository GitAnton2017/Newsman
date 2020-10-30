//
//  Folder Cell CV D&D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 14/02/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

//import UIKit
//
//extension PhotoFolderCell: UICollectionViewDragDelegate
//{
// func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
// {
//  print (#function, self.debugDescription, session.description, session.items.count)
//  AppDelegate.clearAllDragAnimationCancelWorkItems()
//  
// }
// 
// func isDragOverlayedByArrowMenu (_ collectionView: UICollectionView,
//                                    forCellAt indexPath: IndexPath) -> Bool
// {
//  guard
//   let dragCell = collectionView.cellForItem(at: indexPath) as? PhotoFolderCollectionViewCell,
//   let visibleCells = collectionView.visibleCells as? [PhotoFolderCollectionViewCell],
//   let menuView = visibleCells.first(where: {$0.arrowMenuView != nil})?.arrowMenuView?.baseView
//  else { return false }
//  
//  let menuRect = collectionView.convert(menuView.bounds, from: menuView)
//  
//  return dragCell.frame.intersects(menuRect)
// }
// 
// func getDragItems (_ collectionView: UICollectionView,
//                    for session: UIDragSession,
//                    forCellAt indexPath: IndexPath) -> [UIDragItem]
//  
// {
//  if isDragOverlayedByArrowMenu(collectionView, forCellAt: indexPath) { return [] }
//  
//  let dragged = photoItems[indexPath.row]
//  
//  guard collectionView.cellForItem(at: indexPath) != nil else { return [] }
//  
//  guard dragged.isDraggable else { return [] } //check up eligibility for dragging with current drag session...
//  
//  AppDelegate.globalDragItems.append(dragged)
//  
//  let itemProvider = NSItemProvider()
//  let dragItem = UIDragItem(itemProvider: itemProvider)
//  
//  dragged.isSelected = true          //make selected in MOC
//  dragged.isDragAnimating = true     //start drag animation of associated view
//  dragged.dragSession = session
//  dragItem.localObject = dragged
//  
//  AppDelegate.printAllDraggedItems()
//  
//  return [dragItem]
//  
// }
//
//
// var isDraggable: Bool
// {
//  switch (itemsInRow, deviceType, vsc, hsc)
//  {
//   case (1...2, .phone, .regular, .compact),
//        (1...2, .phone, .compact, .compact),
//        (1...3, .phone, .compact, .regular),
//        (1...5, .pad,   .regular, .regular): return true
//   
//   default: return false
//  }
// }
// 
//
// 
// func collectionView(_ collectionView: UICollectionView,
//                     itemsForBeginning session: UIDragSession,
//                     at indexPath: IndexPath) -> [UIDragItem]
//  
// {
//  print (#function, self.debugDescription, session.description)
// 
//  guard isDraggable else { return [] }
//  
//  let name = PhotoSnippetCell.menuLongPressName
//  self.gestureRecognizers?.first{$0.name == name}?.state = .failed
//  
//  let itemsForBeginning = getDragItems(collectionView, for: session, forCellAt: indexPath)
//  
//  //Auto cancel all dragged PhotoItems only!
////  itemsForBeginning.compactMap{$0.localObject as? PhotoItem}.forEach
////   {item in
////    let autoCancelWorkItem = DispatchWorkItem
////    {
////     item.clear(with: (forDragAnimating: AppDelegate.dragAnimStopDelay,
////                       forSelected:      AppDelegate.dragUnselectDelay))
////    }
////    
////    item.dragAnimationCancelWorkItem = autoCancelWorkItem
////    let delay: DispatchTime = .now() + .seconds(AppDelegate.dragAutoCnxxDelay)
////    DispatchQueue.main.asyncAfter(deadline: delay, execute: autoCancelWorkItem)
////    
////  }
//  
//  return itemsForBeginning
//  
// }
// 
// 
// 
// 
// 
// func collectionView(_ collectionView: UICollectionView,
//                     itemsForAddingTo session: UIDragSession,
//                     at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
//  
// {
//  print (#function, self.debugDescription, session.description)
//  return getDragItems(collectionView, for: session, forCellAt: indexPath)
// }
//
// 
// 
//}
//
