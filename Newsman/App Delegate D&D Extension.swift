
import UIKit

extension AppDelegate
{
 static let dragAnimStopDelay: Int = 2   // in seconds of DispatchTimeInterval underlying associted value
 static let dragUnselectDelay: Int = 5   // in seconds of DispatchTimeInterval underlying associted value
 static let dragAutoCnxxDelay: Int = 1   // in seconds of DispatchTimeInterval underlying associted value
 
 static var globalDragItems = [Draggable]()
 static var globalDropItems = [Draggable]()
 
 static var globalDragDropItems: [Draggable] { return globalDragItems + globalDropItems }
 
 static func clearAllDraggedItems()
 {
 
  print(#function)
 
  globalDragDropItems.forEach
  {
   $0.clear(with: (forDragAnimating: dragAnimStopDelay, forSelected: dragUnselectDelay))
  }
 }
 
 
 static func printAllDraggedItems()
 {
  globalDragItems.forEach
  {
   print("DRAG ITEM ID: \($0.id) DRAG SESSION: \(String(describing: $0.dragSession)) SELECTED:\($0.isSelected) ")
  }
 }
 
 

 static func clearCancelledDraggedItems()
 {
  print (#function)
  globalDragItems.removeAll{$0.dragSession == nil}
 }
 
 
 static func clearAllDragAnimationCancelWorkItems ()
 {
  print (#function)
  AppDelegate.globalDragItems.forEach
  {
   $0.dragAnimationCancelWorkItem?.cancel()
   $0.dragAnimationCancelWorkItem = nil
  }
 }
 
 
}//extension AppDelegate...
