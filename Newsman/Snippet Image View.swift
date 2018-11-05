
import Foundation
import UIKit

@IBDesignable class BorderedImageView: UIImageView
{
 @IBInspectable var cornerRadius: CGFloat
  {
  set {layer.cornerRadius = newValue}
  get {return layer.cornerRadius}
 }
 
 @IBInspectable var borderWidth: CGFloat
  {
  set {layer.borderWidth = newValue}
  get {return layer.borderWidth}
 }
 
 @IBInspectable var borderColor: UIColor
 {
  set {layer.borderColor = newValue.cgColor}
  get {return UIColor(cgColor: layer.borderColor!)}
 }
 
 required init?(coder aDecoder: NSCoder)
 //Must be implemented together with other initilizers of the @IBDesignable class!!!
 {
  super.init(coder: aDecoder)
 }
 
 override init(frame: CGRect)
 //Must be implemented together with other initilizers of the @IBDesignable class!!!
 {
  super.init(frame: frame)
 }
 
}
