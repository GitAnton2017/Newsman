

import Foundation

extension SnippetsViewController
{
 override func decodeRestorableState(with coder: NSCoder)
 {
  super.decodeRestorableState(with: coder)
  self.menuTitle = coder.decodeObject(forKey: "menuTitle") as? String
  self.createBarButtonTitle = coder.decodeObject(forKey: "createBarButtonTitle") as? String
  
  if let snippetTypeStr = coder.decodeObject(forKey: "snippetType") as? String
  {
   self.snippetType = SnippetType(rawValue: snippetTypeStr)
  }
  
 }
 
 override func encodeRestorableState(with coder: NSCoder)
 {
  super.encodeRestorableState(with: coder)
  coder.encode(self.menuTitle, forKey: "menuTitle")
  coder.encode(self.createBarButtonTitle, forKey: "createBarButtonTitle")
  coder.encode(self.snippetType.rawValue, forKey: "snippetType")
 }
 
 
 override func applicationFinishedRestoringState()
 {
  updateSnippets()
 }
 
}
