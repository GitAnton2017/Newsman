
import UIKit

extension AppDelegate
{
 static let dragAnimStopDelay: Int = 2   // in seconds of DispatchTimeInterval underlying associted value
 static let dragUnselectDelay: Int = 5   // in seconds of DispatchTimeInterval underlying associted value
 static let dragAutoCnxxDelay: Int = 1   // in seconds of DispatchTimeInterval underlying associted value
 
 static var globalDragItems = [Draggable]()
 {
  didSet
  {
   printAllDraggedItems()
  }
 }
 static var globalDropItems = [Draggable]()
 
 static var globalDragDropItems: [Draggable] { return globalDragItems + globalDropItems }
 
// static func clearAllDraggedItems()
// {
// 
//  print(#function)
// 
//  globalDragDropItems.forEach
//  {
//   $0.clear(with: (forDragAnimating: dragAnimStopDelay, forSelected: dragUnselectDelay))
//  }
// }
 
 
 static func printAllDraggedItems()
 {
  print("*************************************************************************************************")
  print("<<< THE LIST OF GLOBAL DRAG & DROP ITEMS (\(globalDragItems.count))>>> ")
  print("*************************************************************************************************")
  globalDragItems.enumerated().forEach
  {
   print("[\($0.0)] DRAGGED \($0.1) ID: [\($0.1.id?.uuidString ?? "NO ID")] DRAG SESSION: [\($0.1.dragSession?.debugDescription ?? "NO DRAG SESSION")]")
  }
  print("*************************************************************************************************")
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
