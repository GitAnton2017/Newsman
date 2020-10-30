
import Foundation
import UIKit

extension SnippetsViewController: UITableViewDropDelegate, UITableViewDragDelegate
{
 
 
 func getDragItems (_ tableView: UITableView, for session: UIDragSession,
                    forCellAt indexPath: IndexPath) -> [UIDragItem]
  
 {
  
  print (#function, self.debugDescription, session.description)
  
  guard (tableView.cellForRow(at: indexPath) as? SnippetsViewCell) != nil else { return [] }
  
  let snippet = snippetsDataSource[indexPath]
  let dragged = SnippetDragItem(snippet: snippet)
  
  guard dragged.isDraggable else { return [] } //check up if it is really eligible for drags...
 
  let itemProvider = NSItemProvider(object: dragged)
  let dragItem = UIDragItem(itemProvider: itemProvider)
  
  AppDelegate.globalDragItems.append(dragged) //if all OK put it in drags first...
  dragged.isSelected = true                   //make selected in MOC
  dragged.isDragAnimating = true              //start drag animation of associated view
  dragged.dragSession = session
  dragItem.localObject = dragged
  
  AppDelegate.printAllDraggedItems()
  
  return [dragItem]
  
 }
 
 
 
 func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession,
                  at indexPath: IndexPath) -> [UIDragItem]
 {
  let itemsForBeginning = getDragItems(tableView, for: session, forCellAt: indexPath)
  
  //Auto cancel all dragged SnippetDragItems!
//  itemsForBeginning.compactMap{$0.localObject as? SnippetProtocol}.forEach
//  {item in
//   let autoCancelWorkItem = DispatchWorkItem
//   {
//    item.clear(with: (forDragAnimating: AppDelegate.dragAnimStopDelay,
//                      forSelected:      AppDelegate.dragUnselectDelay))
//   }
//
//   item.dragAnimationCancelWorkItem = autoCancelWorkItem
//   let delay: DispatchTime = .now() + .seconds(AppDelegate.dragAutoCnxxDelay)
//   DispatchQueue.main.asyncAfter(deadline: delay, execute: autoCancelWorkItem)
//
//  }
  
  return itemsForBeginning
 }
 
 
 
 func tableView(_ tableView: UITableView, itemsForAddingTo session: UIDragSession,
                  at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
 {
  print (#function, self.debugDescription, session.description)
  
  return getDragItems(tableView, for: session, forCellAt: indexPath)
 }
 
 
 func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession,
                withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal
 {
  if session.localDragSession != nil
  {
   return UITableViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
  }
  else
  {
   return UITableViewDropProposal(operation: .copy , intent: .insertAtDestinationIndexPath)
  }
 }
 
 func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession)
 {
  print (#function, self.debugDescription, session.description, session.items.count)
  AppDelegate.clearAllDragAnimationCancelWorkItems()
 }
 

 
 func tableView(_ tableView: UITableView, dropSessionDidEnd session: UIDropSession)
 {
  print (#function, self.debugDescription, session.description)
//  AppDelegate.clearAllDraggedItems()
  if tableView.isEditing { toggleEditMode() }
 }
 
 
 
 
 func tableView(_ tableView: UITableView, dragSessionDidEnd session: UIDragSession)
 {
  //TO DO....
 }

 
 
 
 func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator)
 {
  guard snippetsDataSource.searchString.isEmpty else { return }
  guard groupType == .byPriority else { return }
  guard let destIndexPath = coordinator.destinationIndexPath else { return }
  guard let newPriority = snippetsDataSource.sectionPriority(for: destIndexPath.section) else { return }
 
  let sourceIndexPaths = coordinator.items.compactMap{$0.sourceIndexPath}
  
  moc.persist(block: {
   self.snippetsDataSource[sourceIndexPaths].forEach
   {
    if $0.snippetPriority != newPriority { $0.snippetPriority = newPriority }
   }
  })
  {success in
   guard success else { return }
   if tableView.isEditing { self.toggleEditMode() }
  }
  
  
  
  //snippetsDataSource.currentFRC.moveSnippets(at: sourceIndexPaths, to: destIndexPath)
  
 }
    
    
    
}
