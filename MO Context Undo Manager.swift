//
//  MO Context Undo Manager.swift
//  Newsman
//
//  Created by Anton2016 on 09/08/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import CoreData
import Foundation
import RxSwift
import RxCocoa


protocol AsyncUndoable: AnyObject
{
 var undoManager: UndoManager    { get }
 var undoCounter: [Completable]  { get set }
 var redoCounter: [Completable]  { get set }
 var disposeBag: DisposeBag      { get }
}



extension AsyncUndoable
{
 func addUndoAction(for asyncTask: @escaping ( @escaping () -> () ) -> () )
 {
  undoManager.registerUndo(withTarget: self)
  {target in
   let compTask = Completable.create
   {comp in
    asyncTask { comp(.completed) }
    return Disposables.create()
   }
  
   target.undoCounter.append(compTask)
  }
  
 }
 
 func addSingleUndoEvent(event: Completable)
 {
  undoManager.registerUndo(withTarget: self)
  {target in
   target.undoCounter.append(event)
  }
 }
 
 func addRedoAction(for asyncTask: @escaping ( @escaping () -> () ) -> () )
 {
  undoManager.registerUndo(withTarget: self)
  {target in
   let compTask = Completable.create
   {comp in
    asyncTask { comp(.completed) }
    return Disposables.create()
   }
   
   target.redoCounter.append(compTask)
  }
  
 }
 
 
 func addSingleRedoEvent(event: Completable)
 {
  undoManager.registerUndo(withTarget: self)
  {target in
   target.redoCounter.append(event)
  }
 }
 
 func addActions(asyncUndoTask: @escaping ( @escaping () -> () ) -> (),
                 asyncRedoTask: @escaping ( @escaping () -> () ) -> () )
 {
  undoManager.registerUndo(withTarget: self)
  {target in
   let compTask = Completable.create
   {comp in
    asyncUndoTask { comp(.completed) }
    return Disposables.create()
   }
   
   target.undoCounter.append(compTask)
   
   self.addRedoAction(for: asyncRedoTask)
   
  }
 }
 

 
 func addSingleEvents(undoEvent: Completable, redoEvent: Completable)
 {
  undoManager.beginUndoGrouping()
  undoManager.registerUndo(withTarget: self)
  {target in
   target.undoCounter.append(undoEvent)
   self.addSingleRedoEvent(event: redoEvent)
  }
  undoManager.endUndoGrouping()
 }
 
 
 var lastUndoEvent: Completable?
 {
  defer { undoCounter.removeAll() }
  undoManager.undo()
  return undoCounter.first
 }
 
 
 var lastRedoEvent: Completable?
 {
  defer { redoCounter.removeAll() }
  undoManager.redo()
  return redoCounter.first
 }
 
 func undoAllTasks(completion: ( () -> () )? = nil )
 {
  guard redoCounter.isEmpty else { return }
  
  undoManager.undo()
  
  Completable.zip(undoCounter)
             .observeOn(MainScheduler.instance)
             .subscribe(onCompleted: {
                        self.undoCounter.removeAll()
                        completion?()
                       }).disposed(by: disposeBag)
  

  
 }
 
 func redoAllTasks(completion: ( () -> () )? = nil )
 {
  guard undoCounter.isEmpty else { return }
  
  undoManager.redo()
  
  Completable.zip(redoCounter)
             .observeOn(MainScheduler.instance)
             .subscribe(onCompleted: {
                        self.redoCounter.removeAll()
                        completion?()
                       }).disposed(by: disposeBag)
  
  
  
  
  
 }
 
 func dropAllUndoableTasks()
 {
  undoManager.removeAllActions()
 }
 
 
 
 
}

extension AsyncUndoable where Self: NSManagedObject
{
 func addUndoAction(for contextUndoBlock: @escaping () -> () )
 {
  addUndoAction
  {completion in
   self.managedObjectContext?.perform
   {
    contextUndoBlock()
    completion()
   }
  }
 }//func addUndoAction...
 
 func addRedoAction(for contextRedoBlock: @escaping () -> () )
 {
  addRedoAction
  {completion in
   self.managedObjectContext?.perform
   {
    contextRedoBlock()
    completion()
   }
  }
 }//func addRedoAction...
 
 func addActions(contextUndoBlock: @escaping () -> (),
                 contextRedoBlock: @escaping () -> () )
 {
  addActions(asyncUndoTask: {completion in
              self.managedObjectContext?.perform { contextUndoBlock(); completion() }
             },
             asyncRedoTask: {completion in
              self.managedObjectContext?.perform { contextRedoBlock(); completion() }
             })
  
 }//func addActions...
 
 func undoContext()
 {
  undoAllTasks { self.managedObjectContext?.saveIfNeeded() }
 }
 
 func redoContext()
 {
  redoAllTasks { self.managedObjectContext?.saveIfNeeded() }
 }

}



