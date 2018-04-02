
import Foundation
import CoreData

extension NSManagedObjectContext
{
 private func executeBlockAndSaveContext (block: @escaping () -> Void)
 {
  block()
  do
  {
   try self.save()
   print ("CHAGES SAVED SUCCESSFULLY TO MOC \(self.description)")
  }
  catch
  {
   let nserror = error as NSError
   print ("ERROR OCCURED WHEN SAVING CHAGES TO MOC \(self.description)\n \(nserror), \(nserror.userInfo)")
   self.rollback()
  }
 }
 
 func persist( block: @escaping () -> Void)
 {
  perform {self.executeBlockAndSaveContext(block: block)}
 }
 
 func persistAndWait( block: @escaping () -> Void)
 {
  performAndWait{self.executeBlockAndSaveContext(block: block)}
 }
 
}
