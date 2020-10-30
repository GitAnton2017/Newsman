//
//  Undo Manager.swift
//  Newsman
//
//  Created by Anton2016 on 04/09/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import RxSwift

protocol UndoTargetRepresentable
{
 var name: String { get }
}

class DistributedUndoManager: CustomDebugStringConvertible
{
 typealias T = UndoTargetRepresentable
 
 var debugDescription: String { return "<<<DISTRIBUTED UNDO MANAGER>>>" }
 
 weak var topUndo: UndoOperation?
 weak var topRedo: UndoOperation?
 
 var isRegisterRedoEnabled = false
 var isRegisterUndoEnabled = true
 
 
 struct TargetTop
 {
  weak var head: UndoOperation?
  weak var tail: UndoOperation?
  
  weak var topUndo: UndoOperation?
  weak var topRedo: UndoOperation?
  
  var isRegisterUndoEnabled = true
  var isRegisterRedoEnabled = false
  
  
  static var empty: TargetTop { return TargetTop(head: nil, tail: nil, topUndo: nil, topRedo: nil) }
  
  init(head: UndoOperation?, tail: UndoOperation?, topUndo: UndoOperation?, topRedo: UndoOperation?)
  {
   self.head = head
   self.tail = tail
   self.topUndo = topUndo
   self.topRedo = topRedo
  }
  
  init(head:    UndoOperation?) { self.head = head       }
  init(tail:    UndoOperation?) { self.tail = tail       }
  init(topUndo: UndoOperation?) { self.topUndo = topUndo }
  init(topRedo: UndoOperation?) { self.topRedo = topRedo }
  
 }
 
 var targetTops = [NSObject : TargetTop]()
 
 var head: UndoOperation? = nil
 weak var tail: UndoOperation? = nil
 
 func head(for target: NSObject) -> UndoOperation?
 {
  return targetTops[target]?.head
 }
 
 func setHead(for target: NSObject, to value: UndoOperation?)
 {
  if targetTops[target] != nil
  {
   targetTops[target]!.head = value
  }
  else
  {
   targetTops[target] = TargetTop(head: value)
  }
 }
 
 func tail(for target: NSObject) -> UndoOperation?
 {
  return targetTops[target]?.tail
 }
 
 func setTail(for target: NSObject, to value: UndoOperation?)
 {
  if targetTops[target] != nil
  {
   targetTops[target]!.tail = value
  }
  else
  {
   targetTops[target] = TargetTop(tail: value)
  }
 }
 
 
 var topUndoMain: UndoOperation?
 {
  while ( self.topUndo?.isExecuted ?? false)
  {
   if let topRedo = self.topUndo?.redo { self.topRedo = topRedo }
   self.topUndo = self.topUndo?.prev
  }
  
  return self.topUndo
 }
 
 
 @discardableResult func topUndo(for target: NSObject) -> UndoOperation?
 {
  var topUndoTarget = self.targetTops[target]?.topUndo
  
  while ( topUndoTarget?.isExecuted ?? false )
  {
   if let topRedoTarget = topUndoTarget?.redo
   {
    self.setTopRedo(for: target, to: topRedoTarget)
   }
   
   topUndoTarget = topUndoTarget?.prev(for: target)
   self.setTopUndo(for: target, to: topUndoTarget)
  }
  
  // log(#function)
  return topUndoTarget
  
 }
 
 
 var topRedoMain: UndoOperation?
 {
  
  while ( topRedo?.isExecuted ?? false )
  {
   topRedo = topRedo?.undo?.next?.redo
   topUndo = topUndo?.next
  }
  
  if ( topRedo == nil && topUndo !== tail ) { topUndo = tail }
  
  return self.topRedo
 }
 
 private var isLastOperationFinished = true
 
 weak var lastOperation: UndoOperation?
 
 func isLastOperation(_ op: UndoOperation) -> Bool
 {
  return lastOperation === op
 }
 
