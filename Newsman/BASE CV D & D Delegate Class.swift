//
//  CV D & D Delegate Base Class.swift
//  Newsman
//
//  Created by Anton2016 on 25.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class RxSwift.DisposeBag
import class RxSwift.PublishSubject

class CollectionViewDragAndDropBaseDelegate: NSObject,
                                             UICollectionViewDragDelegate,
                                             UICollectionViewDropDelegate,
                                             SnippetItemsDraggable,
                                             CollectionViewDragItemProvidable,
                                             DragAndDropStatesObservation

{
 var isContentDraggable: Bool { true }
 
 let disposeBag = DisposeBag()
 
 deinit { print (" D&D DELEGATE OBJECT [\(self.description)] IS DESTROYED!!!)") }
 
 var name: String { Self.description() }
 
 final var completion: (() -> ())?
 
 init(snippet: BaseSnippet, snippetViewController: UIViewController)
 {
  super.init()
  self.snippet = snippet
  self.snippetViewController = snippetViewController
  self.observeDragAndDropStates()
 }
 
 func draggedItem(at indexPath: IndexPath) -> Draggable? { nil }
 
 final weak var snippet: BaseSnippet?
 final weak var snippetViewController: UIViewController?
 
 
 //var ddDelegateSubject = PublishSubject<DragAndDropDelegateStates>()
 
 func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession)
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)], DRAG COUNT [\(session.items.count)]")
  
  ddDelegateSubject.onNext(.begin)
  
 }//func collectionView(_ collectionView...
 

 func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession)
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  ddDelegateSubject.onNext(.end)
 }//func collectionView(_ collectionView: UICollectionView...
 
 
 
 func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession)
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  ddDelegateSubject.onNext(.end)
 }//func collectionView(_ collectionView: UICollectionView...
 
 
 
 func collectionView(_ collectionView: UICollectionView, dropSessionDidEnter session: UIDropSession)
 {
  //print (#function )
  ddDelegateSubject.onNext(.enter(view: collectionView, at: session.location(in: collectionView)))
 }
 
 func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession)
 {
  //print (#function )
  ddDelegateSubject.onNext(.exit(view: collectionView, at: session.location(in: collectionView)))
 }
 
 func isDragOverlayedByArrowMenu (_ collectionView: UICollectionView,
                                  forCellAt indexPath: IndexPath) -> Bool { false }
 
 var dragEventsCount: Int { draggedItems.count }
 
 final var draggedItems: [Draggable]
 {
  AppDelegate.globalDragItems.filter{ $0.dragSession != nil }
 }
 
 
 func getDragItems (_ collectionView: UICollectionView,
                    for session: UIDragSession,
                    forCellAt indexPath: IndexPath) -> [UIDragItem]
  
 {
  
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  

  if isDragOverlayedByArrowMenu(collectionView, forCellAt: indexPath) { return [] }
  
  guard isContentDraggable else { return [] }
  
  guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoSnippetCellProtocol else { return [] }
  guard cell.arrowMenuView == nil else { return [] }
  guard let dragged = draggedItem(at: indexPath) else { return [] }
  guard cell.hostedItem === dragged else { return [] }
  guard dragged.isDraggable else { return [] }
  
  let itemProvider = NSItemProvider()
  let dragItem = UIDragItem(itemProvider: itemProvider)
  dragged.dragSession = session
  dragItem.localObject = dragged
  
  ddDelegateSubject.onNext(.flock(dragItem: dragged))
 
  return [dragItem]
  
 }//func getDragItems (_ collectionView: UICollectionView...

 func collectionView(_ collectionView: UICollectionView,
                       itemsForBeginning session: UIDragSession,
                       at indexPath: IndexPath) -> [UIDragItem]
  
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  return getDragItems(collectionView, for: session, forCellAt: indexPath)
 }
 
 
 func collectionView(_ collectionView: UICollectionView,
                       itemsForAddingTo session: UIDragSession,
                       at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
  
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  return getDragItems(collectionView, for: session, forCellAt: indexPath)
 }
 
 
 func collectionView(_ collectionView: UICollectionView,
                     dropSessionDidUpdate session: UIDropSession,
                     withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
  
 {
  ddDelegateSubject.onNext(.proceed(location: session.location(in: collectionView)))
  
  guard isContentDraggable else { return .init(operation: .forbidden, intent: .unspecified) }
  
  if (session.localDragSession != nil)
  {
   return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
  }
  else
  {
   return UICollectionViewDropProposal(operation: .copy , intent: .insertAtDestinationIndexPath)
  }
  
 }
 

 func collectionView(_ collectionView: UICollectionView,
                      performDropWith coordinator: UICollectionViewDropCoordinator)
  
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(coordinator.session.description)]")
  let count = performDrop(in: collectionView, with: coordinator)
  let destination = coordinator.destinationIndexPath
  ddDelegateSubject.onNext(.drop(eventCount: count, destination: destination))
 }

 
 
 func performDrop(in collectionView: UICollectionView,
                  with coordinator: UICollectionViewDropCoordinator) -> Int
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(coordinator.session.description)]")
  return 0
 }
 
 
 
}





