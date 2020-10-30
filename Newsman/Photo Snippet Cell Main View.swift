//
//  Photo Snippet Cell Main View.swift
//  Newsman
//
//  Created by Anton2016 on 24.04.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import Combine

extension PhotoSnippetCellProtocol
{
 func clearMainView()
 {
  guard let mainView = self.mainView as? PhotoSnippetCellMainView else { return }
  mainView.layer.removeAllAnimations()
  mainView.alpha = 1
  mainView.backgroundColor = .clear
  mainView.isFramed = false
  mainView.isDragMoving = false
  mainView.isNewPhotoAnimated = false

 }
}



final class DraggedArrowView: UIView
{
 private final let arrowColor: UIColor

 
 init(arrowColor: UIColor)
 {
  self.arrowColor = arrowColor
  super.init(frame: .zero)
 }
 
 required init?(coder: NSCoder)
 {
  self.arrowColor = .clear
  super.init(coder: coder)
 }
 

 
 override func draw(_ rect: CGRect)
 {
  let p1 = CGPoint(x: 0, y: rect.height)
  let p2 = CGPoint(x: rect.width / 2, y: 0)
  let p3 = CGPoint(x: rect.width , y: rect.height)
  let path = UIBezierPath(points: [p1, p2 ,p3])
  arrowColor.setFill()
  path.fill()
 }
}


final class PhotoSnippetCellMainView: UIView, CALayerCornerRadiusObservable
{
 final var cornerRadiusObservation: AnyCancellable?
 
 private final var shapeLayer: CAShapeLayer { layer as! CAShapeLayer }
 
 final override class var layerClass: AnyClass { CAShapeLayer.self }
 
 @Filled(fillColor: .clear, alpha: 0)
 @Constrained(inset: 5)
 final var arrowsRotateView = UIView(frame: .zero)
 
 @Rotated(angle: 0, anchorPoint: CGPoint(x: 0.5, y: 2.5))
 @Filled(fillColor: .clear)
 @Constrained(centerShift: .zero, wR: 0.2, hR: 0.2)
 final var topArrowView = DraggedArrowView(arrowColor: .newsmanRed)
 //RunningArrowView(arrowColor: .red, arrowWidth: 2, arrowPhase: 1, arrowSharpness: .pi / 1.5)
 
 @Rotated(angle: .pi / 2, anchorPoint: CGPoint(x: 0.5, y: 2.5))
 @Filled(fillColor: .clear)
 @Constrained(centerShift: .zero, wR: 0.2, hR: 0.2)
 final var rightArrowView = DraggedArrowView(arrowColor: .newsmanRed)
 //RunningArrowView(arrowColor: .red, arrowWidth: 2, arrowPhase: 1, arrowSharpness: .pi / 1.5)
 
 @Rotated(angle: .pi, anchorPoint: CGPoint(x: 0.5, y: 2.5))
 @Filled(fillColor: .clear)
 @Constrained(centerShift: .zero, wR: 0.2, hR: 0.2)
 final var bottomArrowView = DraggedArrowView(arrowColor: .newsmanRed)
 //RunningArrowView(arrowColor: .red, arrowWidth: 2, arrowPhase: 1, arrowSharpness: .pi / 1.5)
 
 @Rotated(angle:  3 * .pi / 2, anchorPoint: CGPoint(x: 0.5, y: 2.5))
 @Filled(fillColor: .clear)
 @Constrained(centerShift: .zero, wR: 0.2, hR: 0.2)
 final var leftArrowView = DraggedArrowView(arrowColor: .newsmanRed)
  //RunningArrowView(arrowColor: .red, arrowWidth: 2, arrowPhase: 1, arrowSharpness: .pi / 1.5)
 
 @Constrained(anchors: .centerX(0, nil, 0.22), .centerY(0, nil, 1.78), .heightR(0.14), .aspect(), .cornerRadius(0.6))
 final var rowPositionTag = DigitalTag(markerColor: .newsmanRed)
 
 @Constrained(anchors: .top(), .trailing(), .widthR(0.2), .heightR(0.25))
 final var priorityFlagMarker = PriorityFlagMarkerView()

