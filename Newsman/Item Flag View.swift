
import Foundation
import UIKit

class FlagLayer: CALayer
{
 var fillColor: UIColor!
 
 override func draw(in ctx: CGContext)
 {
  ctx.beginPath()
  
  let p1 = CGPoint(x: 0, y: 0)
  let p2 = CGPoint(x: 0, y: bounds.height)
  let p3 = CGPoint(x: bounds.width/2, y: bounds.height * 0.75)
  let p4 = CGPoint(x: bounds.width, y: bounds.height)
  let p5 = CGPoint(x: bounds.width, y: 0)
  
  ctx.addLines(between: [p1,p2,p3,p4,p5])
  ctx.setFillColor(fillColor.cgColor)
  ctx.closePath()
  ctx.fillPath()
 }
}


class FlagMarkerView: UIView
{
 var flagColor: UIColor!
 {
  didSet
  {
   flagLayer.fillColor = flagColor
   setNeedsDisplay()
  }
 }
 
 override static var layerClass: AnyClass {return FlagLayer.self}
 
 var flagLayer: FlagLayer { layer as! FlagLayer }
 
 override init(frame: CGRect)
 {
  super.init(frame: frame)
  backgroundColor = UIColor.clear
  flagLayer.needsDisplayOnBoundsChange = true
  flagLayer.contentsScale = UIScreen.main.scale
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 override func draw(_ rect: CGRect) {}
}
