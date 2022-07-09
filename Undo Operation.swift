//
//  Undo Operation.swift
//  Newsman
//
//  Created by Anton2016 on 03/09/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import RxSwift

final class UndoOperation: NSObject
{
 static func == (lhs: UndoOperation, rhs: UndoOperation) -> Bool
 {
  return lhs === rhs
 }
 
 override var debugDescription: String
 {
  return "Undo Operation: [\(name ?? "Unnamed")]"
 }
 
 var next: UndoOperation?
 weak var prev: UndoOperation?
 
 func next(for target: NSObject) -> UndoOperation?
 {
  return targetNods[target]?.next
 }
 
 func setNext(for target: NSObject, to value: UndoOperation?)
 {
  targetNods[target]?.next = value
 }
 
 func prev(for target: NSObject) -> UndoOperation?
 {
  return targetNods[target]?.prev
 }
 
 func setPrev(for target: NSObject, to value: UndoOperation?)
 {
  targetNods[target]?.prev = value
 }
 
 var isExecuted = false
 
 var redo     : UndoOperation? //must strongly retain sibling redo operation!
 weak var undo: UndoOperation?
 
 struct TargetNod
 {
  weak var next: UndoOperation?
  weak var prev: UndoOperation?
  
  init(next: UndoOperation? = nil, prev: UndoOperation? = nil)
  {
   self.next = next
   self.prev = prev
  }
  
  static let empty = TargetNod()
 }
 
 var targetNods: [NSObject: TargetNod]
 
 var name: String?
 
 var undoBlock: ( _ completion: @escaping () -> Void ) -> Void
 
 init(with targets: [NSObject]? = nil, undoBlock: @escaping (_ completion: @escaping () -> Void ) -> Void )
 {
  var targetNods = [NSObject: TargetNod]()
  targets?.forEach { targetNods[$0] = .empty }
  self.targetNods = targetNods
  self.undoBlock = undoBlock
  super.init()
 }
 
 
 func main(completion: @escaping () -> ())
 {
  print (#function, name ?? "")
  undoBlock(completion)
 }
 
 func start(completion: @escaping () -> () ) { main(completion: completion) }
 
 deinit
 {
  print (#function, "\(debugDescription) IS DESTROYED!")
 }
 
}
