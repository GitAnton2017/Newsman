//
//  Async Undo Manager.swift
//  Newsman
//
//  Created by Anton2016 on 05/09/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation
import RxSwift

extension DistributedUndoManager
{
 //--------------------------------- UNDO MAIN ------------------------------------------
 
 func undoAsync() -> Completable
 {
  guard let topUndo = topUndoMain else
  {
   print(#function, "Cannot UNDO more in Main stack!")
   log(#function)
   return .empty()
  }
  
  print(#function, topUndo.name ?? "X", " in Main stack")
  
  self.lastOperation = topUndo
  
  let undoCompletable = Completable.create
  { [weak self] completableEvent in
   if (topUndo.redo == nil ) { self?.enableRedoRegistration() }
   self?.disableUndoRegistration()
   let currTopUndo = self?.topUndo
   self?.topUndo = topUndo
   topUndo.undoBlock { completableEvent(.completed) }
   self?.topUndo = currTopUndo
   self?.enableUndoRegistration()
   return Disposables.create()
  }
  
  
  topUndo.isExecuted = true
  self.topRedo = topUndo.redo
  self.topRedo?.isExecuted = false
  self.topUndo = topUndo.prev
  shiftAllTopUndosUp()
  
  
  log(#function)
  
  return undoCompletable

 }//func undoAsync() -> Completable
 
 
 func undoAllAsync() -> Completable
 {
  var comps = [Completable]()
  while let _ = topUndoMain  { comps.append(undoAsync()) }
  return .concat(comps)
 }//func undoAllAsync() -> Completable
 
 func undoAsync(_ times: Int) -> Completable
 {
  var comps = [Completable]()
  guard abs(times) != 0 else { return .empty()}
  let op = times > 0 ? { comps.append(self.undoAsync()) } : { comps.append(self.redoAsync()) }
  let top = times > 0 ? { self.topUndoMain } : { self.topRedoMain }
  for _ in 1...abs(times) where top() != nil { op() }
  return .concat(comps)
  
 }//func undoAsync(_ times: Int) -> Completable
 

 //--------------------------------- UNDO WITH TARGET ------------------------------------------
 func undoAsync(for target: NSObject) -> Completable
 {
  guard let topUndoTarget = topUndo(for: target) else
  {
   print(#function, "Cannot UNDO more for Target: [\((target as! T).name)]!")
   log(#function)
   return .empty()
  }
  
  print(#function, topUndoTarget.name ?? "X", " for Target: [\((target as! T).name)]!")
  
  self.lastOperation = topUndoTarget
  
  let undoTargetCompletable = Completable.create
  { [weak self] completableEvent in
   if ( topUndoTarget.redo == nil ) { self?.enableRedoRegistration(for: target) }
   self?.disableUndoRegistration()
   let currTopUndoTarget = self?.targetTops[target]?.topUndo
   self?.setTopUndo(for: target, to: topUndoTarget)
   topUndoTarget.undoBlock { completableEvent(.completed) }
   self?.setTopUndo(for: target, to: currTopUndoTarget)
   self?.enableUndoRegistration()
   return Disposables.create()
  }
  
  topUndoTarget.isExecuted = true
  topUndoTarget.redo?.isExecuted = false
  setTopRedo(for: target, to: topUndoTarget.redo)
  setTopUndo(for: target, to: topUndoTarget.prev(for: target))
  shiftAllTopUndosUp()
  
  
  log(#function)
  
  return undoTargetCompletable
  
 }//func undoAsync(for target: AnyHashable) -> Completable
 
 func undoAllAsync(for target: NSObject) -> Completable
 {
  var comps = [Completable]()
  while canUndo(for: target) { comps.append(undoAsync(for: target)) }
  return .concat(comps)
 }//func undoAllAsync(for target: AnyHashable) -> Completable
 
 
 func undoAsync(_ times: Int, for target: NSObject) -> Completable
 {
  var comps = [Completable]()
  guard abs(times) != 0 else { return .empty()}
  let op = times > 0 ? { comps.append(self.undoAsync(for: $0)) } : { comps.append(self.redoAsync(for: $0)) }
  let top = times > 0 ? { self.topUndo(for: $0) } : { self.topRedo(for: $0)}
  for _ in 1...abs(times) where top(target) != nil { op(target) }
  return .concat(comps)
  
 }//func undoAsync(_ times: Int, for target: AnyHashable) -> Completable
 
 //--------------------------------- REDO MAIN ------------------------------------------
 
 func redoAsync() -> Completable
 {
  guard let topRedo = topRedoMain else
  {
   print(#function, "Cannot REDO more in Main redo stack!")
   log(#function)
   return .empty()
  }
  
  print(#function, topRedo.name ?? "X", " in Main stack")
  
  self.lastOperation = topRedo
  
  let redoCompletable = Completable.create
  {[weak self] completableEvent in
   self?.disableUndoRegistration()
   topRedo.undoBlock { completableEvent(.completed) }
   self?.enableUndoRegistration()
   return Disposables.create()
  }
  
  topRedo.isExecuted = true
  self.topUndo = (topUndo == nil) ? head : topUndo?.next
  self.topUndo?.isExecuted = false
  self.topRedo = topUndo?.next?.redo
  shiftAllTopRedosDown()
  
  log(#function)
  
  return redoCompletable
  
 }//func redoAsync() -> Completable
 
 func redoAllAsync() -> Completable
 {
  var comps = [Completable]()
  while let _ = topRedoMain { comps.append(redoAsync()) }
  return .concat(comps)
 }//func uredoAllAsync() -> Completable
 
 func redoAsync(_ times: Int) -> Completable
 {
  var comps = [Completable]()
  guard abs(times) != 0 else { return .empty()}
  let op = times > 0 ? { comps.append(self.redoAsync()) } : { comps.append(self.undoAsync()) }
  let top = times > 0 ? { self.topRedoMain } : { self.topUndoMain }
  for _ in 1...abs(times) where top() != nil { op() }
  return .concat(comps)
  
 }//func redoAsync(_ times: Int) -> Completable
 
 //--------------------------------- REDO WITH TARGET ------------------------------------------
 
 func redoAsync(for target: NSObject) -> Completable
 {
  guard let topRedoTarget = topRedo(for: target) else
  {
   print(#function, "Cannot REDO more for Target: [\((target as! T).name)]!")
   log(#function)
   return .empty()
  }
  
  print(#function, topRedoTarget.name ?? "X", " for Target: [\((target as! T).name)]!")
  
  self.lastOperation = topRedoTarget
  
  let redoTargetCompletable = Completable.create
  { [weak self] completableEvent in
   self?.disableUndoRegistration()
   topRedoTarget.undoBlock { completableEvent(.completed) }
   self?.enableUndoRegistration()
   return Disposables.create()
  }
  

  let topUndoTarget = topUndo(for: target)
  topRedoTarget.isExecuted = true
  let newUndoTarget = (topUndoTarget == nil) ? head(for: target) : topUndoTarget?.next(for: target)
  newUndoTarget?.isExecuted = false
  setTopUndo(for: target, to: newUndoTarget)
  let newRedoTarget = newUndoTarget?.next(for: target)?.redo
  setTopRedo(for: target, to: newRedoTarget)
  shiftAllTopRedosDown()
 
  log(#function)
  
  return redoTargetCompletable
  
 }//func redoAsync(for target: AnyHashable) -> Completable
 
 
 func redoAllAsync(for target: NSObject) -> Completable
 {
  var comps = [Completable]()
  while canRedo(for: target) { comps.append(redoAsync(for: target)) }
  return .concat(comps)
 }//func redoAllAsync(for target: AnyHashable) -> Completable
 
 
 func redoAsync(_ times: Int, for target: NSObject) -> Completable
 {
  var comps = [Completable]()
  guard abs(times) != 0 else { return .empty()}
  let op = times > 0 ? { comps.append(self.redoAsync(for: $0)) } : { comps.append(self.undoAsync(for: $0)) }
  let top = times > 0 ? { self.topRedo(for: $0) } : { self.topUndo(for: $0)}
  for _ in 1...abs(times) where top(target) != nil { op(target) }
  return .concat(comps)
  
 }//func redoAsync(_ times: Int, for target: AnyHashable) -> Completable
 
}//extension DistributedUndoManager...
