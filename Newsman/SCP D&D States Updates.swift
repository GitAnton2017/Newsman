//
//  SCP D&D States Updates.swift
//  Newsman
//
//  Created by Anton2016 on 29.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import CoreData
import Combine

protocol PhotoItemsStateSubscriptionCancellable
{
 var cancellablePhotoItems: [PhotoItemProtocol] { get }
}

extension PhotoItemsStateSubscriptionCancellable
{
 func cancellAllStateSubscriptions()
 {
  cancellablePhotoItems.forEach{ $0.cancellAllStateSubscriptions() }
 }
}

extension PhotoSnippetViewController: PhotoItemsStateSubscriptionCancellable
{
 var cancellablePhotoItems: [PhotoItemProtocol] { photoItems2D.flatMap{$0} }
}

extension PhotoItemProtocol
{
 private func cancellAllStateSubscriptionsBase()
 {
  cellDragLocationSubscription?.cancel()
  cellDragProceedSubscription?.cancel()
  cellDropProceedSubscription?.cancel()
  cellRowPositionChangeSubscription?.cancel()
  cellPriorityFlagChangeSubscription?.cancel()
 }
 
 var rowPositionsPublisher: AnyPublisher<[ String : Int ], Never>
 {
  photoManagedObject.rowPositionsPublisher
 }
 
 var groupTypePublisher: AnyPublisher<String, Never>
 {
  photoManagedObject.groupTypePublisher
 }
 
 var priorityFlagColorPublisher: AnyPublisher<UIColor, Never>
 {
  photoManagedObject.priorityFlagColorPublisher
 }
 
 var hostingCellPublisher: AnyPublisher<PhotoSnippetCellProtocol, Never>
 {
  hostingCollectionViewCellPublisher.compactMap{ $0 }.eraseToAnyPublisher()
 }
 
 private func configueAllStateSubscriptionsBase()
 {
  configuePriorityFlagSubscriptionBase()
  configueCellRowPositionSubscriptionBase()
 }
 
 
 private func configueCellRowPositionSubscriptionBase()
 {
  cellRowPositionChangeSubscription = Publishers
   .CombineLatest3(hostingCellPublisher, rowPositionsPublisher, groupTypePublisher)
   .sink {[ weak self ] cell, positions, grouping in
      guard let self = self else { return }
      guard self.hostedManagedObject.faultingState == 0 else { return }
      guard self.hostedManagedObject.isFault == false else { return }
      guard let hostedItem = cell.hostedItem else { return }
      guard hostedItem === self else { return }
      guard let tag = (cell.mainView as? PhotoSnippetCellMainView)?.rowPositionTag else { return }
     
      switch self.hostedManagedObject
      {
       case let photo as Photo where photo.isFoldered:
         tag.cardinal = positions[GroupPhotos.manually.rawValue]
       
       default: tag.cardinal = positions[grouping]
      }
      

    }
  

 }//func configueCellRowPositionSubscription()...
 
 private func configuePriorityFlagSubscriptionBase()
 {
  cellPriorityFlagChangeSubscription = Publishers
   .CombineLatest(hostingCellPublisher, priorityFlagColorPublisher)
   .sink {[ weak self ] cell, color in
     guard let self = self else { return }
     guard self.hostedManagedObject.faultingState == 0 else { return }
     guard self.hostedManagedObject.isFault == false else { return }
     guard let hostedItem = cell.hostedItem else { return }
     guard hostedItem === self else { return }
     guard let flagMarker = (cell.mainView as? PhotoSnippetCellMainView)?.priorityFlagMarker else { return }
     flagMarker.markerColor = color
  
   }
  

 }//func configueCellRowPositionSubscription()...
 

}

extension PhotoItemProtocol where Self: PhotoItem
{
 func configueAllStateSubscriptions()
 {
  configueCellRowPositionSubscription()
  configuePriorityFlagSubscription()
 }
 
