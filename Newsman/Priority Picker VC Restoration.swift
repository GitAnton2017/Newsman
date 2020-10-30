
import Foundation

extension PriorityPickerViewController
{
 override func encodeRestorableState(with coder: NSCoder)
 {
  super.encodeRestorableState(with: coder)
  coder.encode(self.editedSnippet.id?.uuidString, forKey: "editedSnippetID")
 }
 
 override func decodeRestorableState(with coder: NSCoder)
 {
  super.decodeRestorableState(with: coder)
  self.editedSnippetRestorationID = coder.decodeObject(forKey: "editedSnippetID") as? String
  
 }
 
 override func applicationFinishedRestoringState()
 {
  if let nc = self.navigationController,
     let snippetsVC = nc.children[nc.children.count - 3] as? SnippetsViewController,
     let ID = self.editedSnippetRestorationID,
     let editedSnippet = snippetsVC.snippetsDataSource.currentFRC[ID]
  {
  
   self.editedSnippet = editedSnippet
   
   switch nc.children[nc.children.count - 2]
   {
    case let editedSnippetVC as PhotoSnippetViewController:
     editedSnippetVC.photoSnippet = editedSnippet as? PhotoSnippet
    case let editedSnippetVC as TextSnippetViewController:
     editedSnippetVC.textSnippet = editedSnippet as? TextSnippet
    default: break
    
   }
   
   updateEditedSnippet()
  }
   

 }
}
