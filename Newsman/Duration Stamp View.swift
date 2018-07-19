

import Foundation
import UIKit
import AVKit


class TimeStampView: UIView
{
 var duration: CMTime = kCMTimeZero
 {
  didSet
  {
   setNeedsDisplay()
  }
 }
 
 var textColor: UIColor = UIColor.clear
 
 init ()
 {
  super.init(frame: .zero)
  self.backgroundColor = UIColor.clear
  layer.needsDisplayOnBoundsChange = true
  layer.contentsScale = UIScreen.main.scale
  
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 
 
 override func draw(_ rect: CGRect)
 {
  
  let renderer = UIGraphicsImageRenderer(bounds: rect)
 
  
  guard duration > kCMTimeZero else
  {
   //let con = UIGraphicsGetCurrentContext()
   //con?.clear(rect)
   //con?.addRect(rect)
   //con?.setFillColor(UIColor.clear.cgColor)
   //con?.fillPath()
   
   renderer.image(actions: {_ in}).draw(in: rect)
   return
  }
  
  let HH = Int(duration.seconds/3600)
  let MM = Int((duration.seconds - Double(HH) * 3600) / 60)
  let SS = Int(duration.seconds - Double(HH) * 3600 - Double(MM) * 60)
  
  let timeStr = ((HH > 0 ? "\(HH < 10 ? "0" : "")\(HH):" : "\u{20}\u{20}\u{20}") +
   (HH > 0 || MM > 0 ? "\(MM < 10 ? "0" : "")\(MM):" : "\u{20}\u{20}:") +
   "\(SS < 10 ? "0" : "")\(SS)") as NSString
  
 
  
  let image = renderer.image
   {context in
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .right
    paragraphStyle.lineSpacing = 1.0
    
    let attr = [NSAttributedStringKey.font: UIFont(name: "Avenir", size: rect.height * 0.95)!,
                NSAttributedStringKey.paragraphStyle: paragraphStyle,
                NSAttributedStringKey.foregroundColor: textColor,]
    
    timeStr.draw(in: rect, withAttributes: attr)
  }
  
  image.draw(in: rect)
 }
 
 
}

class DurationStampView:  UIView
{
 override static var layerClass: AnyClass {return CATextLayer.self}
 
 var textLayer: CATextLayer {return layer as! CATextLayer}
 
 override func layoutSubviews()
 {
  super.layoutSubviews()
  textLayer.fontSize = bounds.height
 }
 
 var duration: CMTime = kCMTimeZero
 {
  didSet
  {
   let HH = Int(duration.seconds/3600)
   let MM = Int((duration.seconds - Double(HH) * 3600) / 60)
   let SS = Int(duration.seconds - Double(HH) * 3600 - Double(MM) * 60)
   
   textLayer.string = (HH > 0 ? "\(HH < 10 ? "0" : "")\(HH):" : "\u{20}\u{20}\u{20}") +
    (HH > 0 || MM > 0 ? "\(MM < 10 ? "0" : "")\(MM):" : "\u{20}\u{20}:") +
   "\(SS < 10 ? "0" : "")\(SS)"
   
   
  
  }
 }
 
 var textColor: UIColor = UIColor.clear
 {
  didSet
  {
   textLayer.foregroundColor = textColor.cgColor
  }
 }
 
 init ()
 {
  super.init(frame: .zero)
  self.backgroundColor = UIColor.clear
  textLayer.needsDisplayOnBoundsChange = true
  textLayer.contentsScale = UIScreen.main.scale
  textLayer.alignmentMode = kCAAlignmentRight
  
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  super.init(coder: aDecoder)
 }
 

 
 
 
}