 func cancellAllStateSubscriptions()
 {
  cancellAllStateSubscriptionsBase()
  cellNewItemStateSubscription?.cancel()
  zoomedCellDragProceedSubscription?.cancel()
  zoomedCellDropProceedSubscription?.cancel()
  zoomedCellDragLocationSubscription?.cancel()
  zoomedCellRowPositionChangeSubscription?.cancel()
  zoomedCellPriorityFlagChangeSubscription?.cancel()
  
 }
 
 
 var hostingZoomedCellPublisher: AnyPublisher<ZoomViewCollectionViewCell, Never>
 {
  $hostingZoomedCollectionViewCell.compactMap{$0}.eraseToAnyPublisher()
 }
 
 
 private func configueZoomedCellPriorityFlagSubscription()
 {
  guard photo.isFoldered else { return }
  zoomedCellPriorityFlagChangeSubscription = Publishers
  .CombineLatest(hostingZoomedCellPublisher, priorityFlagColorPublisher)
  //.subscribe(on: DispatchQueue.global(qos: .userInteractive))
  .receive(on: DispatchQueue.main)
  .sink {[ weak self ] cell, color in
     guard let self = self else { return }
     guard self.photo.isFault == false else { return }
     guard let hostedItem = cell.hostedItem as? PhotoItem else { return }
     guard hostedItem === self else { return }
     guard let flagMarker = (cell.mainView as? PhotoSnippetCellMainView)?.priorityFlagMarker else { return }
     flagMarker.markerColor = color
  
   }
 }
 
 func configuePriorityFlagSubscription()
 {
  configuePriorityFlagSubscriptionBase()
  configueZoomedCellPriorityFlagSubscription()
 }
 
 private func configueZoomedCellRowPositionSubscription()
 {
  guard photo.isFoldered else { return }
  zoomedCellRowPositionChangeSubscription = Publishers
  .CombineLatest(hostingZoomedCellPublisher, rowPositionsPublisher)
  //.subscribe(on: DispatchQueue.global(qos: .userInteractive))
  .receive(on: DispatchQueue.main)
  .sink {[ weak self ] cell, positions in
     guard let self = self else { return }
     guard let hostedItem = cell.hostedItem else { return }
     guard hostedItem === self else { return }
     guard let tag = (cell.mainView as? PhotoSnippetCellMainView)?.rowPositionTag else { return }
     tag.cardinal = positions[GroupPhotos.manually.rawValue]
  
   }
 }
 
 func configueCellRowPositionSubscription()
 {
  configueCellRowPositionSubscriptionBase()
  configueZoomedCellRowPositionSubscription()

 }//func configueCellRowPositionSubscription()...
 
}

extension PhotoItemProtocol where Self: PhotoFolderItem
{
 func configueAllStateSubscriptions()
 {
  configueAllStateSubscriptionsBase()
 }
 
 func cancellAllStateSubscriptions()
 {
  cancellAllStateSubscriptionsBase()
 }
 
}


extension PhotoSnippetCellProtocol 
{
 
 func updateAllCellStatesSubscriptions()
 {
  updateCellNewItemState()
  updateCellDragAndDropStates()
 }
 

