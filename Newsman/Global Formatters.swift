
import Foundation

struct DateFormatters
{
 static let shortDate =
 { () -> DateFormatter in
  let df = DateFormatter()
  df.dateStyle = .short
  df.timeStyle = .none
  return df
  
 }()
}
