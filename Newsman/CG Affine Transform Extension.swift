

import Foundation
import UIKit

extension CGRect
{
 func scaledBy(sw: CGFloat, sh: CGFloat) -> CGRect
 {
  return insetBy(dx: width * (1 - sw) / 2, dy: height * (1 - sh) / 2)
 }
 
 func smallerBy(factor: CGFloat) -> CGRect
 {
  return scaledBy(sw: 1 - factor, sh: 1 - factor)
 }
}

extension CGAffineTransform
{
 static let rotate90p = CGAffineTransform(rotationAngle: .pi / 2)
 static let rotate90m = CGAffineTransform(rotationAngle: -.pi / 2)
 static let rotate45p = CGAffineTransform(rotationAngle: .pi / 4)
 static let rotate45m = CGAffineTransform(rotationAngle: -.pi / 4)
 static let rotate180p = CGAffineTransform(rotationAngle: .pi)
 static let rotate180m = CGAffineTransform(rotationAngle: -.pi)
 static let rotate360p = CGAffineTransform(rotationAngle: .pi * 2)
 static let rotate360m = CGAffineTransform(rotationAngle: -.pi * 2)
 
}
