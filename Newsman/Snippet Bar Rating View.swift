

import Foundation
import UIKit

class SnippetPriorityView: UIView
{
 var priority: SnippetPriority = .normal
 {
  didSet {setNeedsDisplay()}
 }
 
 private var d : CGFloat {return h / 3}
 private let dw : CGFloat = 5
 private var h: CGFloat {return bounds.height}
 private var w: CGFloat {return bounds.width}
 private var N: Int {return SnippetPriority.priorities.count}
 private var bw: CGFloat {return w / CGFloat(N + 1) - dw}
 private var a: CGFloat {return (2 * h - 4 * d) / (w * w)}
 private var b: CGFloat {return (4 * d - h) / w}
 
 
 private func x(_ index: Int) -> CGFloat
 {
  return CGFloat (index + 1) * (bw + dw)
 }
 
 private func y(_ index: Int) -> CGFloat
 {
  let xi = x(index)
  return h - (a * xi + b) * xi
 }
 
 
 private func drawBar(with index: Int)
 {
  let p1 = CGPoint(x: x(index) - bw / 2, y: y(index))
  let p2 = CGPoint(x: x(index) + bw / 2, y: y(index))
  let p3 = CGPoint(x: x(index) + bw / 2, y: h)
  let p4 = CGPoint(x: x(index) - bw / 2, y: h)
  
  let path = UIBezierPath(points: [p1, p2, p3, p4])
  
  #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).setFill()
  path.fill()

 }
 
 override func draw(_ rect: CGRect)
 {
  for i in 0..<N - priority.section
  {
   drawBar(with: i)
  }
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 override init(frame: CGRect)
 {
  super.init(frame: frame)
 }
 
}