 @discardableResult func topRedo(for target: NSObject) -> UndoOperation?
 {
  var topRedoTarget = targetTops[target]?.topRedo
  var topUndoTarget = targetTops[target]?.topUndo
  
  while ( topRedoTarget?.isExecuted ?? false )
  {
   topRedoTarget = topRedoTarget?.undo?.next(for: target)?.redo
   setTopRedo(for: target, to: topRedoTarget)
   
   topUndoTarget = topUndoTarget?.next
   setTopUndo(for: target, to: topUndoTarget)
  }
  
  let targetTail = tail(for: target)
  if ( topRedoTarget == nil && topUndoTarget !== targetTail )
  {
   setTopUndo(for: target, to: targetTail)
  }
  
  return topRedoTarget
 }
 
 
 func setTopUndo(for target: NSObject, to value: UndoOperation?)
 {
  
  if targetTops[target] != nil
  {
   targetTops[target]!.topUndo = value
  }
  else
  {
   targetTops[target] = TargetTop(topUndo: value)
  }
 }
 
 
 
 func setTopRedo(for target: NSObject, to value: UndoOperation?)
 {
  
  if targetTops[target] != nil
  {
   targetTops[target]!.topRedo = value
  }
  else
  {
   targetTops[target] = TargetTop(topRedo: value)
  }
 }
 
 func enableUndoRegistration()
 {
  //main and all target UNDO registration are being set to disabled state...
  isRegisterUndoEnabled = true
  targetTops.keys.forEach{ targetTops[$0]?.isRegisterUndoEnabled = true }
  
 }
 
 func disableUndoRegistration()
 {
   //main and all target UNDO registration are being set to enabled state...
  isRegisterUndoEnabled = false
  targetTops.keys.forEach{ targetTops[$0]?.isRegisterUndoEnabled = false }
 }
 
 func enableRedoRegistration(for target: NSObject? = nil)
 {
  if target == nil // no target main and all targets REDO registrations are enabled...
  {
   isRegisterRedoEnabled = true
   targetTops.keys.forEach{ targetTops[$0]?.isRegisterRedoEnabled = true }
  }
  else // only enable REDO registration for specified target...
  {
   isRegisterRedoEnabled = false
   targetTops.keys.forEach{ targetTops[$0]?.isRegisterRedoEnabled = false }
   targetTops[target!]?.isRegisterRedoEnabled = true
  }
 }
 
 func disableRedoRegistration()
 {
  isRegisterRedoEnabled = false
  targetTops.keys.forEach{ targetTops[$0]?.isRegisterRedoEnabled = false }
 }
 
 
 func isRegisterUndoEnabled(for target: NSObject) -> Bool
 {
  return targetTops[target]?.isRegisterUndoEnabled ?? true
 }
 
 func isRegisterRedoEnabled(for target: NSObject) -> Bool
 {
  return targetTops[target]?.isRegisterRedoEnabled ?? false
 }
 
