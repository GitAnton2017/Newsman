
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
  
  if let nc = navigationController,
     let snippetsVC = nc.children[nc.children.count - 2] as? SnippetsViewController,
     let ID = photoSnippetRestorationID,
     let photoSnippet = snippetsVC.snippetsDataSource.currentFRC[ID] as? PhotoSnippet
  {
   
   self.photoSnippet = photoSnippet
   currentFRC = snippetsVC.snippetsDataSource.currentFRC
   (navigationController?.delegate as! NCTransitionsDelegate).currentSnippet = photoSnippet
 
   updatePhotoSnippet()
  }
  
  
 }
 
 
}
