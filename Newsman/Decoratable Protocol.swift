//
//  Decoratable Protocol.swift
//  Newsman
//
//  Created by Anton2016 on 19.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import class Combine.AnyCancellable

protocol Decoratable
{
 var decoratedView: UIView? { get }
}

extension UIView
{
 func addSubviews(_ subviews: UIView...) { subviews.forEach{addSubview($0)} }
}

extension UIView: Decoratable
{
 var decoratedView: UIView? { self }
}

final class DashFrameShapeLayer: CAShapeLayer
{
 private final var boundsChangeSubscription: AnyCancellable?
 
 override final func removeFromSuperlayer()
 {
  super.removeFromSuperlayer()
  cancel()
 }
 
 final func cancel()
 {
  boundsChangeSubscription?.cancel()
  boundsChangeSubscription = nil
 }
 
 static let dashAnimationID = "dashAnimation"
 static let frameLayerID =  "frameLayer"
 
 @discardableResult init( parent: CALayer, _ frameColor: UIColor,
                         _ frameWidth: CGFloat, _ margin: CGFloat,
                         _ dashPattern: [NSNumber], _ animated: Bool)
 {
  super.init()
  
  parent.addSublayer(self)

  name = Self.frameLayerID
  
  zPosition = .greatestFiniteMagnitude
  
  let ins = frameWidth / 2 + margin
  let rect = parent.bounds.insetBy(dx: ins, dy: ins)
  let cr = parent.cornerRadius - ins
  
  boundsChangeSubscription = parent.publisher(for: \.bounds, options: [])
  .map { UIBezierPath(roundedRect: $0.insetBy(dx: ins, dy: ins), cornerRadius: cr).cgPath }
  .sink { [unowned self] in self.path = $0 }
  
  let framePath = UIBezierPath(roundedRect: rect, cornerRadius: cr)
  
  path = framePath.cgPath
  lineDashPattern = dashPattern
  strokeColor = frameColor.cgColor
  lineWidth = frameWidth
  fillColor = UIColor.clear.cgColor
  
  guard animated else { return }
  
  let lineDashAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.lineDashPhase))
  lineDashAnimation.fromValue = 0
  lineDashAnimation.toValue = dashPattern.reduce(0) { $0 + $1.intValue }
  lineDashAnimation.duration = 1
  lineDashAnimation.repeatCount = .greatestFiniteMagnitude
  add(lineDashAnimation, forKey: Self.dashAnimationID)
  
 }
 
 required init?(coder: NSCoder) { super.init(coder: coder) }
 
}

extension Decoratable
{
 func roundCorners(_ cornerRadius: CGFloat)
 {
  decoratedView?.layer.cornerRadius = cornerRadius
 }
 
 func capsulate(_ orientation: Orientaion)
 {
  guard let dv = decoratedView else { return }
  
  switch orientation
  {
   case .horizontal where dv.bounds.width >= dv.bounds.height: roundCorners(0.5 * dv.bounds.height)
   case .vertical   where dv.bounds.width <= dv.bounds.height: roundCorners(0.5 * dv.bounds.width)
   
   default: break
  }
 }
 
 func drawBorder(_ borderWidth: CGFloat, _ borderColor: UIColor?)
 {
  decoratedView?.layer.borderWidth = borderWidth
  decoratedView?.layer.borderColor = borderColor?.cgColor
 }
 
 
 func drawDashFrame(_ frameColor: UIColor,
                    _ frameWidth: CGFloat = 1,
                    _ margin: CGFloat = 0,
                    _ dashPattern: [NSNumber] = [10,5],
                    _ animated: Bool = true,
                    _ overlayed: Bool = true )
 {
  
  guard let dvl = decoratedView?.layer else { return }
  
  if (!overlayed) { dvl.sublayers?.compactMap{ $0 as? DashFrameShapeLayer}.forEach{ $0.removeFromSuperlayer() } }
  
  DashFrameShapeLayer(parent: dvl, frameColor, frameWidth, margin, dashPattern, animated)
  
 }
 
 
 
 func setBackColor(_ color: UIColor?, _ alpha: CGFloat)
 {
  decoratedView?.backgroundColor = color
  decoratedView?.alpha = alpha
 }
 
 func setRotation(_ angle: CGFloat, _ anchorPoint: CGPoint? = nil )
 {
  guard let dv = decoratedView else { return }
  if let anchorPoint = anchorPoint { dv.layer.anchorPoint = anchorPoint }
  dv.transform = dv.transform.rotated(by: angle)
 }
 
 func setScale(_ scaleX: CGFloat, _ scaleY: CGFloat )
 {
  guard let dv = decoratedView else { return }
  dv.transform = dv.transform.scaledBy(x: scaleX, y: scaleY)
 }
 
 func setTranslation(_ shiftX: CGFloat, _ shiftY: CGFloat )
 {
  guard let dv = decoratedView else { return }
  dv.transform = dv.transform.translatedBy(x: shiftX, y: shiftY)
 }
 
 func setTransform(_ tr: CGAffineTransform)
 {
  guard let dv = decoratedView else { return }
  dv.transform = dv.transform.concatenating(tr)
 }
 
 func clear2DTransforms() { decoratedView?.transform = .identity }
 
 func setTransforms(_ tra: [CGAffineTransform]) { tra.forEach { setTransform($0) } }
 
 func decorate(_ decoration: Decoration)
 {
  switch decoration
  {
   case let .bordered(color: nil, width: width):    drawBorder(width, decoratedView?.superview?.backgroundColor)
   case let .bordered(color: color?, width: width): drawBorder(width, color)
   case let .filled(color: color?, alpha: alpha):   setBackColor(color, alpha)
   case let .filled(color: nil, alpha: alpha):      setBackColor(decoratedView?.superview?.backgroundColor, alpha)
   case let .rounded(radius: radius):               roundCorners(radius)
   case let .capsulated(orientation: orientation):  capsulate(orientation)
   case let .rotated(angle: rad, anchorPoint: ap):  setRotation(rad, ap)
   case let .scaled(x: scaleX, y: scaleY):          setScale(scaleX, scaleY)
   case let .translated(x: shiftX, y: shiftY):      setTranslation(shiftX, shiftY)
   case let .transformed(with: tra):                setTransforms(tra)
   case let .constraint(anchor: anchor):            Anchors.constrain(view: decoratedView, with: anchor)
   case let .constraints(anchors: anchors):         Anchors.constrain(view: decoratedView, with: anchors)
   case let .framed(color: fc,
                    width: fw,
                    margin: fm,
                    pattern: fp,
                    animated: fa,
                    overlayed: fo):                 drawDashFrame(fc, fw, fm, fp, fa, fo)
   
   case     .identity:                              clear2DTransforms()
   default: break
  }
 }
 
}

