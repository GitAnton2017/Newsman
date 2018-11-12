
import Foundation
import UIKit

class PriorityBarView: UIView
{
 var boundsObserver: NSKeyValueObservation?
 
 override func layoutSubviews()
 {
  super.layoutSubviews()
 }
 
 override init(frame: CGRect)
 {
  super.init(frame: frame)
  backgroundColor = .clear
  boundsObserver = observe(\.bounds){ob, _ in ob.setNeedsDisplay()}
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 var barColor: UIColor = .clear
 {
  didSet
  {
   setNeedsDisplay()
  }
 }
 
 private let m : CGFloat = 1
 private var h: CGFloat {return bounds.height}
 private var w: CGFloat {return bounds.width}
 private var dh: CGFloat = 2.75
 
 private var N: Int
 {
  let fn = ((h + m)/(dh + m)).rounded(.down)
  return Int(fn)
 }
 
 override func draw(_ rect: CGRect)
 {
  for i in 0..<N
  {
   let d1 = h - dh * CGFloat(i + 1) - m * CGFloat(i)
   let d0 = h - dh * CGFloat(i) - m * CGFloat(i)
   let p1 = CGPoint(x: 0, y: d1)
   let p2 = CGPoint(x: w, y: d1)
   let p3 = CGPoint(x: w, y: d0)
   let p4 = CGPoint(x: 0, y: d0)
   let path = UIBezierPath(points: [p1, p2, p3, p4])
   barColor.setFill()
   path.fill()
  }
 }
}

class SnippetPriorityView: UIView
{
 var priority: SnippetPriority = .normal
 {
  didSet
  {
   drawBars()
   //setNeedsDisplay()
  }
 }
 
 private static let N: Int = SnippetPriority.priorities.count

 private static let m0: CGFloat = 0.1
 private static let mN1: CGFloat = 1.0
 private static let mNk: CGFloat = 0.25
 private static let K: Int = 4
 private static let dw : CGFloat = 3

 
 private static var A: CGFloat =
 {
  let nk = CGFloat(N - K)
  let n1 = CGFloat(N - 1)
  let k1 = CGFloat(K - 1)
  return (mN1 * nk - mNk * n1 + m0 * k1) / (k1 * n1 * nk)
 }()
 
 private static var B: CGFloat =
 {
   let n1 = CGFloat(N - 1)
   return (mN1 - m0) / n1 - n1 * A
 }()
 
 private static var M: [CGFloat] =
 {
  return (0..<N).map
  {
   let x = CGFloat($0)
   return A * x * x + B * x + m0
  }
 }()
 
 lazy var bars: [PriorityBarView] =
 {
  
  let N = SnippetPriorityView.N
  let N1 = 1 / CGFloat(N)
  
  var bars: [PriorityBarView] = []
  
  for i in 0..<N
  {
   let bar = PriorityBarView(frame: .zero)
   addSubview(bar)
   bar.translatesAutoresizingMaskIntoConstraints = false
   NSLayoutConstraint.activate(
   [
    bar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: N1, constant: SnippetPriorityView.dw * (N1 - 1)),
    bar.leadingAnchor.constraint(equalTo: i == 0 ? leadingAnchor : bars[i - 1].trailingAnchor,
                                 constant: i == 0 ? 0 : SnippetPriorityView.dw),
    
    bar.heightAnchor.constraint(equalTo: heightAnchor, multiplier: SnippetPriorityView.M[i]),
    bar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
    
   ])
   
   bars.append(bar)
  }
  return bars

 }()
 
 
 private var d : CGFloat {return h / 3}

 private var h: CGFloat {return bounds.height}
 private var w: CGFloat {return bounds.width}
 
 private var bw: CGFloat {return w / CGFloat(SnippetPriorityView.N + 1) - SnippetPriorityView.dw}
 private var a: CGFloat {return (2 * h - 4 * d) / (w * w)}
 private var b: CGFloat {return (4 * d - h) / w}
 
 
 private func x(_ index: Int) -> CGFloat
 {
  return CGFloat (index + 1) * (bw + SnippetPriorityView.dw)
 }
 
 private func y(_ index: Int) -> CGFloat
 {
  let xi = x(index)
  return h - (a * xi + b) * xi
 }
 
 
 private func drawBar(with index: Int, color: UIColor)
 {

  let p1 = CGPoint(x: x(index) - bw / 2, y: y(index))
  let p2 = CGPoint(x: x(index) + bw / 2, y: y(index))
  let p3 = CGPoint(x: x(index) + bw / 2, y: h)
  let p4 = CGPoint(x: x(index) - bw / 2, y: h)
  
  let path = UIBezierPath(points: [p1, p2, p3, p4])
  
  color.setFill()
  path.fill()

 }
 

 private func drawBars()
 {
  let N = SnippetPriorityView.N
  let colors = SnippetPriority.priorities.reversed().map{$0.color}
  for i in 0..<N
  {
   bars[i].barColor = (i < N - priority.section) ? colors[i]: #colorLiteral(red: 0.9100814104, green: 0.7231698463, blue: 0.6363813562, alpha: 0.51)
  }
 }
 
// override func layoutSubviews()
// {
//  super.layoutSubviews()
// }
//
// override func draw(_ rect: CGRect)
// {
//
//  let colors = SnippetPriority.priorities.reversed().map{$0.color}
//  for i in 0..<N
//  {
//
//   drawBar(with: i, color: i < N - priority.section ? colors[i]: #colorLiteral(red: 0.9100814104, green: 0.7231698463, blue: 0.6363813562, alpha: 0.51))
//  }
// }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 override init(frame: CGRect)
 {
  super.init(frame: frame)
 }
 
}