 func updateCellNewItemState()
 {
  guard let photoItem = hostedItem as? PhotoItem else { return }
  guard let mainView = mainView as? PhotoSnippetCellMainView else { return }
  
  if photoItem.isFoldered
  {
   mainView.isNewPhotoAnimated = false
   return
  }
  
  //mainView.isNewPhotoAnimated = photoItem.isJustCreated
 
  photoItem.cellNewItemStateSubscription = photoItem.photo
   .publisher(for: \.isJustCreated, options: [.initial]) //.print("SINGLE PHOTO CELL DROP STATE FRAME [\(self)]")
   .subscribe(on: DispatchQueue.global())
   .receive(on: DispatchQueue.main)
   .sink { [weak self, weak photoItem] state in
    guard let self = self else { return }
    guard let hostedItem = self.hostedItem as? PhotoItem else { return }
    guard hostedItem === photoItem else { return }
    guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
    mainView.isNewPhotoAnimated = state
  }
 }
 

 
 func updateCellDragAndDropStates()
 {
//  print (#function, self.frame)
  
  guard let photoItem = hostedItem as? PhotoItem else { return }
  
  photoItem.cellDropProceedSubscription = photoItem.photo
   .publisher(for: \.isDropProceeding, options: [.initial]) //.print("SINGLE PHOTO CELL DROP STATE FRAME [\(self)]")
//   .subscribe(on: DispatchQueue.global())
//   .receive(on: DispatchQueue.main)
   .sink { [weak self, weak photoItem] state in
    guard let self = self else { return }
    guard let hostedItem  = self.hostedItem as? PhotoItem else { return }
    guard hostedItem === photoItem else { return }
    guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
    mainView.isFramed = state
   }
  
//
  photoItem.cellDragProceedSubscription = photoItem.photo
   .publisher(for: \.isDragProceeding, options: [.initial])//.print("SINGLE PHOTO CELL DRAG MOVE STATE[\(self)]")
//   .subscribe(on: DispatchQueue.global())
//   .receive(on: DispatchQueue.main)
   .sink { [weak self, weak photoItem] state in
     guard let self = self else { return }
     guard let hostedItem  = self.hostedItem as? PhotoItem else { return }
     guard hostedItem === photoItem else { return }
     guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
     mainView.isDragMoving = state
   }
  
  photoItem.cellDragLocationSubscription = photoItem.photo
   .publisher(for: \.dragProceedLocation, options: [.prior]).collect(2).dropFirst()
   .compactMap { [ weak self ] in self?.center.rotation(from: $0[0], to: $0[1]) }
//   .subscribe(on: DispatchQueue.global())
//   .receive(on: DispatchQueue.main)
   .sink{ [ weak self, weak photoItem ] angle in   //print ("FINAL ROTATION >>>>> : \(angle * 180 / .pi)")
     guard let self = self else { return }
     guard let hostedItem  = self.hostedItem as? PhotoItem else { return }
     guard hostedItem === photoItem else { return }
     guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
     UIView.animate(withDuration: 0.25) {
      mainView.arrowsRotateView.transform = mainView.arrowsRotateView.transform.rotated(by: angle)
     }
     //print ("ACCUMULATED ROTATION ANGLE - \(acos(mainView.arrowsRotateView.transform.a) * 180 / .pi)")
   }
 }

}


extension PhotoSnippetCellProtocol where Self: PhotoFolderCell
{
 func updateAllCellStatesSubscriptions()
 {
  updateCellDragAndDropStates()
 }
 
 
 func updateCellDragAndDropStates()
 {
  guard let photoFolderItem = hostedItem as? PhotoFolderItem else { return }
 
  photoFolderItem.cellDropProceedSubscription = photoFolderItem.folder
   .publisher(for: \.isDropProceeding, options: [.initial]) //.print("FOLDER CELL DROP STATE FRAME [\(self)]")
//   .subscribe(on: DispatchQueue.global())
//   .receive(on: DispatchQueue.main)
   .sink { [weak self, weak photoFolderItem] state in
     guard let self = self else { return }
     guard let hostedFolderItem  = self.hostedItem as? PhotoFolderItem else { return }
     guard hostedFolderItem === photoFolderItem else { return }
     guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
     mainView.isFramed = state
   }
  
  photoFolderItem.cellDragProceedSubscription = photoFolderItem.folder
   .publisher(for: \.isDragProceeding, options: [.initial]) //.print("FOLDER CELL DRAG MOVE STATE[\(self)]")
//   .subscribe(on: DispatchQueue.global())
//   .receive(on: DispatchQueue.main)
   .sink { [weak self, weak photoFolderItem] state in
    guard let self = self else { return }
    guard let hostedFolderItem  = self.hostedItem as? PhotoFolderItem else { return }
    guard hostedFolderItem === photoFolderItem else { return }
    guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
    mainView.isDragMoving = state
  }
  
  photoFolderItem.cellDragLocationSubscription = photoFolderItem.folder
   .publisher(for: \.dragProceedLocation, options: [.prior]).collect(2).dropFirst()
   .compactMap { [ weak self, weak photoFolderItem] points -> CGFloat? in
     guard let self = self else { return nil }
     guard let hostedFolderItem = self.hostedItem as? PhotoFolderItem else { return nil }
     guard hostedFolderItem === photoFolderItem else { return nil }
     self.folderedItemsCells.forEach { cell in
      guard let mainView = cell.mainView as? PhotoSnippetCellMainView else { return }
      guard let mainCV = self.superview as? PhotoSnippetCollectionView else { return }
      guard let center = self.photoCollectionView?.convert(cell.center, to: mainCV) else { return }
      guard let angle = center.rotation(from: points[0], to: points[1]) else { return }
      UIView.animate(withDuration: 0.10) {
        mainView.arrowsRotateView.transform = mainView.arrowsRotateView.transform.rotated(by: angle)
      }
     }
     
     return self.center.rotation(from: points[0], to: points[1])
   }
//   .subscribe(on: DispatchQueue.global())
//   .receive(on: DispatchQueue.main)
   .sink { [ weak self, weak photoFolderItem ] angle in
     guard let self = self else { return }
     guard let hostedFolderItem = self.hostedItem as? PhotoFolderItem else { return }
     guard hostedFolderItem === photoFolderItem else { return }
     guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
     UIView.animate(withDuration: 0.25) {
       mainView.arrowsRotateView.transform = mainView.arrowsRotateView.transform.rotated(by: angle)
     }
   }
    
 }

}

