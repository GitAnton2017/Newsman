
import Foundation
import CoreData
import UIKit
import CoreLocation


protocol StringLocalizable
{
 var localizedString: String {get}
}

protocol AllCasesSelectorRepresentable: StringLocalizable, CaseIterable
{
 typealias ActionType  = (Self) -> Void

 static func caseSelectorController(title: String,
                                    message: String,
                                    style: UIAlertController.Style,
                                    block: @escaping ActionType) -> UIAlertController
}

extension AllCasesSelectorRepresentable
{
 static func caseSelectorController (title: String, message: String,
                                     style: UIAlertController.Style,
                                     block: @escaping ActionType) -> UIAlertController
 {
  let selector = UIAlertController(title: title, message: message, preferredStyle: style)
  
  Self.allCases.map
  {priority in
   UIAlertAction(title: priority.localizedString, style: .default){ _ in block(priority)}
  }.forEach{selector.addAction($0)}
  
  let cancelAction = UIAlertAction(title: Localized.cancelAction, style: .cancel, handler: nil)
  
  selector.addAction(cancelAction)
  
  return selector
  
 }
}

struct Sort
{
 static let byDateDes =        NSSortDescriptor(key: #keyPath(BaseSnippet.date),          ascending: false)
 static let byTagAsc =         NSSortDescriptor(key: #keyPath(BaseSnippet.tag),           ascending: true)
 static let byLocationAsc =    NSSortDescriptor(key: #keyPath(BaseSnippet.location),      ascending: true)
 static let byPriorityAsc =    NSSortDescriptor(key: #keyPath(BaseSnippet.priorityIndex), ascending: true)
 static let bySnippetTypeAsc = NSSortDescriptor(key: #keyPath(BaseSnippet.type),          ascending: true)
 static let byAlphabetAsc =    NSSortDescriptor(key: #keyPath(BaseSnippet.alphaIndex),    ascending: true)
 static let byDateIndexAsc =   NSSortDescriptor(key: #keyPath(BaseSnippet.dateIndex),     ascending: true)
 static let byTextAsc =        NSSortDescriptor(key: #keyPath(TextSnippet.text),          ascending: true)
}

class SnippetDates
{
 var calendar: Calendar {return Calendar(identifier: .gregorian)}
 var today:    Date     {return Date()}
 
 var hour:     Int      {return calendar.component(.hour,    from: today)}
 var day:      Int      {return calendar.component(.day,     from: today)}
 var month:    Int      {return calendar.component(.month,   from: today)}
 var year:     Int      {return calendar.component(.year,    from: today)}
 var weekday:  Int      {return calendar.component(.weekday, from: today)}
 
 var _boftd:   Date     {return calendar.date(from: DateComponents(calendar: calendar,
                                              timeZone: TimeZone.current, era: nil,
                                              year: year, month: month, day: day,
                                              hour: nil, minute: nil, second: nil, nanosecond: nil,
                                              weekday: nil, weekdayOrdinal: nil, quarter: nil,
                                              weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil))! }
 
 lazy var boftd: Date  =  {return _boftd}()
 lazy var bofnd: Date  =  {return _bofnd}()
 lazy var bofld: Date  =  {return _bofld}()
 lazy var boftw: Date  =  {return _boftw}()
 lazy var bofnw: Date  =  {return _bofnw}()
 lazy var boflw: Date  =  {return _boflw}()
 lazy var boftm: Date  =  {return _boftm}()
 lazy var bofnm: Date  =  {return _bofnm}()
 lazy var boflm: Date  =  {return _boflm}()
 lazy var bofty: Date  =  {return _bofty}()
 lazy var bofny: Date  =  {return _bofny}()
 
 func updateDatesWhenBecomeActive()  //update date filters bounds taking current system date
 // when app returns from background mode and become active again!
 {
  boftd  =   _boftd  // the beginning of this day (today)
  bofnd  =   _bofnd  // the beginning of the next day (+ 24h) (tomorrow)
  bofld  =   _bofld  // the beginning of the last day (yesterday) (- 1D)
  boftw  =   _boftw
  bofnw  =   _bofnw
  boflw  =   _boflw
  boftm  =   _boftm
  bofnm  =   _bofnm
  boflm  =   _boflm
  bofty  =   _bofty
  bofny  =   _bofny
 }
 
 var _bofnd:    Date     {return calendar.date(byAdding: .hour, value: 24,           to: _boftd)! }
 var _bofld:    Date     {return calendar.date(byAdding: .day,  value: -1,           to: _boftd)! }
 var _boftw:    Date     {return calendar.date(byAdding: .day,  value: -weekday + 1, to: _bofnd)! }
 var _bofnw:    Date     {return calendar.date(byAdding: .day,  value: 7,            to: _boftw)! }
 var _boflw:    Date     {return calendar.date(byAdding: .day,  value: -7,           to: _boftw)! }
 
 var _boftm:    Date     {return calendar.date(from: DateComponents(calendar: calendar,
                                                     timeZone: TimeZone.current, era: nil,
                                                     year: year, month: month, day: 1,
                                                     hour: nil, minute: nil, second: nil, nanosecond: nil,
                                                     weekday: nil, weekdayOrdinal: nil, quarter: nil,
                                                     weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil))! }
 
 var _bofnm:    Date     {return calendar.date(byAdding: .month, value:  1,          to: _boftm)! }
 var _boflm:    Date     {return calendar.date(byAdding: .month, value: -1,          to: _boftm)! }
 
 var _bofty:    Date     {return calendar.date(from: DateComponents(calendar: calendar,
                                                     timeZone: TimeZone.current,era: nil,
                                                     year: year, month: 1, day: 1,
                                                     hour: nil, minute: nil, second: nil, nanosecond: nil,
                                                     weekday: nil, weekdayOrdinal: nil, quarter: nil,
                                                     weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil))! }
 
 var _bofny:    Date     {return calendar.date(byAdding: .year,   value:  1,  to: _bofty)! }
 
 
 typealias DatePredicate = (title: String, predicate: (BaseSnippet) -> Bool)
 
 lazy var datePredicates : [DatePredicate] = { predicates }()
 
 var predicates : [DatePredicate]
 {
  return [
          ("0_For Today",         {$0.snippetDate >= self.boftd && $0.snippetDate < self.bofnd}),
          ("1_For Yesterday",     {$0.snippetDate >= self.bofld && $0.snippetDate < self.boftd}),
          ("2_For This Week",     {$0.snippetDate >= self.boftw && $0.snippetDate < self.bofnd}),
          ("3_For Last Week",     {$0.snippetDate >= self.boflw && $0.snippetDate < self.boftw}),
          ("4_For This Month",    {$0.snippetDate >= self.boftm && $0.snippetDate < self.bofnd}),
          ("5_For Last Month",    {$0.snippetDate >= self.boflm && $0.snippetDate < self.boftm}),
          ("7_For This Year",     {$0.snippetDate >= self.bofty && $0.snippetDate < self.bofnd}),
          ("8_For Last Year and earlier on",                      {$0.snippetDate < self.bofty})
         ]
 }

 
}

enum SnippetType: String, AllCasesSelectorRepresentable, Codable
{
 var localizedString: String {return NSLocalizedString(rawValue, comment: rawValue)}
 
 private static let presentingVCTypesMap: [SnippetType : SnippetsRepresentable.Type] =
 [
  .photo: PhotoSnippetViewController.self,
  .video: PhotoSnippetViewController.self
 ]
 
 var presenterType:SnippetsRepresentable.Type {return SnippetType.presentingVCTypesMap[self]!}
 
 case text   = "TextSnippet"
 case photo  = "PhotoSnippet"
 case video  = "VideoSnippet"
 case audio  = "AudioSnippet"
 case sketch = "SketchSnippet"
 case report = "Report"
 //*******************************
 case undefined //error case!!!
 
 var localizedSearchScopeBarTitles: [String]
 {
  return SnippetType.searchScopeBarTitles[self]!
 }
 
 
 private static let baseScopeBarTitles: [String] = [ Localized.overallScope,
                                                     Localized.nameScope,
                                                     Localized.dateScope,
                                                     Localized.priorityScope,
                                                     Localized.LocationScope ]

 private static let searchScopeBarTitles : [SnippetType : [String] ] =
 [
  .text   : baseScopeBarTitles + [Localized.contentScope],
  .photo  : baseScopeBarTitles,
  .video  : baseScopeBarTitles,
  .audio  : baseScopeBarTitles,
  .sketch : baseScopeBarTitles,
  .report : baseScopeBarTitles
 ]
 
 
 private static let baseScopeBarSortDescriptors: [[NSSortDescriptor]] =
 [
  [Sort.byTagAsc,      Sort.byDateDes,      Sort.byPriorityAsc,     Sort.byLocationAsc] /* ScopeIndex = 0 */,
  [Sort.byTagAsc,      Sort.byDateDes,      Sort.byPriorityAsc,     Sort.byLocationAsc] /* ScopeIndex = 1 */,
  [Sort.byDateDes,     Sort.byTagAsc,       Sort.byPriorityAsc,     Sort.byLocationAsc] /* ScopeIndex = 2 */,
  [Sort.byPriorityAsc, Sort.byDateDes,      Sort.byTagAsc,          Sort.byLocationAsc] /* ScopeIndex = 3 */,
  [Sort.byLocationAsc, Sort.byDateDes,      Sort.byTagAsc,          Sort.byPriorityAsc] /* ScopeIndex = 4 */,
 ]
 
 private static let textScopeBarSortDescriptors: [[NSSortDescriptor]] =
  [
   [Sort.byTagAsc,      Sort.byDateDes,      Sort.byPriorityAsc,     Sort.byLocationAsc,  Sort.byTextAsc], //0
   [Sort.byTagAsc,      Sort.byDateDes,      Sort.byPriorityAsc,     Sort.byLocationAsc,  Sort.byTextAsc], //1
   [Sort.byDateDes,     Sort.byTagAsc,       Sort.byPriorityAsc,     Sort.byLocationAsc,  Sort.byTextAsc], //2
   [Sort.byPriorityAsc, Sort.byDateDes,      Sort.byTagAsc,          Sort.byLocationAsc,  Sort.byTextAsc], //3
   [Sort.byLocationAsc, Sort.byDateDes,      Sort.byTagAsc,          Sort.byPriorityAsc,  Sort.byTextAsc], //4
   [Sort.byTextAsc, Sort.byDateDes,      Sort.byTagAsc,          Sort.byPriorityAsc,  Sort.byLocationAsc], //5
   
 ]
 
 private static let scopeBarSortDescriptors : [SnippetType : [[NSSortDescriptor]] ] =
 [
   .text   : textScopeBarSortDescriptors,
   .photo  : baseScopeBarSortDescriptors,
   .video  : baseScopeBarSortDescriptors,
   .audio  : baseScopeBarSortDescriptors,
   .sketch : baseScopeBarSortDescriptors,
   .report : baseScopeBarSortDescriptors
 ]
 
 var scopeSearchSortDescriptors: [[NSSortDescriptor]]
 {
  return SnippetType.scopeBarSortDescriptors[self]!
 }

}

enum SnippetPriority: String, AllCasesSelectorRepresentable
{
 var localizedString: String {return NSLocalizedString(rawValue, comment: rawValue)}
 
 static let priorityColorMap : [SnippetPriority: UIColor] =
 [
   .hottest : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 1.00),
   .hot     : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.80),
   .high    : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.70),
   .normal  : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.30),
   .medium  : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.20),
   .low     : UIColor(red: 0.7, green: 0.1, blue: 0.0, alpha: 0.10)
 ]
 
 static let priorityFilters : [(title: String, predicate: (BaseSnippet) -> Bool)] =
  [
   (SnippetPriority.hottest.rawValue, {$0.snippetPriority == .hottest  }),
   (SnippetPriority.hot.rawValue,     {$0.snippetPriority == .hot      }),
   (SnippetPriority.high.rawValue,    {$0.snippetPriority == .high     }),
   (SnippetPriority.normal.rawValue,  {$0.snippetPriority == .normal   }),
   (SnippetPriority.medium.rawValue,  {$0.snippetPriority == .medium   }),
   (SnippetPriority.low.rawValue,     {$0.snippetPriority == .low      })
 ]
 
 static let prioritySectionsMap: [SnippetPriority: Int] =
 [
   .hottest : 0,  //priority index = 0_hottest
   .hot :     1,  //priority index = 1_hot
   .high :    2,  //priority index = 2_high
   .normal :  3,  //priority index = 3_normal
   .medium :  4,  //priority index = 4_medium
   .low :     5   //priority index = 5_low
 ]
 
 static let priorities: [SnippetPriority] = [.hottest , .hot, .high, .normal, .medium, .low]
 
 var color: UIColor {return SnippetPriority.priorityColorMap[self]!}
 
 var section: Int {return SnippetPriority.prioritySectionsMap[self]!}
 
 
 
 static let strings: [String] =
 [
   SnippetPriority.hottest.rawValue,
   SnippetPriority.hot.rawValue,
   SnippetPriority.high.rawValue,
   SnippetPriority.normal.rawValue,
   SnippetPriority.medium.rawValue,
   SnippetPriority.low.rawValue,
 ]
 
 case hottest =  "Hottest"
 case hot     =  "Hot"
 case high    =  "High"
 case normal  =  "Normal"
 case medium  =  "Medium"
 case low     =  "Low"

 
}

enum SnippetStatus: String, AllCasesSelectorRepresentable
{
 var localizedString: String {return NSLocalizedString(rawValue, comment: rawValue)}
 
 case new         =   "New"
 case old         =   "Old"
 case archived    =   "Archived"
}

enum GroupSnippets: String,  AllCasesSelectorRepresentable
{
 
 var localizedString: String {return NSLocalizedString(rawValue, comment: rawValue)}
 
 case byPriority     =  "By Snippet Priority"
 case byDateCreated  =  "By Snippet Date Created"
 case alphabetically =  "Alphabetically"
 case bySnippetType  =  "By Snippet Type"
 case plainList      =  "Plain List"
 case byLocation     =  "By Snippet Location"

 
 static let groupingTypes: [GroupSnippets] =
 [
   byPriority, byDateCreated, alphabetically, bySnippetType, plainList, byLocation
 ]
 
 static let groupingBitsMap: [GroupSnippets : Int16] =
 [
   byPriority :      0b0000000_1,
   byDateCreated:    0b000000_10,
   alphabetically:   0b00000_100,
   bySnippetType:    0b0000_1000,
   plainList:        0b000_10000,
   byLocation:       0b00_100000
 ]
 
 static let groupingKeyPath: [GroupSnippets : String] =
 [
   byPriority :      #keyPath(BaseSnippet.priorityIndex),
   byDateCreated:    #keyPath(BaseSnippet.dateIndex),
   alphabetically:   #keyPath(BaseSnippet.alphaIndex),
   bySnippetType:    #keyPath(BaseSnippet.type),
   byLocation:       #keyPath(BaseSnippet.location)
 ]
 
 func checkMask(for value: Int16) -> Bool
 {
  let mask = GroupSnippets.groupingBitsMap[self]!
  return mask & value == mask
 }
}
