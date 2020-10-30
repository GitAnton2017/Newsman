//
//  Folder Nested CV D & D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 04.07.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import RxSwift

final class FolderNestedCollectionViewDragAndDropDelegate: CollectionViewDragAndDropBaseDelegate
{
 final weak var folderCell: PhotoFolderCell?
 final var photoSnippet: PhotoSnippet? { snippet as? PhotoSnippet }
 
 init?(folderCell: PhotoFolderCell)
 {
  self.folderCell = folderCell
  
  guard let photoSnippetVC = folderCell.photoSnippetVC else { return nil }
  guard let photoSnippet = photoSnippetVC.photoSnippet else { return nil }
  
  super.init(snippet: photoSnippet, snippetViewController: photoSnippetVC)
  
 }
 
 final override var isContentDraggable: Bool { folderCell?.isContentDraggable ?? false }
 
 final override func isDragOverlayedByArrowMenu (_ collectionView: UICollectionView,
                                                 forCellAt indexPath: IndexPath) -> Bool
 {
  guard
   let dragCell = collectionView.cellForItem(at: indexPath) as? PhotoFolderCollectionViewCell,
   let visibleCells = collectionView.visibleCells as? [PhotoFolderCollectionViewCell],
   let menuView = (visibleCells.first{$0.arrowMenuView != nil}?.arrowMenuView?.baseView)
  else { return false }

  let menuRect = collectionView.convert(menuView.bounds, from: menuView)

  return dragCell.frame.intersects(menuRect)
 }
 
 final override func collectionView(_ collectionView: UICollectionView,
                                    dropSessionDidUpdate session: UIDropSession,
                                    withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
 {
  ddDelegateSubject.onNext(.proceed(location: session.location(in: collectionView)))
  
  guard isContentDraggable else { return .init(operation: .forbidden, intent: .unspecified) }
  
  switch (session.localDragSession, session.items.count, session.items.first?.localObject)
  {
   case (_?,  1, is PhotoFolderItem):
    return UICollectionViewDropProposal(operation: .forbidden  , intent: .insertAtDestinationIndexPath)
   case (_?,  1, is PhotoItem):
    return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
   case (_?, let k, _) where k > 1:
    return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
   case (nil, _, _):
    return UICollectionViewDropProposal(operation: .forbidden, intent: .insertAtDestinationIndexPath)
   default:
    return UICollectionViewDropProposal(operation: .cancel, intent: .unspecified)
  }
  
 }
 
 final override func draggedItem(at indexPath: IndexPath) -> Draggable?
 {
  guard let photoItems = folderCell?.photoItems else { return nil }
  guard indexPath.row < photoItems.count else { return nil }
  return photoItems[indexPath.row]
 }
 
 final override func performDrop(in collectionView: UICollectionView,
                                 with coordinator: UICollectionViewDropCoordinator) -> Int
 {
  print (#function, coordinator.session)
  
  let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath.zero
  
  switch (coordinator.proposal.operation)
  {
   case .move: return moveInAppItems (into: destinationIndexPath)
   
   default: return 0
  }
 }//func performDrop(in collectionView...
 
 final private func moveInAppItems(into destinationIndexPath: IndexPath) -> Int
 {
  print ("\(#function), DELEGATE: [\(self)] AT INDEX PATH: [\(destinationIndexPath)]")
  
  let draggedItems = self.draggedItems
  
  if draggedItems.isEmpty { return 0 }
  
  guard let photoSnippet = self.photoSnippet else { return 0 }
  guard let folderCell = self.folderCell else { return 0 }
  
  guard let folderItem = folderCell.hostedItem else { return 0 }
  
  var draggedWrappedItems = Set(draggedItems.map{ DraggableWrapper($0) })
  let position = folderCell.photoItemPosition(for: destinationIndexPath)
  
  var dragObsSeqMake: ( (Set<DraggableWrapper>) -> Observable<Draggable> )!
  
  dragObsSeqMake = {[weak photoSnippet] wrapped -> Observable<Draggable> in
   guard let photoSnippet = photoSnippet else { return .empty() }
    return Observable<DraggableWrapper>.from(wrapped)
    .map { $0.wrapped }
    .flatMap { $0.move(to: photoSnippet, to: folderItem, to: position) }
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
   .debug("<<< NESTED FOLDER CV DROP ITEMS PUBLISHER >>>")
   .subscribe()
   .disposed(by: disposeBag)
  
  
  return dragEventsCount
  
 }//func moveInAppItemsRx(_ collectionView:...

}
