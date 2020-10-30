//
//  Zoom View CV D & D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 27.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import RxSwift

final class ZoomViewCollectionViewDragAndDropDelegate: CollectionViewDragAndDropBaseDelegate
{

 final weak var zoomView: ZoomView?
 
 final var photoSnippet: PhotoSnippet? { snippet as? PhotoSnippet }
 final var zoomedPhotoItem: Draggable? { zoomView?.zoomedPhotoItem }
 final var photoSnippetVC: PhotoSnippetViewController? { zoomView?.photoSnippetVC }
 final var photoSnippetCV: PhotoSnippetCollectionView? { photoSnippetVC?.photoCollectionView }
 final var zoomedCellIndexPath: IndexPath? { zoomView?.zoomedCellIndexPath }
 
 final var zoomedFolderCell: PhotoFolderCell?
 {
  guard let zoomedCellIndexPath = self.zoomedCellIndexPath else { return nil }
  return photoSnippetCV?.cellForItem(at: zoomedCellIndexPath) as? PhotoFolderCell
 }
 
 final override func draggedItem(at indexPath: IndexPath) -> Draggable?
 {
  guard let photoItems = zoomView?.photoItems else { return nil }
  guard indexPath.row < photoItems.count else { return nil }
  return photoItems[indexPath.row]
 }
 
 
 init?(zoomView: ZoomView)
 {
  self.zoomView = zoomView
  
  guard let photoSnippetVC = zoomView.photoSnippetVC else { return nil }
  guard let photoSnippet = photoSnippetVC.photoSnippet else { return nil }
  
  super.init(snippet: photoSnippet, snippetViewController: photoSnippetVC)
  
  self.completion = { [weak self] in
   self?.zoomView?.repositionItemsIfNeeded(after: 1)
   self?.zoomedFolderCell?.repositionItemsIfNeeded(after: 1)
  }
 
 
 }
 
 final override func isDragOverlayedByArrowMenu (_ collectionView: UICollectionView,
                                                   forCellAt indexPath: IndexPath) -> Bool
 {
  guard
   let dragCell = collectionView.cellForItem(at: indexPath) as? ZoomViewCollectionViewCell,
   let visibleCells = collectionView.visibleCells as? [ZoomViewCollectionViewCell],
   let menuView = visibleCells.first(where: {$0.arrowMenuView != nil})?.arrowMenuView?.baseView
  else { return false }
  
  let menuRect = collectionView.convert(menuView.bounds, from: menuView)
  
  return dragCell.frame.intersects(menuRect)
 }
 
