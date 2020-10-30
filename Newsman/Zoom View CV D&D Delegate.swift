
//import Foundation
//import CoreData
//import UIKit
//import RxSwift
//import RxCocoa
//
//
//extension ZoomView: UICollectionViewDragDelegate,
//                    UICollectionViewDropDelegate,
//                    PhotoItemsDraggable
// 
//{
//
// var photoSnippet: PhotoSnippet! { photoSnippetVC.photoSnippet }
// 
// var isDraggable: Bool { true }
// 
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
// {
//  print (#function, session.description, session.items.count)
//  //AppDelegate.clearAllDragAnimationCancelWorkItems()
//
// }
// 
//
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession)
// {
//  print (#function, session.description)
// }
// 
// 
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession)
// {
//  print (#function, session.description)
//  //AppDelegate.clearAllDraggedItems()
//  
// }
// 
// func isDragOverlayedByArrowMenu (_ collectionView: UICollectionView,
//                                    forCellAt indexPath: IndexPath) -> Bool
// {
//  guard
//   let dragCell = collectionView.cellForItem(at: indexPath) as? ZoomViewCollectionViewCell,
//   let visibleCells = collectionView.visibleCells as? [ZoomViewCollectionViewCell],
//   let menuView = visibleCells.first(where: {$0.arrowMenuView != nil})?.arrowMenuView?.baseView
//  else { return false }
//  
//  let menuRect = collectionView.convert(menuView.bounds, from: menuView)
//  
//  return dragCell.frame.intersects(menuRect)
// }
//
// 
// func getDragItems (_ collectionView: UICollectionView,
//                      for session: UIDragSession,
//                      forCellAt indexPath: IndexPath) -> [UIDragItem]
//  
// {
//  
//  if isDragOverlayedByArrowMenu(collectionView, forCellAt: indexPath) { return [] }
//  
//  let dragged = photoItems[indexPath.row]
//  
//  guard collectionView.cellForItem(at: indexPath) != nil else { return [] }
//  
//  guard dragged.isDraggable else { return [] }
//  //check up eligibility for dragging with current drag session...
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
// func dragItemsForBeginning(in collectionView: UICollectionView,
//                            for session: UIDragSession,
//                            at indexPath: IndexPath) -> [UIDragItem]
// 
// {
//  print (#function, session.description)
//  
//  guard isDraggable else { return [] }
//  
//  let itemsForBeginning = getDragItems(collectionView, for: session, forCellAt: indexPath)
//  
//  //Auto cancel all dragged PhotoItems only!
////  itemsForBeginning.compactMap{$0.localObject as? PhotoItem}.forEach
////  {item in
////   let autoCancelWorkItem = DispatchWorkItem
////   {
////    item.clear(with: (forDragAnimating: AppDelegate.dragAnimStopDelay,
////                      forSelected:      AppDelegate.dragUnselectDelay))
////   }
////   
////   item.dragAnimationCancelWorkItem = autoCancelWorkItem
////   let delay: DispatchTime = .now() + .seconds(AppDelegate.dragAutoCnxxDelay)
////   DispatchQueue.main.asyncAfter(deadline: delay, execute: autoCancelWorkItem)
////    
////  }
//  
//  return itemsForBeginning
// }//func dragItemsForBeginning(in collectionView...
// 
// 
// 
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView,
//                       itemsForBeginning session: UIDragSession,
//                       at indexPath: IndexPath) -> [UIDragItem]
//
// {
//  return dragItemsForBeginning(in: collectionView, for: session, at: indexPath)
// }
//
// 
// 
// 
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView,
//                       itemsForAddingTo session: UIDragSession,
//                       at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
//
// {
//  print (#function, session.description)
//  return getDragItems(collectionView, for: session, forCellAt: indexPath)
// }
//
// 
// 
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView,
//                       dropSessionDidUpdate session: UIDropSession,
//                       withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
// {
//  switch (session.localDragSession, session.items.count, session.items.first?.localObject)
//  {
//   case (_?,  1, let dragged as PhotoFolderItem):
//    let op: UIDropOperation = dragged.isDragAnimating && dragged.isZoomed ? .forbidden : .move
//    return UICollectionViewDropProposal(operation: op , intent: .insertAtDestinationIndexPath)
//   case (_?,  1, is PhotoItem):
//    return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//   case (_?, let k, _) where k > 1:
//    return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
//   case (nil, _, _):
//    return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
//   default:
//    return UICollectionViewDropProposal(operation: .cancel, intent: .unspecified)
//  }
//  
// }
// 
// 
// 
// 
// 
// func copyPhotosFromSideApp (_ collectionView: UICollectionView,
//                             performDropWith coordinator: UICollectionViewDropCoordinator,
//                             at destinationIndexPath: IndexPath)
//
// {
//  print(#function)
//  for item in coordinator.items
//  {
//   let dragItem = item.dragItem
//   guard dragItem.itemProvider.canLoadObject(ofClass: UIImage.self) else {continue}
//   let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
//                                                     reuseIdentifier: "ZoomCollectionViewCell")
//   
//   let placeholderContext = coordinator.drop(dragItem, to: placeholder)
//   dragItem.itemProvider.loadObject(ofClass: UIImage.self)
//   {[weak self] item, error in
//    OperationQueue.main.addOperation
//    {
//     guard let image = item as? UIImage,
//           let ip = self?.zoomedCellIndexPath,
//           let vc = self?.photoSnippetVC,
//           let imageSize = self?.imageSize,
//           let zoomedCell = vc.photoCollectionView.cellForItem(at: ip) as? PhotoFolderCell
//      
//     else
//     {
//       placeholderContext.deletePlaceholder()
//       return
//     }
//     
//     placeholderContext.commitInsertion
//     {indexPath in
//      let newPhotoItem = PhotoItem(photoSnippet: vc.photoSnippet, image: image, cachedImageWidth:imageSize)
//      zoomedCell.photoItems.insert(newPhotoItem, at: indexPath.row)
//      zoomedCell.photoCollectionView.insertItems(at: [indexPath])
//      self?.photoItems.insert(newPhotoItem, at: indexPath.row)
//     }
//    }
//   }
//  }
//  
// }
// 
// 
// func performDrop(in collectionView: UICollectionView, with coordinator: UICollectionViewDropCoordinator)
// {
//  print (#function, coordinator.session)
//  
//  guard let destinationIndexPath = coordinator.destinationIndexPath else {return}
//  
//  switch (coordinator.proposal.operation)
//  {
//   case .move: moveInAppItemsRx      (collectionView, performDropWith: coordinator, to: destinationIndexPath)
//   case .copy: copyPhotosFromSideApp (collectionView, performDropWith: coordinator, at: destinationIndexPath)
//   default: break
//  }
// }//func performDrop(in collectionView...
// 
// 
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView,
//                       performDropWith coordinator: UICollectionViewDropCoordinator)
//
// {
//  performDrop(in: collectionView, with: coordinator)
// } //func collectionView(_ collectionView: UICollectionView, performDropWith...
// 
// 
//
// func moveInAppItemsRx(_ collectionView: UICollectionView,
//                       performDropWith coordinator: UICollectionViewDropCoordinator,
//                       to destinationIndexPath: IndexPath)
//  
// {
//  print (#function)
//  
//  let group = DispatchGroup()
//  
////  defer //finally remove and clear all drag items...
////  {
////   group.notify(queue: .main) { AppDelegate.clearAllDraggedItems() }
////  }
//  
//  let draggedItems = AppDelegate.globalDragItems.filter{ $0.dragSession != nil }
//  //filter out not cancelled items!
//  
//  let count = AppDelegate.globalDragItems.count
//  
//  ddPublish.enumerated()
//           .debug()
//           .filter{ $0.index == count - 1 }
//           .subscribe(onNext:
//            {[weak self] _ in
//             self?.repositionItemsIfNeeded(after: 1)
//             {[weak self] in
//              self?.ddPublish.onCompleted()
//             }
//             guard let folderItem = self?.zoomedPhotoItem as? PhotoFolderItem else { return }
//             guard let folderCell = folderItem.hostingCollectionViewCell as? PhotoFolderCell else { return }
//             folderCell.repositionItemsIfNeeded(after: 1)
//            },
//            onCompleted: { [weak self] in self?.ddPublish = PublishSubject() },
//            onDisposed:
//            {[weak self] in
//             print("DD PUBS DISPOSED", count, self?.photoSnippet?.tag ?? "---")
//            }).disposed(by: disposeBag)
//  
//  draggedItems.forEach
//  {dragItem in
//   let position = photoItemPosition(for: destinationIndexPath)
//   group.enter()
//   dragItem.move(to: photoSnippet, to: zoomedPhotoItem, to: position) { group.leave() }
//  }
// }//func moveInAppItemsRx(_ collectionView:...
//
//}