extension PhotoSnippetCellProtocol where Self: ZoomViewCollectionViewCell
{
 
 func updateAllCellStatesSubscriptions()
 {
  updateCellDragAndDropStates()
  (hostedItem as? PhotoItem)?.configueAllStateSubscriptions()
 }
 
 
 func updateCellDragAndDropStates()
 {
  guard let photoItem = hostedItem as? PhotoItem else { return }
 
  photoItem.zoomedCellDropProceedSubscription = photoItem.photo
   .publisher(for: \.isDropProceeding, options: [.initial]) //.print("ZOOM VIEW CELL DROP STATE FRAME [\(self)]")
//   .subscribe(on: DispatchQueue.global())
//   .receive(on: DispatchQueue.main)
   .sink { [weak self, weak photoItem] state in
    guard let self = self else { return }
    guard let hostedItem  = self.hostedItem as? PhotoItem else { return }
    guard hostedItem === photoItem else { return }
    guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
    mainView.isFramed = state
  }
  
  photoItem.zoomedCellDragProceedSubscription = photoItem.photo
   .publisher(for: \.isDragProceeding, options: [.initial]) //.print("ZOOM VIEW CELL DRAG MOVE STATE[\(self)]")
//   .subscribe(on: DispatchQueue.global())
//   .receive(on: DispatchQueue.main)
   .sink { [weak self, weak photoItem] state in
    guard let self = self else { return }
    guard let hostedItem  = self.hostedItem as? PhotoItem else { return }
    guard hostedItem === photoItem else { return }
    guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
    mainView.isDragMoving = state
  }
  
  photoItem.zoomedCellDragLocationSubscription = photoItem.photo
  .publisher(for: \.dragProceedLocation, options: [.prior]).collect(2).dropFirst()
  .compactMap { [ weak self ] in self?.center.rotation(from: $0[0], to: $0[1]) }
//  .subscribe(on: DispatchQueue.global())
//  .receive(on: DispatchQueue.main)
  .sink { [ weak self, weak photoItem ] angle in
    guard let self = self else { return }
    guard let hostedItem  = self.hostedItem as? PhotoItem else { return }
    guard hostedItem === photoItem else { return }
    guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
    UIView.animate(withDuration: 0.25) {
     mainView.arrowsRotateView.transform = mainView.arrowsRotateView.transform.rotated(by: angle)
    }
  }
    
 }
}
