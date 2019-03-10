
import Foundation
import UIKit

struct Defaults
{
 static let groupTypeKey = "groupTypeKey"
 static let searchScopeIndexKey = "searchScopeIndexKey"
 static let settings:  [String : Any] =
 [
  groupTypeKey        : GroupSnippets.byPriority.rawValue,
  searchScopeIndexKey : 0
 ]
 
 
 
 static func groupType(for type: SnippetType) -> GroupSnippets
 {
  guard let settings = UserDefaults.standard.dictionary(forKey: type.rawValue) else { return .plainList }
  guard let grouping = settings[groupTypeKey] as? String else { return .plainList }
  return GroupSnippets(rawValue: grouping) ?? .plainList
 }
 
 static func setGroupType(groupType: GroupSnippets, for type: SnippetType)
 {
  var settings = UserDefaults.standard.dictionary(forKey: type.rawValue) ?? [ : ]
  settings[groupTypeKey] = groupType.rawValue
  UserDefaults.standard.set(settings, forKey: type.rawValue)
 }
 
 static func searchScopeIndex (for type: SnippetType) -> Int
 {
  guard let settings = UserDefaults.standard.dictionary(forKey: type.rawValue) else { return 0 }
  guard let index = settings[searchScopeIndexKey] as? Int else { return 0 }
  return index
 }
 
 static func setSearchScopeIndex (index: Int, for type: SnippetType)
 {
  var settings = UserDefaults.standard.dictionary(forKey: type.rawValue) ?? [ : ]
  settings[searchScopeIndexKey] = index
  UserDefaults.standard.set(settings, forKey: type.rawValue)
 }
 
 
}

extension AppDelegate
{
 
 
 func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool
 {
  return true
 }
 
 
 
 func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool
 {
  return true
 }
 
 
 func registerDefaults()
 {
  let pairs = SnippetType.allCases.map{ ($0.rawValue, Defaults.settings) }
  let defaults = Dictionary(uniqueKeysWithValues: pairs)
  UserDefaults.standard.register(defaults: defaults)
 }

}

