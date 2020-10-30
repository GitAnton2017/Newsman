//
//  Main CV D & D Delegate.swift
//  Newsman
//
//  Created by Anton2016 on 25.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import RxSwift

final class PhotoSnippetCollectionViewDragAndDropDelegate: CollectionViewDragAndDropBaseDelegate
{
 init(photoSnippet: PhotoSnippet, viewController: PhotoSnippetViewController)
 {
  super.init(snippet: photoSnippet, snippetViewController: viewController)
//  self.completion = { [weak self] in
//   //self?.photoSnippetVC?.repositionItemsIfNeeded(after: 1)
//  }
 }
 
 final override var isContentDraggable: Bool { photoSnippetVC?.isContentDraggable ?? false }
 
 final var photoSnippetVC: PhotoSnippetViewController? { snippetViewController as? PhotoSnippetViewController }
 final var photoSnippet: PhotoSnippet? { snippet as? PhotoSnippet }
 
 final override func draggedItem(at indexPath: IndexPath) -> Draggable?
 {
  guard let photoItems = photoSnippetVC?.photoItems2D else { return nil }
  guard indexPath.section < photoItems.count else { return nil }
  guard indexPath.row < photoItems[indexPath.section].count else { return nil }
  return photoItems[indexPath.section][indexPath.row]
 }
 
 

 final override func isDragOverlayedByArrowMenu (_ collectionView: UICollectionView,
                                                  forCellAt indexPath: IndexPath) -> Bool
 {
  guard
   let dragCell = collectionView.cellForItem(at: indexPath) as? PhotoSnippetCellProtocol,
   let visibleCells = collectionView.visibleCells as? [PhotoSnippetCellProtocol],
   let menuView = visibleCells.first(where: {$0.arrowMenuView != nil})?.arrowMenuView?.baseView
  else { return false }
  
  let menuRect = collectionView.convert(menuView.bounds, from: menuView)
  
  return dragCell.frame.intersects(menuRect)
 }
 
 final override var dragEventsCount: Int
 {
  if draggedItems.isEmpty { return 0 }
  
  let folders = draggedItems.compactMap{ ($0.hostedManagedObject as? Photo)?.folder }
  
  return Set(folders).map { folder  -> Int in
   switch (folder.count - folder.folderedPhotos.filter{$0.isDragAnimating}.count)
   {
    case 0:  return 1
    case 1:  return 2
    default: return 0
   }
  }.reduce(0, +) + draggedItems.count
  
 }//func dragEventsCount(of draggedItems: [Draggable] ) ...
 