 final override func collectionView(_ collectionView: UICollectionView,
                                    dropSessionDidUpdate session: UIDropSession,
                                    withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
 {
  ddDelegateSubject.onNext(.proceed(location: session.location(in: collectionView)))
  
  switch (session.localDragSession, session.items.count, session.items.first?.localObject)
  {
   case (_?,  1, let dragged as PhotoFolderItem):
    let op: UIDropOperation = dragged.isDragAnimating && dragged.isZoomed ? .forbidden : .move
    return UICollectionViewDropProposal(operation: op , intent: .insertAtDestinationIndexPath)
   case (_?,  1, is PhotoItem):
    return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
   case (_?, let k, _) where k > 1:
    return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
   case (nil, _, _):
    return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
   default:
    return UICollectionViewDropProposal(operation: .cancel, intent: .unspecified)
  }
  
 }
 
 private static let cellID = "ZoomCollectionViewCell"
 
 final private func copyPhotosFromSideApp (_ collectionView: UICollectionView,
                                             performDropWith coordinator: UICollectionViewDropCoordinator,
                                             at destinationIndexPath: IndexPath) -> Int

 {
  print(#function)
  
  guard let photoSnippet = self.photoSnippet else { return 0 }
  guard let zoomView = self.zoomView else { return 0 }
  
  for item in coordinator.items
  {
   let dragItem = item.dragItem
   guard dragItem.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
   let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
                                                     reuseIdentifier: Self.cellID)
   
   let placeholderContext = coordinator.drop(dragItem, to: placeholder)
   dragItem.itemProvider.loadObject(ofClass: UIImage.self)
   {[weak photoSnippet, weak zoomView, weak self] item, error in
    OperationQueue.main.addOperation
    {
     guard let self = self else { placeholderContext.deletePlaceholder(); return  }
     guard error == nil else { placeholderContext.deletePlaceholder(); return  }
     guard let image = item as? UIImage else { placeholderContext.deletePlaceholder(); return }
     guard let photoSnippet = photoSnippet else { placeholderContext.deletePlaceholder(); return }
     guard let zoomView = zoomView else { placeholderContext.deletePlaceholder(); return }
     placeholderContext.commitInsertion { indexPath in
      let newPhotoItem = PhotoItem(photoSnippet: photoSnippet,
                                   image: image,
                                   cachedImageWidth: zoomView.imageSize)
      
      self.zoomedFolderCell?.photoItems.insert(newPhotoItem, at: indexPath.row)
      self.zoomedFolderCell?.photoCollectionView.insertItems(at: [indexPath])
      zoomView.photoItems.insert(newPhotoItem, at: indexPath.row)
     }
    }
   }
  }
  return coordinator.items.count
 }
  
  
 final override func performDrop(in collectionView: UICollectionView,
                                 with coordinator: UICollectionViewDropCoordinator) -> Int
 {
  print (#function, coordinator.session)
  
  let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath.zero
  
  switch (coordinator.proposal.operation)
  {
   case .move:
    return moveInAppItems (into: destinationIndexPath)
   
   case .copy:
    return copyPhotosFromSideApp (collectionView, performDropWith: coordinator, at: destinationIndexPath)
   
   default: return 0
  }
 }//func performDrop(in collectionView...
 
 final private func moveInAppItems(into destinationIndexPath: IndexPath) -> Int
 {
  print ("\(#function), DELEGATE: [\(self)] AT INDEX PATH: [\(destinationIndexPath)]")
  
  let draggedItems = self.draggedItems
  
  if draggedItems.isEmpty { return 0 }
  
  guard let photoSnippet = self.photoSnippet else { return 0 }
  guard let zoomView = self.zoomView else { return 0 }
  
  guard let zoomedPhotoItem = self.zoomedPhotoItem as? PhotoFolderItem else { return 0 }
  
  var draggedWrappedItems = Set(draggedItems.map{ DraggableWrapper($0) })
  let position = zoomView.photoItemPosition(for: destinationIndexPath)
  
  var dragObsSeqMake: ( (Set<DraggableWrapper>) -> Observable<Draggable> )!
  
  dragObsSeqMake = {[weak photoSnippet] wrapped -> Observable<Draggable> in
   guard let photoSnippet = photoSnippet else { return .empty() }
    return Observable<DraggableWrapper>.from(wrapped)
    .map { $0.wrapped }
    .flatMap { $0.move(to: photoSnippet, to: zoomedPhotoItem, to: position) }
    .observeOn(MainScheduler.instance)
    .do(onNext: { draggedWrappedItems.remove(DraggableWrapper($0)) })
    .catchError { error -> Observable<Draggable> in
     if case let DraggableError.moveError(dragged, contextError) = error
     {
      draggedWrappedItems.remove(DraggableWrapper(dragged))
      contextError.log()
      return dragObsSeqMake(draggedWrappedItems)
     }
     else
     {
      return .empty()
     }
   }
  }
  
  dragObsSeqMake(draggedWrappedItems)
   .observeOn(MainScheduler.instance)
   .debug("<<< ZOOM VIEW DROP ITEMS PUBLISHER >>>")
   .subscribe()
   .disposed(by: disposeBag)
  
  
  return dragEventsCount
  
 }//func moveInAppItemsRx(_ collectionView:...

 
 
 
}
