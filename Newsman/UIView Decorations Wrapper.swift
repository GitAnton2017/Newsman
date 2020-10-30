

import UIKit


@propertyWrapper class Decorated<V: UIView>
{
 private final var wrappedView: V?
 {
  didSet { decorators.forEach { decorate($0)} }
 }
 
 private final var decorators: [Decoration]
 {
  didSet { decorators.forEach { decorate($0)} }
 }
 
 
 final func decorate(_ decoration: Decoration)
 {
  switch decoration
  {
   case let .bordered(color: nil, width: width):
    wrappedView?.layer.borderWidth = width
    wrappedView?.layer.borderColor = wrappedView?.superview?.backgroundColor?.cgColor
    
   case let .bordered(color: color?, width: width):
    wrappedView?.layer.borderWidth = width
    wrappedView?.layer.borderColor = color.cgColor
   
   case let .filled(color: color?, alpha: alpha):
    wrappedView?.backgroundColor = color
    wrappedView?.alpha = alpha
   
   case let .filled(color: nil, alpha: alpha):
    wrappedView?.backgroundColor = wrappedView?.superview?.backgroundColor
    wrappedView?.alpha = alpha
   
   case let .rounded(radius: radius):
    wrappedView?.layer.cornerRadius = radius
   
   case let .rotated(angle: angle, anchorPoint: ap?):
    guard let dv = wrappedView else { break }
    dv.layer.anchorPoint = ap
    dv.transform = dv.transform.rotated(by: angle)
   
   case let .rotated(angle: angle, anchorPoint: nil):
    guard let dv = wrappedView else { break }
    dv.transform = dv.transform.rotated(by: angle)
   
   case let .scaled(x: scaleX, y: scaleY):
    guard let dv = wrappedView else { break }
    dv.transform = dv.transform.scaledBy(x: scaleX, y: scaleY)
   
   case let .translated(x: shiftX, y: shiftY):
    guard let dv = wrappedView else { break }
    dv.transform = dv.transform.translatedBy(x: shiftX, y: shiftY)
    
   default: break
  }
 }

 
 var wrappedValue: V?
 {
  get { wrappedView }
  set { wrappedView = newValue }
 }
 
 init(wrappedValue: V? = nil, decorators: Decoration...)
 {
  self.decorators = decorators
  self.wrappedView = wrappedValue
  
  decorators.forEach { decorate($0) }
 }
 
 var projectedValue: [Decoration]
 {
  get { decorators }
  set { decorators = newValue }
 }
}
