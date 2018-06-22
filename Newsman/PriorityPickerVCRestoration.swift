
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
   let snippetsVC = nc.childViewControllers[nc.childViewControllers.count - 3] as? SnippetsViewController,
   let ID = self.editedSnippetRestorationID
  {
   
   self.editedSnippet = snippetsVC.snippetsDataSource.items.first{$0.id!.uuidString == ID}
   
   switch nc.childViewControllers[nc.childViewControllers.count - 2]
   {
    case let editedSnippetVC as PhotoSnippetViewController:
     editedSnippetVC.photoSnippet = self.editedSnippet as! PhotoSnippet
    case let editedSnippetVC as TextSnippetViewController:
     editedSnippetVC.textSnippet = self.editedSnippet as! TextSnippet
    default: break
    
   }
   
   updateEditedSnippet()
  }
   

 }
}
