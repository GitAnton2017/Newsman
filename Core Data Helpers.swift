
import UIKit
import CoreData

extension NSManagedObjectContext
{
 
 final func performChanges (block: @escaping () throws -> Void, handler: ((Result<Void, Error>) -> Void)?)
 {
  perform { handler?(Result { try block() }) }
 }//final func performChangesPublisher...
 
 final func performChangesAndWait (block: @escaping () throws -> Void, handler: ((Result<Void, Error>) -> Void)?)
 {
  performAndWait { handler?(Result { try block() }) }
 }//final func performChangesPublisher...
 
 var backgroundContext: NSManagedObjectContext
 {
  let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
  context.persistentStoreCoordinator = self.persistentStoreCoordinator
  return context
 }
 
 func saveIfNeeded() // save all main queue context changes as needed.
 {
  guard hasChanges else { return } // if it really needs saving proceed...
  
  do {
   try save()
   print ("{\(#function)} ALL NEEDED CONTEXT CHANGES SAVED SUCCESSFULLY TO \(concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(description)")
  }
  catch
  {
   let nserror = error as NSError
   print ("{\(#function)} ERROR OCCURED WHEN SAVING ALL NEEDED CHAGES TO \(concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(description)\n \(nserror), \(nserror.userInfo)")
  }
 }
 
 final var parentContext: NSManagedObjectContext
 {
  (UIApplication.shared.delegate as! AppDelegate).backgroundContext
 }
 
 private final func executeBlockAndSaveContext (block: () -> Void, completion: ((Bool) -> Void)? = nil)
 {
  block()
  do {
   try save()
   completion?(true)
   print ("{\(#function)} BLOCK OF CHAGES SAVED SUCCESSFULLY TO \(concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(description)")
  }
  catch
  {
   let nserror = error as NSError
   print ("{\(#function)} ERROR OCCURED WHEN SAVING BLOCK OF CHAGES TO \(concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(description)\n \(nserror), \(nserror.userInfo)")
   self.rollback()
   completion?(false)
  }
 
 }

 
 private final func executeBlockAndSaveContext (block: () -> Void, handler: ((Result<Void, Error>) -> Void)?)
 {
  block()
  do {
   try save()
   handler?(.success(()))
   print ("{\(#function)} BLOCK OF CHANGES SAVED SUCCESSFULLY TO \(concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") QUEUE MOC \(description)")
  }
  catch
  {
   let nserror = error as NSError
   print ("{\(#function)} ERROR OCCURED WHEN SAVING BLOCK OF CHANGES TO \(concurrencyType == .mainQueueConcurrencyType ? "MAIN" : "PRIVATE") MOC \(description)\n \(nserror), \(nserror.userInfo)")
   rollback()
   handler?(.failure(error))
  }

 }
 
 
 
 final func persist( block:  @escaping () -> Void) -> Void
 {
  perform { self.executeBlockAndSaveContext(block: block) }
 }
 
 
 
 func persist( block: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) -> Void
 {
  perform { self.executeBlockAndSaveContext(block: block, completion: completion) }
 }
 
 
 func persist( _ block: @escaping () -> Void, handler: ((Result<Void, Error>) -> Void)?) -> Void
 {
  perform { self.executeBlockAndSaveContext(block: block, handler: handler) }
 }
 
 func persistAndWait( block: () -> Void)
 {
  performAndWait { executeBlockAndSaveContext(block: block) }
 }
 
 final func persistAndWait( block:  () -> Void, completion: ((Bool) -> Void)? = nil)
 {
  performAndWait { executeBlockAndSaveContext(block: block, completion: completion) }
 }

 
 
}




