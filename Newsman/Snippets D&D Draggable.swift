//
//  Snippets Draggable.swift
//  Newsman
//
//  Created by Anton2016 on 14/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData
import protocol RxSwift.Disposable
import class Combine.AnyCancellable

final class SnippetDragItem: NSObject, SnippetProtocol
{
 var isDropProceeding: Bool = false //TO DO LATER
 var isDragProceeding: Bool = false //TO DO LATER
 var isJustCreated: Bool = false //TO DO LATER
 var dragProceedLocation: CGPoint = .zero //TO DO LATER
 
 var cellDragProceedSubscription: AnyCancellable?  //TO DO LATER
 var cellDropProceedSubscription: AnyCancellable?  //TO DO LATER
 var cellDragLocationSubscription: AnyCancellable?  //TO DO LATER
 
 
 
 var dragStateSubscription: Disposable?
 var dragProceedSubscription: Disposable?

 
 func move(to snippet: BaseSnippet, to draggableItem: Draggable?)
 {
  // TO DO
 }
 
 var isFolderDragged: Bool { return false } // Snippet always is not contained in any folder item!
 
 weak var dragSession: UIDragSession?
 
 var dragAnimationCancelWorkItem: DispatchWorkItem?

 var id: UUID? { return snippet.id }
 
 var type: SnippetType?  { return snippet.snippetType }
 
 var location: String?  { return snippet.snippetLocation }
 
 var snippet: BaseSnippet
 
 init (snippet: BaseSnippet)
 {
  self.snippet = snippet
  super.init()
 }
 
 var date: Date { return snippet.snippetDate }
 
 var priority: SnippetPriority { return snippet.snippetPriority }
 
 var url: URL? { return snippet.url }
 
 func deleteAllData()
 {
  
 }
 
 func cancelProviderOperations()
 {
  
 }
 
 func toggleSelection()
 {
  isSelected.toggle()
 }

 var hostedManagedObject: NSManagedObject { return snippet }
 
 var isSelected: Bool
 {
  get { snippet.isSelected }
  set
  {
   guard newValue != isSelected else { return }
   snippet.managedObjectContext?.perform { self.snippet.isSelected = newValue }
  }
 }

 
 var isDragAnimating: Bool
 {
  get { snippet.isDragAnimating}
  set { snippet.managedObjectContext?.perform { self.snippet.isDragAnimating = newValue } }
 }
 
// var isSetForClear: Bool
// {
//  get { snippet.dragAndDropAnimationSetForClearanceState }
//  set { snippet.dragAndDropAnimationSetForClearanceState = newValue }
// }
//

 var isZoomed: Bool
 {
  get { snippet.zoomedSnippetState}
  set { snippet.zoomedSnippetState = newValue }
 }
 
 var zoomView: ZoomView? = nil //reseved for futute use...
 
 
}



