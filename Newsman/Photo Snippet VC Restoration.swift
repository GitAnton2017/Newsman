
import Foundation

extension PhotoSnippetViewController
{
 override func encodeRestorableState(with coder: NSCoder)
 {
  super.encodeRestorableState(with: coder)
  coder.encode(self.photoSnippet.id?.uuidString, forKey: "photoSnippetID")
 }
 
 override func decodeRestorableState(with coder: NSCoder)
 {
  super.decodeRestorableState(with: coder)
  self.photoSnippetRestorationID = coder.decodeObject(forKey: "photoSnippetID") as? String

 }
 
 override func applicationFinishedRestoringState()
 {
  
  if let nc = self.navigationController,
     let snippetsVC = nc.childViewControllers[nc.childViewControllers.count - 2] as? SnippetsViewController,
     let ID = self.photoSnippetRestorationID,
     let photoSnippet = snippetsVC.snippetsDataSource.currentFRC[ID] as? PhotoSnippet
  {
   
   self.photoSnippet = photoSnippet
   (self.navigationController?.delegate as! NCTransitionsDelegate).currentSnippet = photoSnippet
 
   updatePhotoSnippet()
  }
  
  
 }
 
 
}