 func registerRedo(_ named: String? = nil,
                     for target: NSObject? = nil,
                     redoBlock: @escaping (@escaping () -> ()) -> ()) -> UndoOperation
 {
  
  print(#function, "REDO - target: [\((target as? T)?.name ?? "")] named: [\(named ?? "No name")]")
  
  let newRedo = UndoOperation(undoBlock: redoBlock)
  newRedo.name = named
  
  if ( target == nil ) // register with main queue...
  {
   self.topUndo?.redo = newRedo
   newRedo.undo = topUndo
   self.topRedo = newRedo
  }
  else
  {
   let topUndoTarget = targetTops[target!]?.topUndo // register with targeted queue...
   topUndoTarget?.redo = newRedo
   newRedo.undo = topUndoTarget
   setTopRedo(for: target!, to: newRedo)
   
  }
  
  disableRedoRegistration() // main and all targeted redo registation are set to disabled state!
  
  print("to undo by: \(newRedo.undo?.name ?? "X")")
  log(#function)
  
  return newRedo
  
 }
 
 
 @discardableResult func registerUndo(named: String? = nil,
                                      with targets: [NSObject]? = nil,
                                      undoBlock: @escaping (@escaping () -> ()) -> ()) -> UndoOperation?
 {
  
  let newUndo = UndoOperation(with: targets, undoBlock: undoBlock)
  newUndo.name = named
  
  switch targets
  {
   case _ where isRegisterRedoEnabled: return registerRedo(named, redoBlock: undoBlock)
   // if isRegisterRedoEnabled main flag is set register REDO as with main queue...
   
   case .some(let targets):
    // register REDO only for enabled target...
    if let target = targets.first(where: { isRegisterRedoEnabled(for: $0) })
    {
     return registerRedo(named, for: target, redoBlock: undoBlock)
    }
    
    guard isRegisterUndoEnabled else { return nil }
    //if we have targets register UNDO with each target and in main queue as well...
    
    targets.forEach
    {
     let targetHead = head(for: $0)
     if ( targetHead == nil )
     {
      setHead(for: $0, to: newUndo)
      setTail(for: $0, to: newUndo)
     }
     else
     {
      if let topUndoTarget = topUndo(for: $0)
      {
       let nextTopTarget = topUndoTarget.next(for: $0)
       newUndo.setNext(for: $0, to: nextTopTarget)
       nextTopTarget?.setPrev(for: $0, to: newUndo)
       topUndoTarget.setNext(for: $0, to: newUndo)
       newUndo.setPrev(for: $0, to: topUndoTarget)
      }
      else
      {
       newUndo.setNext(for: $0, to: targetHead)
       targetHead?.setPrev(for: $0, to: newUndo)
       setHead(for: $0, to: newUndo)
      }
      
      let targetTail = tail(for: $0)
      if let newTargetTail = targetTail?.next(for: $0) { setTail(for: $0, to: newTargetTail) }
     }
    
     setTopUndo(for: $0, to: newUndo)
    }
    
    fallthrough //...and in main queue as well...
   
   case .none where isRegisterUndoEnabled: //no target register Undo in main queue
    
    print(#function, "for targets: \((targets as? [T])?.map{$0.name} ?? [""]) named: [\(named ?? "No name")]")
    
    if ( head == nil )
    {
     head = newUndo
     tail = newUndo
    }
    else
    {
     if let topUndo = self.topUndoMain
     {
      newUndo.next = topUndo.next
      topUndo.next?.prev = newUndo
      topUndo.next = newUndo
      newUndo.prev = topUndo
     }
     else
     {
      newUndo.next = head
      head?.prev = newUndo
      head = newUndo
     }
     
     
     if let newTail = tail?.next { tail = newTail }
    }
    
    topUndo = newUndo
    
    print("to redo by: \(newUndo.redo?.name ?? "[No Redo yet...]")")
    log(#function)
    
    return newUndo
   
   default : break
  }
  
  return nil
 }
 
 func log(_ fnc: String)
 {
  print("-----------------------------------------------------------------------------")
  print(fnc, "MAIN TAIL: [\(tail?.name ?? "X")] TOP UNDO: [\(topUndo?.name ?? "X")] TOP REDO: [\(topRedo?.name ?? "X")]")
  print("-----------------------------------------------------------------------------")
  
  
  print("UNDO REG enabled: [\(isRegisterUndoEnabled)] REDO REG enabled: [\(isRegisterRedoEnabled)]")
  targetTops.forEach
   {target, tops in
    print ("Target: [\((target as? T)?.name ?? "")] Head: [\(tops.head?.name ?? "X")] Tail: [\(tops.tail?.name ?? "X")] TopUndo: [\(tops.topUndo?.name ?? "X")] TopRedo: [\(tops.topRedo?.name ?? "X")] UndoEnabled: [\(tops.isRegisterUndoEnabled)] RedoEnabled: [\(tops.isRegisterRedoEnabled)]" )
  }
  print("-----------------------------------------------------------------------------")
  print("\n")
  
 }
 
 func logStack()
 {
  print("-----------------------------------------------------------------------------")
  print ("<<<<<< MAIN UNDO/REDO STACK >>>>>>>")
  print("-----------------------------------------------------------------------------")
  
  var currUndo = head
  let tu = topUndoMain
  let tr = topRedoMain

  while let undo = currUndo
  {
   let redo = undo.redo
   print ("\(undo === tu ? "=> " :"")UNDO: [\(undo.name ?? "Unnamed") EXE (\(undo.isExecuted ? "X" : " "))]",
    redo != nil ? "REDO: [\(redo?.name ?? "Unnamed") EXE (\(redo?.isExecuted ?? false ? "X" : " "))]\(redo === tr ? " <=" : "")" : "")
   currUndo = currUndo?.next
  }
  print("-----------------------------------------------------------------------------")
  print("\n")
 }
 
 func logStack(for target: NSObject)
 {
  print("-----------------------------------------------------------------------------")
  print ("<<< UNDO/REDO STACK FOR TARGET [\((target as? T)?.name ?? "")] >>>")
  print("-----------------------------------------------------------------------------")
  
  var currUndo = head(for: target)
  let tu = topUndo(for: target)
  let tr = topRedo(for: target)
  
  while let undo = currUndo
  {
   let redo = undo.redo
   print ("\(undo === tu ? "=> " :"")UNDO: [\(undo.name ?? "Unnamed") EXE (\(undo.isExecuted ? "X" : " "))]",
    redo != nil ? "REDO: [\(redo?.name ?? "Unnamed") EXE (\(redo?.isExecuted ?? false ? "X" : " "))]\(redo === tr ? " <=" : "")" : "")
   currUndo = currUndo?.next(for: target)
  }
  
  print("-----------------------------------------------------------------------------")
  print("\n")
  
 }
 
 func logAllStacks()
 {
  logStack()
  targetTops.keys.forEach{ logStack(for: $0) }
 }
 
 private func isReadyForUndo(for target: NSObject? = nil) -> Bool
 {
  guard let lastOp = self.lastOperation else { return true }
  guard let currUndoOp = (target == nil) ? topUndoMain : topUndo(for: target!) else { return false }
 
  let lastOpTargets = Set(lastOp.targetNods.keys)
  let currUndoOpTargets = Set(currUndoOp.targetNods.keys)
  
  return lastOpTargets.isDisjoint(with: currUndoOpTargets) ? true : isLastOperationFinished
  
 }
 
 func canUndo(for target: NSObject? = nil) -> Bool
 {
  //guard isReadyForUndo(for: target) else { return false }
  guard let target = target else { return topUndoMain != nil }
  return topUndo(for: target) != nil
 }
 
 func shiftAllTopUndosUp()
 {
  let _ = topUndoMain
  targetTops.keys.forEach{ topUndo(for: $0) }
 }
 
 func shiftAllTopRedosDown()
 {
  let _ = topRedoMain
  targetTops.keys.forEach{ topRedo(for: $0) }
 }
 
 func undoAll()
 {
  while canUndo() { undo() }
 }
 
 func undo(_ times: Int)
 {
  guard abs(times) != 0 else { return }
  let op = times > 0 ? { self.undo() } : { self.redo() }
  let top = times > 0 ? { self.topUndoMain } : { self.topRedoMain }
  for _ in 1...abs(times) where top() != nil { op() }
 }
 
 func undo()
 {
  guard let topUndo = topUndoMain else
  {
   print(#function, "Cannot UNDO more in Main stack!")
   log(#function)
   return
  }
  
  lastOperation = topUndo
  
  print(#function, topUndo.name ?? "X", " in Main stack")
  
  if (topUndo.redo == nil ) { enableRedoRegistration() }
  
  
  disableUndoRegistration()
  
  isLastOperationFinished = false
  topUndo.start
  {
   DispatchQueue.main.async { self.isLastOperationFinished = true }
  }
  
  
  topUndo.isExecuted = true
  
  
  self.topRedo = topUndo.redo
  self.topRedo?.isExecuted = false
  self.topUndo = topUndo.prev
  
  shiftAllTopUndosUp()
  
  enableUndoRegistration()
  
  log(#function)
  
 }
 
 
 
 
 func undoAll(for target: NSObject)
 {
  while canUndo(for: target) { undo(for: target) }
 }
 
 func undo(_ times: Int, for target: NSObject)
 {
  guard abs(times) != 0 else { return }
  let op = times > 0 ? { self.undo(for: $0) } : { self.redo(for: $0) }
  let top = times > 0 ? { self.topUndo(for: $0) } : { self.topRedo(for: $0)}
  
  for _ in 1...abs(times) where top(target) != nil { op(target) }
  
 }
 
 func undo(for target: NSObject)
 {
  guard let topUndoTarget = topUndo(for: target) else
  {
   print(#function, "Cannot UNDO more for Target: [\((target as! T).name)]!")
   log(#function)
   return
  }
  
  lastOperation = topUndoTarget
  
  print(#function, topUndoTarget.name ?? "X", " for Target: [\((target as! T).name)]!")
  
  
  if ( topUndoTarget.redo == nil ) { enableRedoRegistration(for: target) }
  
  disableUndoRegistration()
  
  isLastOperationFinished = false
  topUndoTarget.start
  {
   DispatchQueue.main.async { self.isLastOperationFinished = true }
  }
  
  topUndoTarget.isExecuted = true
  
  
  topUndoTarget.redo?.isExecuted = false
  
  setTopRedo(for: target, to: topUndoTarget.redo)
  setTopUndo(for: target, to: topUndoTarget.prev(for: target))
  
  //topUndo(for: target)
  shiftAllTopUndosUp()
  
  enableUndoRegistration()
  
  log(#function)
  
 }
 
 private func isReadyForRedo(for target: NSObject? = nil) -> Bool
 {
  guard let lastOp = self.lastOperation else { return true }
  guard let currRedoOp = (target == nil) ? topRedoMain : topRedo(for: target!) else { return false }
  
  let lastOpTargets = Set(lastOp.targetNods.keys)
  let currRedoOpTargets = Set(currRedoOp.targetNods.keys)
  
  return lastOpTargets.isDisjoint(with: currRedoOpTargets) ? true : isLastOperationFinished
  
 }
 
 func canRedo(for target: NSObject? = nil) -> Bool
 {
  //guard isReadyForRedo(for: target) else { return false }
  guard let target = target else { return topRedoMain != nil }
  return topRedo(for: target) != nil
 }
 
 func redoAll()
 {
  while canRedo() { undo() }
 }
 
 func redo(_ times: Int)
 {
  guard abs(times) != 0 else { return }
  let op = times > 0 ? { self.redo() } : { self.undo() }
  let top = times > 0 ? { self.topRedoMain } : { self.topUndoMain }
  
  for _ in 1...abs(times) where top() != nil { op() }
  
 }
 
 func redo()
 {
  guard let topRedo = topRedoMain else
  {
   print(#function, "Cannot REDO more in Main redo stack!")
   log(#function)
   return
  }
  
  lastOperation = topRedo
  
  print(#function, topRedo.name ?? "X", " in Main stack")
  
  disableUndoRegistration()
  
  isLastOperationFinished = false
  
  topRedo.start
  {
   DispatchQueue.main.async { self.isLastOperationFinished = true }
  }
  
  topRedo.isExecuted = true
  
  
  self.topUndo = (topUndo == nil) ? head : topUndo?.next
  self.topUndo?.isExecuted = false
  self.topRedo = topUndo?.next?.redo
  
  shiftAllTopRedosDown()
  
  enableUndoRegistration()
  
  log(#function)
  
 }
 
 
 func redoAll(for target: NSObject)
 {
  while canRedo(for: target) { redo(for: target) }
 }
 
 func redo(_ times: Int, for target: NSObject)
 {
  guard abs(times) != 0 else { return }
  let op = times > 0 ? { self.redo(for: $0) } : { self.undo(for: $0) }
  let top = times > 0 ? { self.topRedo(for: $0) } : { self.topUndo(for: $0)}
  
  for _ in 1...abs(times) where top(target) != nil { op(target) }
  
 }
 
 func redo(for target: NSObject)
 {
  
  guard let topRedoTarget = topRedo(for: target) else
  {
   print(#function, "Cannot REDO more for Target: [\((target as! T).name)]!")
   log(#function)
   return
  }
  
  lastOperation = topRedoTarget
  
  print(#function, topRedoTarget.name ?? "X", " for Target: [\((target as! T).name)]!")
  
  disableUndoRegistration()
  
  let topUndoTarget = topUndo(for: target)
  
  isLastOperationFinished = true
  topRedoTarget.start
  {
   DispatchQueue.main.async { self.isLastOperationFinished = true }
  }
  
  topRedoTarget.isExecuted = true
  
  let newUndoTarget = (topUndoTarget == nil) ? head(for: target) : topUndoTarget?.next(for: target)
  newUndoTarget?.isExecuted = false
  setTopUndo(for: target, to: newUndoTarget)
  let newRedoTarget = newUndoTarget?.next(for: target)?.redo
  setTopRedo(for: target, to: newRedoTarget)
  
  shiftAllTopRedosDown()
  
  enableUndoRegistration()
  
  log(#function)
 }
 
 func removeAllOperations()
 {
  targetTops.removeAll()
  head = nil
 }
 
 private let deleteOperationsScheduler =
  SerialDispatchQueueScheduler(internalSerialQueueName: "delete.operations.isolation.queue")
 
 func removeAllOperations(for target: NSObject) -> Completable
 {
  Completable.create
  { promise in
   self.removeAllOperations(for: target) as Void
   promise(.completed)
   return Disposables.create()
  }.subscribeOn(deleteOperationsScheduler)
 }
 
 func removeAllOperations(for targets: [NSObject]) -> Completable
 {
  Completable.zip(targets.map{ removeAllOperations(for: $0)} )
 }
 
 
 func removeAllOperations(for targets: [NSObject])
 {
  targets.forEach{ removeAllOperations(for: $0)}
 }
 
 func removeAllOperations(for target: NSObject)
 {
  defer { targetTops[target] = nil }
  
  var currUndo = head
  while let undo = currUndo
  {
   currUndo = currUndo?.next
   if ( undo.targetNods[target] != nil ) { remove(undo: undo) }
  }
 
 }// func removeAllOperations...
 
 func remove(undo: UndoOperation, for target: NSObject)
 {
  if undo.targetNods.isEmpty { return }
  guard undo.targetNods[target] != nil else { return }
  
  let topUndoTarget = targetTops[target]?.topUndo
  let prevUndoTarget = topUndoTarget?.prev(for: target)
  
  if undo === topUndoTarget
  {
   setTopUndo(for: target, to: prevUndoTarget)
  }
  
  let headTarget = head(for: target)
  let tailTarget = tail(for: target)
  
  switch undo
  {
   case headTarget:
    let nextTarget = headTarget?.next(for: target)
    setHead(for: target, to: nextTarget)
    headTarget?.setPrev(for: target, to: nil)
   
   case tailTarget:
    let prevTarget = tailTarget?.prev(for: target)
    setTail(for: target, to: prevTarget)
    tailTarget?.setNext(for: target, to: nil)
   
   default:
    let prevUndoTarget = undo.prev(for: target)
    let nextUndoTarget = undo.next(for: target)
    prevUndoTarget?.setNext(for: target, to: nextUndoTarget)
    nextUndoTarget?.setPrev(for: target, to: prevUndoTarget)
  }
 }
 
 func remove(undo: UndoOperation)
 {
  targetTops.keys.forEach{ remove(undo: undo, for: $0) }
  
  if ( undo === topUndo ) { topUndo = undo.prev }
  
  switch undo
  {
   case head: head = head?.next; head?.prev = nil
   case tail: tail = tail?.prev; tail?.next = nil
   default:
    let prevUndo = undo.prev
    let nextUndo = undo.next
    prevUndo?.next = nextUndo
    nextUndo?.prev = prevUndo
  }
 }
 
 deinit
 {
 // print (#function, "\(debugDescription) IS DESTROYED!")
 }
 
}