 private final func configueChildren()
 {

  addSubviews(arrowsRotateView, rowPositionTag, priorityFlagMarker)
  arrowsRotateView.addSubviews(topArrowView, rightArrowView, bottomArrowView, leftArrowView)
  
  let shift = arrowsRotateView.bounds.height / 2
  
  $topArrowView =    .constraint(anchor: .centerY(-shift))
  $bottomArrowView = .constraint(anchor: .centerY( shift))
  $rightArrowView =  .constraint(anchor: .centerX( shift))
  $leftArrowView =   .constraint(anchor: .centerX(-shift))
 }
 
 required init?(coder: NSCoder)
 {
  super.init(coder: coder)
  configueChildren()
 }
 
 final var isDragMoving = false
 {
  didSet
  {
   guard oldValue != isDragMoving else { return }
//   topArrowView.isRunning = isDragMoving
//   bottomArrowView.isRunning = isDragMoving
//   rightArrowView.isRunning = isDragMoving
//   leftArrowView.isRunning = isDragMoving
   animateDragMoving()
  }
 }
 
 final var isFramed = false
 {
  didSet { setNeedsDisplay() }
 }
 
 final var isNewPhotoAnimated = false
 {
  didSet { updateNewItemAnimationState() }
 }
 
 weak var takenPhotoImageView: UIImageView?
 
 weak var takenPhotoImageViewTop: NSLayoutConstraint?
 weak var takenPhotoImageViewBottom: NSLayoutConstraint?
 weak var takenPhotoImageViewLeading: NSLayoutConstraint?
 weak var takenPhotoImageViewTrailing: NSLayoutConstraint?
 
 
 override final func layoutSubviews()
 {
  super.layoutSubviews()
 
  guard bounds != .zero else { return }
  
  shapeLayer.path = framePath.cgPath
  
  guard let iv = self.takenPhotoImageView else { return }
  
  
  iv.translatesAutoresizingMaskIntoConstraints = false
  
  let w = bounds.width
  let h = bounds.height
  
  if !(takenPhotoImageViewTop?.isActive ?? false)
  {
   let top = iv.topAnchor.constraint(equalTo: topAnchor, constant: 0.15 * h)
   top.isActive = true
   takenPhotoImageViewTop = top
  }
  else
  {
   return
  }
  
  
  if !(takenPhotoImageViewBottom?.isActive ?? false)
  {
   let bottom = iv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -0.15 * h)
   bottom.isActive = true
   takenPhotoImageViewBottom = bottom
  }
  else
  {
   return
  }
  
