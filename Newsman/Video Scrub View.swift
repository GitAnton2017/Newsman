

import UIKit
import AVKit

class VideoScrubView: UIView, UIGestureRecognizerDelegate
{
 var markersColor: UIColor!
 var markersDistance: CGFloat!

 init(frame: CGRect, markersColor: UIColor, markersDistance: CGFloat)
 {
  self.markersColor = markersColor
  self.markersDistance = markersDistance
  
  super.init(frame: frame)
  backgroundColor = UIColor.clear
  
  let panGR = UIPanGestureRecognizer(target: self, action: #selector(scrubMove))
  addGestureRecognizer(panGR)
  panGR.name = "VideoScrubViewPan"
  panGR.delegate = self
  
 }
 
 override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
 {
  return gestureRecognizer.name == "VideoScrubViewPan"
 }
 
 func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                          shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
 {
   return false
 }
 
 @objc func scrubMove(_ gr: UIPanGestureRecognizer)
 {
  
  guard let pv = superview as? PlayerView, let duration = pv.player?.currentItem?.asset.duration else {return}
  
  switch (gr.state)
  {

   case .began:
   
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction],
                   animations:
                   {[unowned self] in
                     self.transform = CGAffineTransform(scaleX: 1.1, y: 1.2)
                     self.alpha = 0.75
      
                   },
                   completion: nil)
   
   case .changed:
   
   
    let dx = gr.translation(in: self.superview!).x
    
    
    
    //guard bounds.insetBy(dx: -15, dy: 0).contains(gr.location(in: self)) else {return}
    
    center.x = max(pv.progressView.frame.minX, min(center.x + dx, pv.progressView.frame.maxX))
    
    let progress = Double((center.x - pv.progressView.frame.minX) / pv.progressView.frame.width)
    
   // print (progress)
    
    let time = CMTime(seconds: duration.seconds * progress, preferredTimescale: duration.timescale)
    let tol = CMTime(seconds: 0.001, preferredTimescale: duration.timescale)
    pv.player?.seek(to: time, toleranceBefore: tol, toleranceAfter: tol)
   
    gr.setTranslation(CGPoint.zero, in: self.superview!)
   
   case .ended:
    pv.player?.play()
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   options: [.curveEaseIn],
                   animations:
                   {[unowned self] in
                    self.transform = CGAffineTransform(scaleX: 0, y: 0)
                    self.alpha = 0
                    
                   },
                   completion:
                   {[unowned self] _ in
                    self.transform = .identity
                   })
    
   
   default:
   
    break
  }
  
 }
 override func draw(_ rect: CGRect)
 {
 
  let p1 = CGPoint.zero
  let p2 = CGPoint(x: bounds.width, y: 0)
  let p3 = CGPoint(x: bounds.width / 2, y: (bounds.height - markersDistance) / 2)
  
  let path = UIBezierPath()
  path.move(to: p1)
  path.addLine(to: p2)
  path.addLine(to: p3)
  path.close()
  
  let p4 = CGPoint(x: bounds.width / 2, y: (bounds.height + markersDistance) / 2)
  let p5 = CGPoint(x: bounds.width, y: bounds.height)
  let p6 = CGPoint(x: 0, y: bounds.height)
  
  path.move(to: p4)
  path.addLine(to: p5)
  path.addLine(to: p6)
  path.close()
  
  markersColor.setFill()
  path.fill()
  
 }

 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
  
 }
}
