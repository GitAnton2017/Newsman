
import Foundation
import CoreData
import UIKit
import CoreLocation


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

struct SnippetDates
{
 static let calendar = Calendar(identifier: .gregorian)
 static let today = Date()
 
 static let hour    = calendar.component(.hour, from: today)
 static let day     = calendar.component(.day, from: today)
 static let month   = calendar.component(.month, from: today)
 static let year    = calendar.component(.year, from: today)
 static let weekday = calendar.component(.weekday, from: today)
 
 static let boftd   = calendar.date(from: DateComponents(calendar: calendar,
                                                         timeZone: TimeZone.current,
                                                         era: nil,
                                                         year: year, month: month, day: day,
                                                         hour: nil, minute: nil, second: nil, nanosecond: nil,
                                                         weekday: nil, weekdayOrdinal: nil, quarter: nil,
                                                         weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil))
 
 static let bofnd   = calendar.date(byAdding: .hour, value: 24, to: boftd!)
 static let bofld   = calendar.date(byAdding: .day, value: -1, to: boftd!)
 
 static let boftw   = calendar.date(byAdding: .day, value: -weekday + 1, to: bofnd!)
 static let bofnw   = calendar.date(byAdding: .day, value: 7, to: boftw!)
 static let boflw   = calendar.date(byAdding: .day, value: -7, to: boftw!)
 
 static let boftm   = calendar.date(from: DateComponents(calendar: calendar,
                                                         timeZone: TimeZone.current,
                                                         era: nil,
                                                         year: year, month: month, day: 1,
                                                         hour: nil, minute: nil, second: nil, nanosecond: nil,
                                                         weekday: nil, weekdayOrdinal: nil, quarter: nil,
                                                         weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil))
 
 static let bofnm   = calendar.date(byAdding: .month, value: 1, to: boftm!)
 static let boflm   = calendar.date(byAdding: .month, value: -1, to: boftm!)
 
 static let bofty   = calendar.date(from: DateComponents(calendar: calendar,
                                                         timeZone: TimeZone.current,
                                                         era: nil,
                                                         year: year, month: 1, day: 1,
                                                         hour: nil, minute: nil, second: nil, nanosecond: nil,
                                                         weekday: nil, weekdayOrdinal: nil, quarter: nil,
                                                         weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil))
 
 static let bofny   = calendar.date(byAdding: .year, value: 1, to: bofty!)
 
 static let dateFilter : [(title: String, predicate: (BaseSnippet) -> Bool)] =
  [
   ("0_For Today",         {$0.snippetDate >= boftd! && $0.snippetDate < bofnd!}),
   ("1_For Yesterday",     {$0.snippetDate >= bofld! && $0.snippetDate < boftd!}),
   ("2_For This Week",     {$0.snippetDate >= boftw! && $0.snippetDate < bofnd!}),
   ("3_For Last Week",     {$0.snippetDate >= boflw! && $0.snippetDate < boftw!}),
   ("4_For This Month",    {$0.snippetDate >= boftm! && $0.snippetDate < bofnd!}),
   ("5_For Last Month",    {$0.snippetDate >= boflm! && $0.snippetDate < boftm!}),
   ("7_For This Year",     {$0.snippetDate >= bofty! && $0.snippetDate < bofnd!}),
   ("8_For Last Year and earlier on",                 {$0.snippetDate <  bofty!})
  ]
}

enum SnippetType: String, AllCasesSelectorRepresentable
{
 var localizedString: String {return NSLocalizedString(rawValue, comment: rawValue)}
 
 case text   = "TextSnippet"
 case photo  = "PhotoSnippet"
 case video  = "VideoSnippet"
 case audio  = "AudioSnippet"
 case sketch = "SketchSnippet"
 case report = "Report"
 //*******************************
 case undefined //error case!!!

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
 
 //***********************************************
 case nope           //initial state
 
 static let groupingTypes: [GroupSnippets] =
 [
   byPriority, byDateCreated, alphabetically, bySnippetType, plainList, byLocation
 ]
}
