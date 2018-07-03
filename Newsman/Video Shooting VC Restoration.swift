import Foundation

extension VideoShootingViewController
{
 override func encodeRestorableState(with coder: NSCoder)
 {
  super.encodeRestorableState(with: coder)
  coder.encode(self.videoSnippetID, forKey: "videoSnippetID")
 }
 
 override func decodeRestorableState(with coder: NSCoder)
 {
  super.decodeRestorableState(with: coder)
  self.videoSnippetID = coder.decodeObject(forKey: "videoSnippetID") as? String
  
 }
 
 override func applicationFinishedRestoringState()
 {
 }

}
