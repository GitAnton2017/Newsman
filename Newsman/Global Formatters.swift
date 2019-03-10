
import Foundation


extension String
{
 init(repeating: [Character], counts: [Int])
 {
  self = zip(repeating, counts).reduce(""){$0 + String(repeating: $1.0, count: $1.1)}
 }
 
}
struct DateFormatters
{
 static let short: DateFormatter  =
 {
  let df = DateFormatter()
  df.dateStyle = .short
  df.timeStyle = .none
  return df
 }()
 
 
 static let medium: DateFormatter  =
 {
  let df = DateFormatter()
  df.dateStyle = .medium
  df.timeStyle = .none
  return df
  
 }()
 
 static let dr = 0...2
 static let mr = 0...5
 static let yr = 0...4
 
 static let format = ["ddMyy","ddMMMyy", "dMyy", "dMMyy","dMMMyy","y"]
 
  //dr.map{d in mr.map{m in yr.map{y in String(repeating: ["d", "M", "y"], counts: [d, m, y])}}}.joined().joined()
 
 static func localizedSearchString(for date: Date) -> String
 {
  let str_dates = format.map
  {(format) -> String in
   let fs = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: Locale.current)
   let df = DateFormatter()
   df.dateFormat = fs
   return df.string(from: date)
  }
  
  return str_dates.reduce("") { $0 + " " + $1 }
 }
  
 
 
 
 
}
