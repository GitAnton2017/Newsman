

import Foundation
import UIKit

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
