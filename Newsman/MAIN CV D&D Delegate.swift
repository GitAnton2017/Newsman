//
//  MAIN CV D&D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 30/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import RxSwift


//extension PhotoSnippetViewController: UICollectionViewDragDelegate,
//                                      UICollectionViewDropDelegate,
//                                      //PhotoItemsDraggable//, DragAndDropStatesObservation
//{
//
//// var isDraggable: Bool
//// {
////  switch (itemsInRow, deviceType, vsc, hsc)
////  {
////   case (2... , .phone, .regular, .compact),
////        (5... , .phone, .compact, .compact),
////        (6... , .phone, .compact, .regular),
////        (7... , .pad,   .regular, .regular): return true
////
////   default: return false
////  }
//// }//var isDraggable: Bool...
//
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
// {
//  print (#function, session.description, session.items.count)
//  //ddDelegateSubject.onNext(.begin)
//  //  AppDelegate.clearAllDragAnimationCancelWorkItems()
//
// }//func collectionView(_ collectionView...
//
//
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession)
// {
//  print (#function, session.description)
//  //ddDelegateSubject.onNext(.end)
//  //AppDelegate.clearAllDraggedItems()
// }//func collectionView(_ collectionView: UICollectionView...
//
//
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession)
// {
//  defer { isDropPerformed = false }
//
//  print (#function, session.description)
////  if isDropPerformed { return }
//  //AppDelegate.clearAllDraggedItems()
//
//
//
//
// }//func collectionView(_ collectionView: UICollectionView...
//
//
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView,
//                     itemsForBeginning session: UIDragSession,
//                     at indexPath: IndexPath) -> [UIDragItem]
//
// {
//  return dragItemsForBeginning(in: collectionView, for: session, at: indexPath)
// }
//
//
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView,
//                     itemsForAddingTo session: UIDragSession,
//                     at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
//
// {
//  print (#function, session.description)
//  return getDragItems(collectionView, for: session, forCellAt: indexPath)
// }
//
//
// //D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView,
//                     dropSessionDidUpdate session: UIDropSession,
//                     withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
//
// {
//
//  //ddDelegateSubject.onNext(.proceed(location: session.location(in: collectionView)))
//
//  if (session.localDragSession != nil)
//  {
//   return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
//  }
//  else
//  {
//   return UICollectionViewDropProposal(operation: .copy , intent: .insertAtDestinationIndexPath)
//  }
//
// }//func collectionView(_ collectionView: UICollectionView
//
//
//
////D&D DELEGATE METHOD
// func collectionView(_ collectionView: UICollectionView,
//                      performDropWith coordinator: UICollectionViewDropCoordinator)
//
// {
//  performDrop(in: collectionView, with: coordinator)
// }//func collectionView(_ collectionView: UICollectionView, performDropWith...
//
//
//
//
// func copyPhotosFromSideApp (_ collectionView: UICollectionView,
//                             performDropWith coordinator: UICollectionViewDropCoordinator,
//                             at destinationIndexPath: IndexPath)
//
// {
//  PhotoItem.MOC.persistAndWait
//  {
//   for item in coordinator.items
//   {
//    let dragItem = item.dragItem
//    guard dragItem.itemProvider.canLoadObject(ofClass: UIImage.self) else {continue}
//
//    let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
//                                                      reuseIdentifier: "PhotoSnippetCell")
//
//    let placeholderContext = coordinator.drop(dragItem, to: placeholder)
//    dragItem.itemProvider.loadObject(ofClass: UIImage.self)
//    {[weak self] item, error in
//     OperationQueue.main.addOperation
//      {
//       guard let image = item as? UIImage else
//       {
//        placeholderContext.deletePlaceholder()
//        return
//       }
//       placeholderContext.commitInsertion
//        {indexPath in
//         let newPhotoItem = PhotoItem(photoSnippet: (self?.photoSnippet)!,
//                                      image: image,
//                                      cachedImageWidth: (self?.imageSize)!)
//
//         if let flagStrs = self?.sectionTitles
//         {
//          newPhotoItem.photo.priorityFlag = flagStrs[indexPath.section]
//         }
//
//         self?.photoItems2D[indexPath.section].insert(newPhotoItem, at: indexPath.row)
//       }
//     }
//    }
//   }
//  }
// }//func copyPhotosFromSideApp (_ collectionView: UICollectionView...
//
//
// func isDragOverlayedByArrowMenu (_ collectionView: UICollectionView,
//                                    forCellAt indexPath: IndexPath) -> Bool
// {
//  guard
//   let dragCell = collectionView.cellForItem(at: indexPath) as? PhotoSnippetCellProtocol,
//   let visibleCells = collectionView.visibleCells as? [PhotoSnippetCellProtocol],
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
//
//  print (#function, session.description)
//
//  if isDragOverlayedByArrowMenu(collectionView, forCellAt: indexPath) { return [] }
//
//  guard collectionView.cellForItem(at: indexPath) != nil else { return [] }
//
//  let dragged = photoItems2D[indexPath.section][indexPath.row]
//
//  guard dragged.isDraggable else { return [] } //check up if it is really eligible for drags...
//
//  let itemProvider = NSItemProvider()
//  let dragItem = UIDragItem(itemProvider: itemProvider)
//  dragged.dragSession = session
//  dragItem.localObject = dragged
//  //ddDelegateSubject.onNext(.flock(dragItem: dragged))
//
//  return [dragItem]
//
// }//func getDragItems (_ collectionView: UICollectionView...
//
//
//
// func dragItemsForBeginning(in collectionView: UICollectionView, for session: UIDragSession,
//                            at indexPath: IndexPath) -> [UIDragItem]
// {
//  print (#function, session.description)
//
//  guard isDraggable else { return [] }
//  let itemsForBeginning = getDragItems(collectionView, for: session, forCellAt: indexPath)
//  return itemsForBeginning
//
// } //func dragItemsForBeginning(in collectionView: UICollectionView...
//
//
//
// func dragEventsCount(of draggedItems: [Draggable] ) -> Int
// {
//  let folders = draggedItems.compactMap{($0.hostedManagedObject as? Photo)?.folder}
//
//  return Set(folders).map { folder  -> Int in
//   switch (folder.count - folder.folderedPhotos.filter{$0.isDragAnimating}.count)
//   {
//    case 0:  return 1
//    case 1:  return 2
//    default: return 0
//   }
//  }.reduce(0, +) + draggedItems.count
//
// }//func dragEventsCount(of draggedItems: [Draggable] ) ...
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
//  let draggedItems = AppDelegate.globalDragItems.filter{ $0.dragSession != nil }//active drags only!
//
//  var count = dragEventsCount(of: draggedItems)
//
//  defer
//  {
//   print ("<<<< Event Count - \(count) >>>>" )
//
////   ddPublish.debug()
////            .elementAt(count - 1)
////            .observeOn(MainScheduler.instance)
////            .subscribe(onNext: {[weak self] _ in self?.repositionItemsIfNeeded(after: 1) })
////            .disposed(by: disposeBag)
//  }
//
//
//  let position = photoItemPosition(for: destinationIndexPath)
//  let photoDragItems = draggedItems.filter{$0 is PhotoItem}
//  let folderDragItems = draggedItems.filter{ $0 is PhotoFolderItem }
//
//  if (photoSnippet.photoGroupType == .typeGroups &&
//      position.sectionName == PhotoItemsTypes.allPhotos.rawValue)
//  {
//   count += folderDragItems.count
//  }//if (photoSnippet.photoGroupType ...
//
//  if (photoDragItems.count > 1 &&
//      photoSnippet.photoGroupType == .typeGroups &&
//      position.sectionName == PhotoItemsTypes.allFolders.rawValue)
//  {
//   count -= photoDragItems.filter{ $0.isFoldered }.count
//   count += 1
//
//   let destPhotoItem = photoDragItems.first as! PhotoItem
//
//   group.performBatchTask(batch: photoDragItems[1...1], asyncTask:
//   {
//    $0.move(to: photoSnippet, to: destPhotoItem, to: nil, completion: $1)
//   })
//   {
//    guard let newFolder = destPhotoItem.folder.map({PhotoFolderItem(folder: $0)}) else { return }
//
//    group.performBatchTask(batch: photoDragItems[2...], asyncTask:
//    {
//     $0.move(to: self.photoSnippet, to: newFolder, to: .zero, completion: $1)
//    })
//    {
//     group.performBatchTask(batch: folderDragItems, asyncTask:
//     {
//      $0.move(to: self.photoSnippet, to: nil, to: position, completion: $1)
//     })
//    }
//   }
//  }//if (photoDragItems.count > 1 &&...
//  else
//  {
//   group.performBatchTask(batch: draggedItems, asyncTask:
//   {
//    $0.move(to: photoSnippet, to: nil, to: position, completion: $1)
//   })
//  }//if (photoDragItems.count > 1 &&...
//
// }//func moveInAppItemsRx(_ collectionView:...
//
// func moveInAppItemsFullyRx(_ collectionView: UICollectionView,
//                              performDropWith coordinator: UICollectionViewDropCoordinator,
//                              to destinationIndexPath: IndexPath)
//
// {
//  print (#function)
//
//  let draggedItems = AppDelegate.globalDragItems.filter{ $0.dragSession != nil }//active drags only!
//
//  var draggedWrappedItems = Set(draggedItems.map{ DraggableWrapper($0) })
//
//  var count = dragEventsCount(of: draggedItems)
//
////  defer {
////   ddPublish
////    .debug(" <<< DRAGGED COUNT PUBLISHER (\(count))>>>")
////    .elementAt(count - 1) // terminates & disposed after receive count of elements!
////    .observeOn(MainScheduler.instance)
////    .subscribe(onNext: { [weak self] _ in self?.repositionItemsIfNeeded(after: 1) })
////    .disposed(by: disposeBag)
////  }
//
//
//  let position = photoItemPosition(for: destinationIndexPath)
//  let photoDragItems = draggedItems.filter{$0 is PhotoItem}
//  let folderDragItems = draggedItems.filter{ $0 is PhotoFolderItem }
//
//
//  if ( photoSnippet.photoGroupType == .typeGroups &&
//       position.sectionName == PhotoItemsTypes.allPhotos.rawValue ) { count += folderDragItems.count }
//
//  if photoDragItems.count > 1 &&
//   photoSnippet.photoGroupType == .typeGroups &&
//   position.sectionName == PhotoItemsTypes.allFolders.rawValue
//  {
//   count -= photoDragItems.filter{ $0.isFoldered }.count
//   count += 1
//
//   let firstPhotoDragged = draggedItems.first{$0 is PhotoItem} as! PhotoItem
//   let secondPhotoDragged = draggedItems.first{$0 is PhotoItem && $0 !== firstPhotoDragged} as! PhotoItem
//
//   var thenObsSeqMake: ( (Set<DraggableWrapper>) -> Observable<Draggable> )!
//
//   thenObsSeqMake = {[unowned self] wrapped -> Observable<Draggable> in
//    let draggedItems = wrapped.map{$0.wrapped}
//    return Observable<Draggable>.from(draggedItems)
//     .filter { $0 !== firstPhotoDragged && $0 !== secondPhotoDragged }
//     .flatMap { dragged -> Observable<Draggable> in
//       switch dragged
//       {
//        case let photoItem as PhotoItem:
//         guard let newFolder = firstPhotoDragged.folder.map({PhotoFolderItem(folder: $0)}) else { return .empty() }
//         return photoItem.move(to: self.photoSnippet, to: newFolder, to: .zero)
//
//        case let photoFolderItem as PhotoFolderItem:
//         return photoFolderItem.move(to: self.photoSnippet, to: nil, to: position)
//
//        default: return .empty()
//       }//switch dragged...
//     }//.flatMap...
//     .observeOn(MainScheduler.instance)
//     .do(onNext: { draggedWrappedItems.remove(DraggableWrapper($0)) })
//     .catchError { error -> Observable<Draggable> in
//      if case let DraggableError.moveError(dragged, contextError) = error
//      {
//       draggedWrappedItems.remove(DraggableWrapper(dragged))
//       contextError.log()
//       return thenObsSeqMake(draggedWrappedItems)
//      }
//      else
//      {
//       return .empty()
//      }
//    }
//   }
//
//   secondPhotoDragged.move(to: self.photoSnippet, to: firstPhotoDragged, to: nil)
//    .catchError{ _ in .empty() }
//    .ignoreElements()
//    .andThen(thenObsSeqMake(draggedWrappedItems))
//    .observeOn(MainScheduler.instance)
//    .debug("<<< DROP ITEMS WITH FOLDERING PUBLISHER >>>")
//    .subscribe()
//    .disposed(by: disposeBag)
//
//  }
//  else
//  {
//   var dragObsSeqMake: ( (Set<DraggableWrapper>) -> Observable<Draggable> )!
//   dragObsSeqMake = {[unowned self]  wrapped -> Observable<Draggable> in
//    let draggedItems = wrapped.map{$0.wrapped}
//    return Observable<Draggable>.from(draggedItems)
//     .flatMap { $0.move(to: self.photoSnippet, to: nil, to: position) }
//     .observeOn(MainScheduler.instance)
//     .do(onNext: { draggedWrappedItems.remove(DraggableWrapper($0)) })
//     .catchError {error -> Observable<Draggable> in
//      if case let DraggableError.moveError(dragged, contextError) = error
//      {
//       draggedWrappedItems.remove(DraggableWrapper(dragged))
//       contextError.log()
//       return dragObsSeqMake(draggedWrappedItems)
//      }
//      else
//      {
//       return .empty()
//      }
//    }
//   }
//
//   dragObsSeqMake(draggedWrappedItems)
//    .observeOn(MainScheduler.instance)
//    .debug("<<< DROP ITEMS PUBLISHER >>>")
//    .subscribe()
//    .disposed(by: disposeBag)
//
//  }//if photoDragItems.count > 1 &&...
//
// }//func moveInAppItemsFullyRx(_ collectionView:...
//
//
// func performDrop(in collectionView: UICollectionView, with coordinator: UICollectionViewDropCoordinator)
// {
//  print (#function, coordinator.session)
//
//  //ddDelegateSubject.onNext(.drop)
// // isDropPerformed = true
//
//  let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath.zero
//
//  switch (coordinator.proposal.operation)
//  {
//   case .move: // moveInAppItemsRx      (collectionView, performDropWith: coordinator, to: destinationIndexPath)
//    moveInAppItemsFullyRx (collectionView, performDropWith: coordinator, to: destinationIndexPath)
//   case .copy: break
//    //copyPhotosFromSideApp (collectionView, performDropWith: coordinator, at: destinationIndexPath)
//   default: break
//  }
//
// }//func performDrop(in collectionView: UICollectionView...
//
//
//
//}




