//
//  BaseSnippet+CoreDataClass.swift
//  Newsman
//
//  Created by Anton2016 on 16.11.17.
//  Copyright © 2017 Anton2016. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(BaseSnippet)

public class BaseSnippet: NSManagedObject{}

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
    ("Today",         {($0.date! as Date) >= boftd! && ($0.date! as Date) < bofnd!}),
    ("Yesterday",     {($0.date! as Date) >= bofld! && ($0.date! as Date) < boftd!}),
    ("This Week",     {($0.date! as Date) >= boftw! && ($0.date! as Date) < bofnd!}),
    ("Last Week",     {($0.date! as Date) >= boflw! && ($0.date! as Date) < boftw!}),
    ("This Month",    {($0.date! as Date) >= boftm! && ($0.date! as Date) < bofnd!}),
    ("Last Month",    {($0.date! as Date) >= boflm! && ($0.date! as Date) < boftm!}),
    ("This Year",     {($0.date! as Date) >= bofty! && ($0.date! as Date) < bofnd!})
 ]
}

public enum SnippetType: String
{
    case text   = "TextSnippet"
    case photo  = "PhotoSnippet"
    case video  = "VideoSnippet"
    case audio  = "AudioSnippet"
    case sketch = "SketchSnippet"
    case report = "Report"
    
}

public enum SnippetPriority: String
{
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
        (SnippetPriority.hottest.rawValue, {$0.priority == SnippetPriority.hottest.rawValue }),
        (SnippetPriority.hot.rawValue,     {$0.priority == SnippetPriority.hot.rawValue     }),
        (SnippetPriority.high.rawValue,    {$0.priority == SnippetPriority.high.rawValue    }),
        (SnippetPriority.normal.rawValue,  {$0.priority == SnippetPriority.normal.rawValue  }),
        (SnippetPriority.medium.rawValue,  {$0.priority == SnippetPriority.medium.rawValue  }),
        (SnippetPriority.low.rawValue,     {$0.priority == SnippetPriority.low.rawValue     })
    ]
    
    static let prioritySectionsMap: [SnippetPriority: Int] =
    [
        .hottest : 0, .hot : 1, .high : 2, .normal : 3, .medium : 4, .low : 5
    ]
    static let priorities: [SnippetPriority] =
    [
        .hottest , .hot, .high, .normal, .medium, .low
    ]
    
    var color: UIColor
    {
        get
        {
            return SnippetPriority.priorityColorMap[self]!
        }
    }
    
    var section: Int
    {
        get
        {
            return SnippetPriority.prioritySectionsMap[self]!
        }
    }
    
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

public enum SnippetStatus: String
{
    
    case new         =   "New"
    case old         =   "Old"
    case archived    =   "Archived"
   
    
}
