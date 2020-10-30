
import Foundation

extension TextSnippetViewController
{
 
 var snippetsVC: SnippetsViewController?
 {
   guard let nc = self.navigationController else { return nil }
   let count = nc.children.count
   guard count == 3 else { return nil }
   return nc.children[count - 2] as? SnippetsViewController
 }
 
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
  
  if let textSnippet = snippetsVC?.snippetsDataSource[textSnippetRestorationID] as? TextSnippet
  {
   self.textSnippet = textSnippet
   (self.navigationController?.delegate as! NCTransitionsDelegate).currentSnippet = textSnippet
   updateTextSnippet()
   
  }
  
  
 }
 
 
}
