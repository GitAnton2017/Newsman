//
//  Core Data Helpers Combine.swift
//  Newsman
//
//  Created by Anton2016 on 05.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import Combine
import CoreData

extension NSManagedObjectContext
{
 
 final func performChangesPublisher (block: @escaping () throws -> Void) -> AnyPublisher<Void, Error>
 {
  Future<Void, Error> { promise in
    self.perform { promise(Result { try block() }) }
  }.eraseToAnyPublisher()
 }//final func performChangesPublisher...
 
 
 final func persist(  block:  @escaping () -> Void) -> AnyPublisher<Void, Error>
 {
  Future<Void, Error>
  {[ unowned self ] promise in
   self.perform
   {
    block()
    promise(Result { try self.save() })
   }
  }.handleEvents(receiveCompletion: {[ unowned self ] in
   switch $0
   {
    case .failure(let error as  NSError):
     print ("{\(#function)} ERROR OCCURED WHEN SAVING BLOCK OF CHANGES TO \(self.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(self.description)\n \(error), \(error.userInfo)")
     self.rollback()
    
    case .finished:
     print ("{\(#function)} BLOCK OF CHANGES SAVED SUCCESSFULLY TO \(self.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(self.description)")
     
   }
  }).eraseToAnyPublisher()
 }//final func persist ...
 
 
 
 static func saveContextPublisher(for context: NSManagedObjectContext) -> AnyPublisher<Void, Error>
 {
  Future<Void, Error>{ promise in
    context.perform
    {
     if context.hasChanges { promise(Result { try context.save()}) }
     promise(.success(()) )
    }
   }.handleEvents(receiveCompletion: { result in
     switch result
     {
      case .failure(let error as  NSError):
       print ("{\(#function)} ERROR OCCURED WHEN SAVING ALL CHANGES TO \(context.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC <\(context.description)>\n \(error), \(error.userInfo)")
       context.rollback()
      
      case .finished:
       print ("{\(#function)} ALL CHANGES SAVED SUCCESSFULLY TO \(context.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC <\(context.description)>")
     }
    }).eraseToAnyPublisher()
 }//static func saveContextPublisher...
 
 static func saveBackgroundContextPublisher(for context: NSManagedObjectContext) -> AnyPublisher<Void, Error>
 {
  Future<Void, Error>{ promise in
    let parent = context.parent
    context.perform
    {
     if context.hasChanges { promise(Result { try context.save()}) }
     
     parent?.perform
     {
      if parent?.hasChanges ?? false { promise(Result { try parent?.save()}) }
      promise(.success(()) )
     }
    }

   }.handleEvents(receiveCompletion: { result in
     switch result
     {
      case .failure(let error as  NSError):
       print ("{\(#function)} ERROR OCCURED WHEN SAVING ALL CHANGES TO \(context.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC <\(context.description)>\n \(error), \(error.userInfo)")
       context.rollback()
      
      case .finished:
       print ("{\(#function)} ALL CHANGES SAVED SUCCESSFULLY TO \(context.concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC <\(context.description)>")
     }
    }).eraseToAnyPublisher()
 }//static func saveContextPublisher...
 
 
 final var saveContextPublisher: AnyPublisher<Void, Error>
 {
  Self.saveContextPublisher(for: self)
 }
 
 final var saveChildParentContextPublisher: AnyPublisher<Void, Error>
 {
  Deferred { [unowned self] in
   Self.saveContextPublisher(for: self)
  }.append(
   Deferred{ [unowned self] in
    Self.saveContextPublisher(for: self.parentContext)}
  ).eraseToAnyPublisher()
 }

 
 
 
}
