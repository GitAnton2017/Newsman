
/*
Every view controller with a restoration identifier will receive a call to encodeRestorableStateWithCoder(_:)
 of the UIStateRestoring protocol when the app is saved. Additionally, the view controller will receive a call to decodeRestorableStateWithCoder(_:) when the app is restored.
 
 To complete the restoration flow, you need to add logic to encode and decode your view controllers.
 While this part of the process is probably the most time-consuming, the concepts are relatively straightforward.
 
 You’d usually write an extension to add conformance to a protocol, but UIKit automatically registers view controllers to conform to UIStateRestoring — you merely need to override the appropriate methods.
*/


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
  let bar = self.navigationItem.searchController?.searchBar
  //bar?.showsScopeBar = false
  bar?.isHidden = true
  bar?.scopeButtonTitles = self.snippetType?.localizedSearchScopeBarTitles
  bar?.sizeToFit()
  
 }
 
}
