
import Foundation

extension TextSnippetViewController
{
 override func encodeRestorableState(with coder: NSCoder)
 {
  super.encodeRestorableState(with: coder)
  coder.encode(self.textSnippet.id?.uuidString, forKey: "photoSnippetID")
 }
 
 override func decodeRestorableState(with coder: NSCoder)
 {
  super.decodeRestorableState(with: coder)
  self.textSnippetRestorationID = coder.decodeObject(forKey: "photoSnippetID") as? String

 }
 
 override func applicationFinishedRestoringState()
 {
  
  if let nc = self.navigationController,
   let snippetsVC = nc.childViewControllers[nc.childViewControllers.count - 2] as? SnippetsViewController,
   let ID = self.textSnippetRestorationID,
   let textSnippet = snippetsVC.snippetsDataSource.currentFRC[ID] as? TextSnippet
  {
   
   self.textSnippet = textSnippet
   
   (self.navigationController?.delegate as! NCTransitionsDelegate).currentSnippet = textSnippet
   
   updateTextSnippet()
   
  }
  
  
 }
 
 
}