  if !(takenPhotoImageViewLeading?.isActive ?? false)
  {
   let leading = iv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.15 * w)
   leading.isActive = true
   takenPhotoImageViewLeading = leading
  }
  else
  {
   return
  }
  
  if !(takenPhotoImageViewTrailing?.isActive ?? false)
  {
   let trailing = iv.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0.15 * w)
   trailing.isActive = true
   takenPhotoImageViewTrailing = trailing
  }
  else
  {
   return
  }
  
  
 }
 
 private final func applyConstraints(_ r: CGFloat)
 {
  let hor = bounds.width * r
  let ver = bounds.height * r
  
  takenPhotoImageViewTop?.constant = ver
  takenPhotoImageViewBottom?.constant = -ver
  takenPhotoImageViewLeading?.constant = hor
  takenPhotoImageViewTrailing?.constant = -hor

  layoutIfNeeded()
 }
 
 final func animateNewPhoto()
 {
  UIView.animate(withDuration: 0.75, delay: 0, options: [.curveLinear],
   animations: { [ weak self ] in
    UIView.modifyAnimations(withRepeatCount: 5, autoreverses: true)
    {
     self?.takenPhotoImageView?.alpha = 0.5
     self?.applyConstraints(0.175)
     self?.takenPhotoImageView?.transform = .init(scaleX: 0.9, y: 0.9)
    }
   },
   completion: { [ weak self ] success in
   
    self?.applyConstraints(0.15)
    
    guard success else
    {
     self?.takenPhotoImageView?.transform = .identity
     self?.transform = .identity
     self?.takenPhotoImageView?.alpha = 1
     return
    }
    
    
    UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut], animations:
    { [ weak self ] in
     self?.takenPhotoImageView?.transform = CGAffineTransform(rotationAngle: 3 * .pi).scaledBy(x: 1e-5, y: 1e-5)
     self?.transform = .identity
     self?.takenPhotoImageView?.alpha = 0
    }, completion: nil)
  })
 }
 
 private final func updateNewItemAnimationState()
 {
  switch (isNewPhotoAnimated, takenPhotoImageView)
  {
   case(true, nil):
    let takenPhotoImage = UIImage(systemName: "camera")
    let takenPhotoImageView = UIImageView(image: takenPhotoImage)
    takenPhotoImageView.contentMode = .scaleAspectFit
    takenPhotoImageView.tintColor = .white
    takenPhotoImageView.preferredSymbolConfiguration = .init(weight: .ultraLight)
    
    addSubview(takenPhotoImageView)
    self.takenPhotoImageView = takenPhotoImageView
    
   
   case let (false, photoView?): photoView.removeFromSuperview()
    takenPhotoImageView = nil
   
   default: break
  }
 
  
 }
 
 private final func animateDragMoving()
 {
  let shift = arrowsRotateView.bounds.height / 2
  UIView.animate(withDuration: 0.35, animations:
  {[ weak self ] in
   guard let self = self else { return }
   //self.backgroundColor = self.isDragMoving ? UIColor.red : .clear
   self.arrowsRotateView.alpha = self.isDragMoving ? 1 : 0
   self.arrowsRotateView.transform = .identity

   self.$topArrowView =    self.isDragMoving ? .constraint(anchor: .centerY(0)): .constraint(anchor: .centerY(-shift))
   self.$bottomArrowView = self.isDragMoving ? .constraint(anchor: .centerY(0)): .constraint(anchor: .centerY( shift))
   self.$rightArrowView =  self.isDragMoving ? .constraint(anchor: .centerX(0)): .constraint(anchor: .centerX( shift))
   self.$leftArrowView =   self.isDragMoving ? .constraint(anchor: .centerX(0)): .constraint(anchor: .centerX(-shift))

   self.arrowsRotateView.layoutIfNeeded()
   
  })
  
  
  
 }
 
 private final var frameLineWidth: CGFloat { max(2.0, min(3.0, 0.03 * bounds.size.width)) }
 
 final var frameColor = UIColor(red: 236/255, green: 60/255, blue: 26/255, alpha: 1)
 {
  didSet { setNeedsDisplay() }
 }
 
 private final var frameCornerRadius: CGFloat { layer.cornerRadius - frameLineWidth / 2 }
 
 private let lineDashPattern: [NSNumber] = [8,4]
 
 private final var frameRect: CGRect { bounds.insetBy(dx: frameLineWidth / 2, dy: frameLineWidth / 2)}
 private final var framePath: UIBezierPath
 {
  UIBezierPath(roundedRect: frameRect, cornerRadius: frameCornerRadius)
 }
 
 private final var frameStrokeColor: UIColor { isFramed ? frameColor: .clear }
 private final var borderColor: UIColor { isFramed ? .clear : frameColor }
 
 private static let dashAnimation = "dashAnimation"
 
 private final func animateDashPattern()
 {
  guard isFramed else { shapeLayer.removeAnimation(forKey: Self.dashAnimation); return }
  let lineDashAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.lineDashPhase))
  lineDashAnimation.fromValue = 0
  lineDashAnimation.toValue = lineDashPattern.reduce(0) { $0 + $1.intValue }
  lineDashAnimation.duration = 1
  lineDashAnimation.repeatCount = .greatestFiniteMagnitude
  shapeLayer.add(lineDashAnimation, forKey: Self.dashAnimation)
 }
 
 private final func drawDashFrame()
 {
  shapeLayer.path = framePath.cgPath
  shapeLayer.lineDashPattern = lineDashPattern
  shapeLayer.strokeColor = frameStrokeColor.cgColor
  shapeLayer.lineWidth = frameLineWidth
  shapeLayer.fillColor = UIColor.clear.cgColor
 }
 
 private final func applyDashPattern(animated: Bool = true)
 {
  drawDashFrame()
  guard animated else { return }
  animateDashPattern()
 }
  
 final override func draw(_ rect: CGRect)
 {
  layer.borderColor = borderColor.cgColor
  applyDashPattern()
 }
}
