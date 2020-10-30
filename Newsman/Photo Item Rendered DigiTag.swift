//
//  Photo Item Rendered DigiTag.swift
//  Newsman
//
//  Created by Anton2016 on 14/05/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class DigitalTagAction: CAAction
{
 func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable : Any]?)
 {
  guard event == #keyPath(CALayer.contents) else { return }
  guard let layer = anObject as? CALayer else { return }
  guard let _ = layer.presentation()?.contents else { return }
  
  let tr = CATransition()
  tr.type = .reveal
  tr.subtype = .fromRight
  tr.duration = 1
  layer.add(tr, forKey: nil)
 }
 
 
}

class DigitalTag: UIView
{
// override func action(for layer: CALayer, forKey event: String) -> CAAction?
// {
//  guard event == #keyPath(CALayer.contents) else { return super.action(for: layer, forKey: event) }
//  return DigitalTagAction()
//
// }
 
// override func layoutSubviews() {
//  super.layoutSubviews()
//  hostedLayer.frame = bounds
// }
 
// lazy var hostedLayer: CALayer =
// {
//  let layer = CALayer()
//  layer.delegate = self
//  //layer.frame = bounds
//  self.layer.addSublayer(layer)
//  layer.cornerRadius = cornerRadius
//  layer.contentsGravity = .resizeAspect
//  layer.contentsScale = UIScreen.main.scale
//  layer.minificationFilter = .trilinear
//  return layer
// }()
 
 static private let cache = NSCache<NSString, UIImage>()
 
 private var markerColor: UIColor
 private var cornerRadius: CGFloat
 
 private var outlineColor: UIColor
 var textColor: UIColor
 
 private final let animateTransitions: [UIView.AnimationOptions] =
  [.transitionFlipFromRight, .transitionFlipFromTop, .transitionFlipFromBottom, .transitionFlipFromLeft, .transitionCrossDissolve]
 
 private final func animateTag(with image: UIImage)
 {
 
  let transition = animateTransitions.shuffled()[Int.random(in: 0...4)]
  UIView.transition(with: self, duration: 1.25, options: [transition], animations:
  {
   self.layer.contents = image.cgImage
  }, completion: nil)
 }
  
 var cardinal: Int?
 {
  didSet
  {
   layoutIfNeeded()
   
   guard let cardinal = cardinal else
   {
    backgroundColor = .clear
    layer.contents = nil
    return
   }
   
   backgroundColor = markerColor
   let tagStr = String(cardinal)
   
   
   if let image = DigitalTag.cache.object(forKey: tagStr as NSString)
   {
    animateTag(with: image)
    return
   }
   
   let ps = NSMutableParagraphStyle()
   ps.alignment = .center
   ps.lineBreakMode = .byClipping
   
   let tagShadow = NSShadow()
   tagShadow.shadowColor = outlineColor
   tagShadow.shadowBlurRadius = 20
   tagShadow.shadowOffset = CGSize(width: 5, height: 5)
   
   let attr: [NSMutableAttributedString.Key : Any] =
   [
     .font            : UIFont.systemFont(ofSize: 100, weight: .semibold),
     .paragraphStyle  : ps,
     .foregroundColor : textColor,
     .kern            : -1,
//     .shadow          : tagShadow,
//     .strokeColor     : outlineColor,
//     .strokeWidth     : -1
   ]
   
   let tag = NSAttributedString(string: tagStr, attributes: attr)
   
   let nsize = tag.size()
   
   let R: CGFloat = 0.5
   
   let rsize = CGSize(width: nsize.width * (1 + R) , height: nsize.height * (1 + R))
   
   let shiftX: CGFloat = nsize.width * R / 2
   let shiftY: CGFloat = nsize.height * R / 2
   
   let rf = UIGraphicsImageRendererFormat()
   rf.preferredRange = .extended
   rf.scale = UIScreen.main.scale
   let ir = UIGraphicsImageRenderer(size: rsize, format: rf)
  
   let image = ir.image {_ in tag.draw(at: CGPoint(x: shiftX, y: shiftY)) }
   
   DigitalTag.cache.setObject(image, forKey: tagStr as NSString)
   
   animateTag(with: image)
  
  }
  
 }
 
 init (with frame: CGRect = .zero,
       textColor: UIColor = .white,
       markerColor: UIColor = .newsmanRed,
       cornerRadius: CGFloat = .zero)
 {
  self.textColor = textColor
  self.outlineColor = #colorLiteral(red: 0.569727144, green: 0.0646498548, blue: 0.1405149381, alpha: 1)
  self.markerColor = markerColor
  self.cornerRadius = cornerRadius
  
  super.init(frame: frame)
  
  layer.cornerRadius = cornerRadius
  layer.contentsGravity = .resizeAspect
  layer.contentsScale = UIScreen.main.scale
  layer.minificationFilter = .trilinear
  
  

 
 }
 
 required init?(coder aDecoder: NSCoder) {
  fatalError("init(coder:) has not been implemented")
 }
}
