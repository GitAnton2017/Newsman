//
//  CV Cell D & D Interaction Delegate Base.swift
//  Newsman
//
//  Created by Anton2016 on 04.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class RxSwift.DisposeBag
import class RxSwift.PublishSubject

class PhotoItemCellDragAndDropBaseDelegate: NSObject,
                                            UIDropInteractionDelegate,
                                            PhotoItemCellDropProvidable,
                                            DragAndDropStatesObservation

{
 
 weak var ownerCell: PhotoSnippetCellProtocol?
 
 var disposeBag =  DisposeBag()
 
 var completion: (() -> ())?
 
 var name: String { Self.description() }
 
 var snippet: BaseSnippet? { hosted?.photoManagedObject.photoSnippet }
 
 var isDraggable: Bool { true }
 
 var hosted: PhotoItemProtocol? { ownerCell?.hostedItem }
 
 var mainView: UIView? { ownerCell?.mainView }
 
 var isDropAllowed: Bool
 {
  guard let hostedItem = self.hosted else { return false }
  return !hostedItem.isDragAnimating
 }
 
 var dragEventsCount: Int { draggedItems.count }
 
 final var draggedItems: [ Draggable ]
 {
  AppDelegate.globalDragItems.filter{ $0.dragSession != nil }
 }

 init( ownerCell: PhotoSnippetCellProtocol? )
 {
  self.ownerCell = ownerCell
  super.init()
 }
 
 func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool
 {
  return true
 }//func dropInteraction(_ interaction: ...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, item: UIDragItem,
                      willAnimateDropWith animator: UIDragAnimating)
 {
  animator.addAnimations
  {
   self.ownerCell?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
   self.mainView?.backgroundColor = UIColor.newsmanRed.withAlphaComponent(0.5)
  }
 }//func dropInteraction(_ interaction: ...
 
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, concludeDrop session: UIDropSession)
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  UIView.animate(withDuration: 0.25, animations:
  {
   self.ownerCell?.transform = .identity
   self.mainView?.backgroundColor = .clear
  })
  {_ in
   self.mainView?.layer.borderWidth = 1.0
   self.mainView?.alpha = 1.0
  
  }
  
 }//func dropInteraction(_ interaction:...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession)
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  mainView?.layer.borderWidth = 3.0
  mainView?.alpha = 0.5
  ddDelegateSubject.onNext(.enter(view: interaction.view,
                                  at: interaction.view != nil ? session.location(in: interaction.view!) : nil ))
 }//func dropInteraction(_ interaction:...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidExit session: UIDropSession)
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  mainView?.layer.borderWidth = 1.0
  mainView?.alpha = 1.0
  ddDelegateSubject.onNext(.exit(view: interaction.view,
                                 at: interaction.view != nil ? session.location(in: interaction.view!) : nil ))
  
 }//func dropInteraction(_ interaction:...
 
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession)
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  mainView?.layer.borderWidth = 1.0
  mainView?.alpha = 1.0
  ddDelegateSubject.onNext(.end)
 }//func dropInteraction(_ interaction:...
 
 
 
 func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal
 {
  guard let ownerCell = self.ownerCell else { return UIDropProposal(operation: .cancel) }
  
  if let ownerCellCollectionView = ownerCell.superview as? UICollectionView
  {
   ddDelegateSubject.onNext(.proceed(location: session.location(in: ownerCellCollectionView)))
  }
  
  if session.localDragSession != nil
  {
   return UIDropProposal(operation: isDropAllowed ? .move : .forbidden)
  }
  else
  {
   return UIDropProposal(operation: .copy)
  }
 }//func dropInteraction(_ interaction:...
 
 
 func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession)
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  let count = performDrop(in: interaction, with: session)
  
  ddDelegateSubject.onNext(.drop(eventCount: count, destination: nil))
  
 }//func dropInteraction(_ interaction:...
 
 
 func performDrop(in interaction: UIDropInteraction, with session: UIDropSession) -> Int
 {
  print ("\(#function), DELEGATE: [\(self)] DRAG SESSION [\(session.description)]")
  return 0
 }
 
 
}
