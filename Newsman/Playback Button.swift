
import Foundation
import UIKit

class PlaybackButton: UIButton
{
 var iconColor: UIColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).withAlphaComponent(0.75)
 var r: CGFloat = 0
 var shift: CGFloat = 0.125
 var width: CGFloat = 0.075
 
 override static var layerClass: AnyClass { CAShapeLayer.self }
 
 var playIconLayer: CAShapeLayer { layer as! CAShapeLayer }
 
 override init(frame: CGRect)
 {
  super.init(frame: frame)
  backgroundColor = UIColor.clear
  playIconLayer.needsDisplayOnBoundsChange = true
  playIconLayer.contentsScale = UIScreen.main.scale
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 func drawPlayIcon()
 {
  let D = self.bounds.width // cell contentView diametr...
  let rect = self.bounds
  
  
  let path = CGMutablePath()
  let rs = r + shift
  let r1 = r + width // 0.03 define the width of outer ring...
  
  path.addEllipse(in: rect.insetBy(dx: r * D, dy: r * D))    //outer circle
  path.addEllipse(in: rect.insetBy(dx: r1 * D, dy: r1 * D))  //inner circle
  
  let p13x = D * (1/2 + (rs - 1/2) * cos(.pi/3))
  let q = (rs - 1/2) * sin(.pi/3)
  let p1 = CGPoint(x: p13x, y:  D * (1/2 + q))
  let p2 = CGPoint(x:  D * (1 - rs), y:  D / 2)
  let p3 = CGPoint(x:  p13x, y:  D * (1/2 - q))
  
  path.addLines(between: [p1, p2, p3]) // play icon internal triangle points...
  playIconLayer.path = path
  playIconLayer.strokeColor = iconColor.cgColor
  playIconLayer.fillColor = iconColor.cgColor
  playIconLayer.fillRule = CAShapeLayerFillRule.evenOdd
 
 }
 
 override func draw(_ rect: CGRect)
 {
  drawPlayIcon()
 }

}
