
import Foundation
import CoreData

extension NSManagedObjectContext
{
 private func executeBlockAndSaveContext (block: @escaping () -> Void, completion: ((Bool) -> Void)? = nil)
 {
  block()
  do
  {
   try self.save()
   completion?(true)
   print ("CHAGES SAVED SUCCESSFULLY TO MOC \(self.description)")
  }
  catch
  {
   let nserror = error as NSError
   print ("ERROR OCCURED WHEN SAVING CHAGES TO MOC \(self.description)\n \(nserror), \(nserror.userInfo)")
   self.rollback()
   completion?(false)
  }
 }
 
 
 func persist( block: @escaping () -> Void)
 {
  perform
  {
    self.executeBlockAndSaveContext(block: block)
  }
 }
 
 func persist( block: @escaping () -> Void, completion: ((Bool) -> Void)? = nil)
 {
  perform
  {
   self.executeBlockAndSaveContext(block: block, completion: completion)
  }
 }
 
 func persistAndWait( block: @escaping () -> Void)
 {
  performAndWait
  {
    self.executeBlockAndSaveContext(block: block)
  }
 }
 
 func persistAndWait( block: @escaping () -> Void, completion: ((Bool) -> Void)? = nil)
 {
  performAndWait
  {
   self.executeBlockAndSaveContext(block: block, completion: completion)
  }
 }
 
}