 private final func moveInAppItems(into destinationIndexPath: IndexPath) -> Int
 {
  print ("\(#function), DELEGATE: [\(self)] AT INDEX PATH: [\(destinationIndexPath)]")
  
  var count = self.dragEventsCount
  
  guard count > 0 else { return 0 }
  
  guard let photoSnippetVC = self.photoSnippetVC else { return 0 }
  guard let photoSnippet = self.photoSnippet else { return 0 }
  
  let draggedItems = self.draggedItems
  var draggedWrappedItems = Set(draggedItems.map{ DraggableWrapper($0) })
  
  let position = photoSnippetVC.photoItemPosition(for: destinationIndexPath)
  let photoDragItems = draggedItems.filter { $0 is PhotoItem }
  let folderDragItems = draggedItems.filter { $0 is PhotoFolderItem }
  
  if ( photoSnippet.photoGroupType == .typeGroups &&
   position.sectionName == PhotoItemsTypes.allPhotos.rawValue ) { count += folderDragItems.count }
  
  if photoDragItems.count > 1 && photoSnippet.photoGroupType == .typeGroups &&
   position.sectionName == PhotoItemsTypes.allFolders.rawValue
  {
   count -= photoDragItems.filter{ $0.isFoldered }.count
   count += 1
   
   let firstPhotoDragged = draggedItems.first{$0 is PhotoItem} as! PhotoItem
   let secondPhotoDragged = draggedItems.first{$0 is PhotoItem && $0 !== firstPhotoDragged} as! PhotoItem
   
   var thenObsSeqMake: ( (Set<DraggableWrapper>) -> Observable<Draggable> )!
   
   thenObsSeqMake = {[weak photoSnippet] wrapped -> Observable<Draggable> in
    guard let photoSnippet = photoSnippet else { return .empty() }
    let draggedItems = wrapped.map{ $0.wrapped }
    return Observable<Draggable>.from(draggedItems)
     .filter { $0 !== firstPhotoDragged && $0 !== secondPhotoDragged }
     .flatMap { dragged -> Observable<Draggable> in
      switch dragged
      {
       case let photoItem as PhotoItem:
        guard let newFolder = firstPhotoDragged.folder.map({PhotoFolderItem(folder: $0)}) else { return .empty() }
        return photoItem.move(to: photoSnippet, to: newFolder, to: .zero)
       
       case let photoFolderItem as PhotoFolderItem:
        return photoFolderItem.move(to: photoSnippet, to: nil, to: position)
       
       default: return .empty()
      }//switch dragged...
    }//.flatMap...
     .observeOn(MainScheduler.instance)
     .do(onNext: { draggedWrappedItems.remove(DraggableWrapper($0)) })
     .catchError { error -> Observable<Draggable> in
      if case let DraggableError.moveError(dragged, contextError) = error
      {
       draggedWrappedItems.remove(DraggableWrapper(dragged))
       contextError.log()
       return thenObsSeqMake(draggedWrappedItems)
      }
      else
      {
       return .empty()
      }
    }
   }
   
   secondPhotoDragged.move(to: photoSnippet, to: firstPhotoDragged, to: nil)
    .catchError{ _ in .empty() }
    .ignoreElements()
    .andThen(thenObsSeqMake(draggedWrappedItems))
    .observeOn(MainScheduler.instance)
    .debug("<<< DROP ITEMS WITH FOLDERING PUBLISHER >>>")
    .subscribe()
    .disposed(by: disposeBag)
   
  }
  else
  {
   var dragObsSeqMake: ( (Set<DraggableWrapper>) -> Observable<Draggable> )!
   dragObsSeqMake = { [weak photoSnippet] wrapped -> Observable<Draggable> in
    guard let photoSnippet = photoSnippet else { return .empty() }
    let draggedItems = wrapped.map{ $0.wrapped }
    return Observable<Draggable>.from(draggedItems)
     .flatMap { $0.move(to: photoSnippet, to: nil, to: position) }
     .observeOn(MainScheduler.instance)
     .do(onNext: { draggedWrappedItems.remove(DraggableWrapper($0)) })
     .catchError {error -> Observable<Draggable> in
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
    .debug("<<< DROP ITEMS PUBLISHER >>>")
    .subscribe()
    .disposed(by: disposeBag)
  
  }//if photoDragItems.count > 1 &&...
  
  return count
  
 }//func moveInAppItemsFullyRx(_ collectionView:...
 
 
 private static let cellID = "PhotoSnippetCell"
 
 private final func copyPhotosFromSideApp (_ collectionView: UICollectionView,
                                           performDropWith coordinator: UICollectionViewDropCoordinator,
                                           at destinationIndexPath: IndexPath) -> Int
  
 {
  
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(coordinator.session.description)]")
  
  guard let photoSnippetVC = self.photoSnippetVC else { return 0 }
  guard let photoSnippet = self.photoSnippet else { return 0 }
  
  for item in coordinator.items
  {
   let dragItem = item.dragItem
   guard dragItem.itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
   
   let placeholder = UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
                                                     reuseIdentifier: Self.cellID)
   
   let placeholderContext = coordinator.drop(dragItem, to: placeholder)
   dragItem.itemProvider.loadObject(ofClass: UIImage.self)
   { [weak photoSnippetVC, weak photoSnippet] item, error in
    OperationQueue.main.addOperation
    {
     guard error == nil else { placeholderContext.deletePlaceholder(); return  }
     guard let image = item as? UIImage else { placeholderContext.deletePlaceholder(); return }
     guard let photoSnippet = photoSnippet else { placeholderContext.deletePlaceholder(); return }
     guard let photoSnippetVC = photoSnippetVC else { placeholderContext.deletePlaceholder(); return }
     
     placeholderContext.commitInsertion { indexPath in
      let newPhotoItem = PhotoItem(photoSnippet: photoSnippet,
                                   image: image,
                                   cachedImageWidth: photoSnippetVC.imageSize)
      
      if let flagStrs = photoSnippetVC.sectionTitles
      {
       newPhotoItem.photo.priorityFlag = flagStrs[indexPath.section]
      }
      
      photoSnippetVC.photoItems2D[indexPath.section].insert(newPhotoItem, at: indexPath.row)
  
    }
    }
   }
  }
  return coordinator.items.count
 }//func copyPhotosFromSideApp (_ collectionView: UICollectionView...
 
 final override func performDrop(in collectionView: UICollectionView,
                                 with coordinator: UICollectionViewDropCoordinator) -> Int
 {
  let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath.zero
  
  switch (coordinator.proposal.operation)
  {
   case .move: return moveInAppItems (into: destinationIndexPath)
   case .copy: return copyPhotosFromSideApp (collectionView, performDropWith: coordinator, at: destinationIndexPath)
   default: return 0
  }
 }
 
}
