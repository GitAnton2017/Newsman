//
//  Undoable Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 04/09/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import Foundation

import struct RxSwift.Completable
import class RxSwift.DisposeBag
import class RxSwift.PublishSubject
import class RxSwift.MainScheduler

protocol UndoableItem
{
 var canUndo: Bool { get }
 func undo()
 func undo(_ times: Int)
 func undoAll()
 
 var canRedo: Bool { get }
 func redo()
 func redo(_ times: Int)
 func redoAll()
 
}

protocol MultipleTargetUndoable
{
 var target: NSObject? { get }
 var undoer: DistributedUndoManager { get }
 var undoQueue: PublishSubject<Completable> { get }
 var disposeBag: DisposeBag { get }
}


extension MultipleTargetUndoable where Self: Hashable
{
 func subscribeForUndo() -> PublishSubject<Completable>
 {
  let undoQueue = PublishSubject<Completable>()
  undoQueue.concatMap{$0}
           .observeOn(MainScheduler.instance)
           .subscribe()
           .disposed(by: disposeBag)
  
  return undoQueue
 }
 
 //--------------------------------- UNDO ------------------------------------------
 
 var canUndo:     Bool { return undoer.canUndo(for: target) }
 var canUndoMain: Bool { return undoer.topUndoMain != nil   }
 
 func undo()
 {
  if target == nil
  {
   //undoer.undo()
   undoQueue.onNext(undoer.undoAsync())
  }
  else
  {
   //undoer.undo(for: target!)
   undoQueue.onNext(undoer.undoAsync(for: target!))
  }
 }//func undo()
 
 func undoAll()
 {
  if target == nil
  {
   undoQueue.onNext(undoer.undoAllAsync())
  }
  else
  {
   undoQueue.onNext(undoer.undoAllAsync(for: target!))
  }
 }// undoAll()...
 
 func undo(_ times: Int)
 {
  if target == nil
  {
   undoQueue.onNext(undoer.undoAsync(times))
  }
  else
  {
   undoQueue.onNext(undoer.undoAsync(times, for: target!))
  }
 }//func undo(_ times: Int)...
 
 //--------------------------------- REDO ------------------------------------------
 
 var canRedo:     Bool { return undoer.canRedo(for: target) }
 var canRedoMain: Bool { return undoer.topRedoMain != nil   }
 
 func redo()
 {
  if target == nil
  {
   //undoer.redo()
   undoQueue.onNext(undoer.redoAsync())
  }
  else
  {
  // undoer.redo(for: target!)
   undoQueue.onNext(undoer.redoAsync(for: target!))
  }
 }//func redo()
 
 func redoAll()
 {
  if target == nil
  {
   undoQueue.onNext(undoer.redoAllAsync())
  }
  else
  {
   undoQueue.onNext(undoer.redoAllAsync(for: target!))
  }
 }// redoAll()...
 
 func redo(_ times: Int)
 {
  if target == nil
  {
   undoQueue.onNext(undoer.redoAsync(times))
  }
  else
  {
   undoQueue.onNext(undoer.redoAsync(times, for: target!))
  }
 }//func redo(_ times: Int)...
 
}
