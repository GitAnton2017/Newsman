//
//  Snippets Draggable.swift
//  Newsman
//
//  Created by Anton2016 on 14/03/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit
import CoreData

final class SnippetDragItem: NSObject, SnippetProtocol
{
 
 var isFolderDragged: Bool { return false } // Snippet always is not contained in any folder item!
 
 weak var dragSession: UIDragSession?
 
 var dragAnimationCancelWorkItem: DispatchWorkItem?

 var id: UUID { return snippet.id! }
 
 var type: SnippetType  { return snippet.snippetType }
 
 var location: String?  { return snippet.snippetLocation }
 
 var snippet: BaseSnippet
 
 init (snippet: BaseSnippet)
 {
  self.snippet = snippet
  super.init()
 }
 
 var date: Date { return snippet.snippetDate }
 
 var priority: SnippetPriority { return snippet.snippetPriority }
 
 var url: URL { return snippet.url }
 
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
  get { return snippet.isSelected }
  set
  {
   guard newValue != isSelected else { return }
   snippet.managedObjectContext?.persist
   {
    self.snippet.isSelected = newValue
   }
  }
 }

 
 var isDragAnimating: Bool
 {
  get { return snippet.isDragAnimating}
  set
  {
   snippet.managedObjectContext?.persist
   {
    self.snippet.isDragAnimating = newValue
   }
  }
 }
 
 var isSetForClear: Bool
 {
  get { return snippet.dragAndDropAnimationSetForClearanceState }
  set { snippet.dragAndDropAnimationSetForClearanceState = newValue }
 }
 

 var isZoomed: Bool
 {
  get { return snippet.zoomedSnippetState}
  set { snippet.zoomedSnippetState = newValue }
 }
 
 var zoomView: ZoomView? = nil //reseved for futute use...
 
 func move(to snippet: BaseSnippet, to draggableItem: Draggable?)
 {
  guard self.snippet !== snippet else { return } //prevent moving into itself...
  
  switch (self.snippet, snippet, draggableItem)
  {
   case let (source as PhotoSnippet, destination as PhotoSnippet, nil):
    source.move(into: destination)
   case let (source as PhotoSnippet, _ as PhotoSnippet, folderItem as PhotoFolderItem):
    source.merge(with: folderItem.folder)
   case let (source as PhotoSnippet, _ as PhotoSnippet, photoItem as PhotoItem):
    source.merge(with: photoItem.photo)
   default: break
  }
 }
 
 
}



