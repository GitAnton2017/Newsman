//
//  Core Data Helpers RX.swift
//  Newsman
//
//  Created by Anton2016 on 05.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import RxSwift
import CoreData


extension NSManagedObjectContext
{
 final func performCnangesCompletable (block: @escaping () throws -> Void) -> Completable
 {
  Completable.create { promise in
   self.perform {
    switch (Result{ try block() })
    {
     case .success() : promise(.completed)
     case .failure(let error as NSError): promise(.error(error))
    }
   }
   return Disposables.create()
  }
 }//final func performCnangesCompletable...
 
 
 
 final func persist( block:  @escaping () -> Void)  -> Completable
 {
  Completable.create{ promise in
   self.perform {
    block()
    switch (Result{ try self.save() })
    {
     case .success() :
      promise(.completed)
      print ("{\(#function)} BLOCKED CHANGES SAVED SUCCESSFULLY TO \(self.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(self.description)")
    
     case .failure(let error as NSError):
      promise(.error(error))
      self.rollback()
      print ("{\(#function)} ERROR OCCURED WHEN SAVING BLOCKED CHAGES TO \(self.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(self.description)\n \(error), \(error.userInfo)")
    }
   }
   return Disposables.create()
  }
 }//final func persist( block: ....
 
 
 static func saveContextCompletable(for context: NSManagedObjectContext) -> Completable
 {
  Completable.create { promise in
   context.perform
   {
    if (context.hasChanges) {
     switch (Result{ try context.save() })
     {
      case .success(): promise(.completed)
        print ("{\(#function)} ALL CHANGES SAVED SUCCESSFULLY TO \(context.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC <\(context.description)>")
      
      case .failure(let error as NSError):
       promise(.error(error))
       context.rollback()
       print ("{\(#function)} ERROR OCCURED WHEN SAVING ALL CHANGES TO \(context.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(context.description)\n \(error), \(error.userInfo)")
     }
    }
    else
    {
     promise(.completed)
    }
   }
   return Disposables.create()
  }
 }//static func saveContextCompletable...

 
 final func persistAllChanges() -> Completable
 {
  Self.saveContextCompletable(for: self)
 }//final func persistAllChanges...
 
 
 
 static func saveContextCompletable(child: NSManagedObjectContext, parent: NSManagedObjectContext) ->  Completable
 {
  Completable.create
  {promise in
   child.perform
   {
    guard child.hasChanges else { promise(.completed); return }
    
    do
    {
     try child.save()
     print ("{\(#function)} ALL CHANGES SAVED SUCCESSFULLY TO CHILD MOC <\(child.description)>")
    }
    catch
    {
     let saveError = error as NSError
     print ("{\(#function)} ERROR SAVING ALL CHANGES TO CHILD MOC \(child.description)\n \(error), \(saveError.userInfo)")
     promise(.error(error))
     child.rollback()
    }
    
    parent.performAndWait
    {
     guard parent.hasChanges else { promise(.completed); return }
  
     do
     {
      try parent.save()
      print ("{\(#function)} ALL CHAGES SAVED SUCCESSFULLY TO PARENT MOC <\(parent.description)>")
      promise(.completed)
     }
     catch
     {
      let saveError = error as NSError
      print ("{\(#function)} ERROR SAVING ALL CHANGES TO PARENT MOC \(parent.description)\n \(error), \(saveError.userInfo)")
      promise(.error(error))
      parent.rollback()
      
     }
     
    }
    
   }
   return Disposables.create()
  }
 }
 
}
