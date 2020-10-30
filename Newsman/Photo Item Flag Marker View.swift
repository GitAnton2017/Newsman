//
//  Photo Item Flag Marker View.swift
//  Newsman
//
//  Created by Anton2016 on 17.07.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import Foundation
import UIKit

final class FlagMarkerLayer: CALayer
{
 final var markerColor: UIColor!
 
 final override func draw(in ctx: CGContext)
 {
  ctx.beginPath()
  
  let p1 = CGPoint(x: 0, y: 0)
  let p2 = CGPoint(x: 0, y: bounds.height)
  let p3 = CGPoint(x: bounds.width/2, y: bounds.height * 0.75)
  let p4 = CGPoint(x: bounds.width, y: bounds.height)
  let p5 = CGPoint(x: bounds.width, y: 0)
  
  ctx.addLines(between: [p1,p2,p3,p4,p5])
  ctx.setFillColor(markerColor.cgColor)
  ctx.closePath()
  ctx.fillPath()
 }
}



final class PriorityFlagMarkerView: UIView
{
 
 enum FlagChangeAnimation
 {
  case transition(options: UIView.AnimationOptions = [.transitionCrossDissolve, .curveEaseInOut],
                  duration: TimeInterval = 0.5)
  case none
  
  static private var randomTransition: UIView.AnimationOptions
  {
   [.transitionFlipFromRight,
    .transitionFlipFromTop,
    .transitionFlipFromBottom,
    .transitionFlipFromLeft,
    .transitionCrossDissolve].shuffled()[Int.random(in: 0...4)]
  }
  
  case jumpDown (duration: TimeInterval = 0.5, damping: CGFloat = 0.5)
  case jumpLeft (duration: TimeInterval = 0.5, damping: CGFloat = 0.5)
  case swingDown(duration: TimeInterval = 1.5, damping: CGFloat = 0.5)
  
  static func randomTransitions(_ duration: TimeInterval = 1.0) -> Self
  {
   .transition(options: [randomTransition], duration: duration)
  }
  
  static func randomAll(_ duration: TimeInterval = 1.0) -> Self
  {
   [.jumpDown(duration: duration / 2),
    .jumpLeft(duration: duration / 2),
    .swingDown(duration: duration * 1.5),
    .randomTransitions(duration)].shuffled()[Int.random(in: 0...3)]
  }
 }
 
 final var animation: FlagChangeAnimation
 final var markerColor: UIColor
 {
  didSet
  {
   flagMarkerLayer.markerColor = markerColor
   updateFlagColor()
  }
 }
 
 final var animated = true
 

 private final func animateSwingDown(_ duration: TimeInterval, _ damping: CGFloat)
 {
  setNeedsDisplay()
  
  guard bounds != .zero  else { return }
   
  alpha = 0
  layer.anchorPoint = CGPoint(x: 0, y: 0)
  transform = CGAffineTransform(translationX: -bounds.width / 2, y: -bounds.height / 2).rotated(by: -.pi/2)
  
  UIView.animate(withDuration: duration, delay: 0.0,
                 usingSpringWithDamping: damping,
                 initialSpringVelocity: 0,  options: [.curveEaseInOut],
                 animations: {[ weak self ] in
                  self?.alpha = 1;
                  self?.transform = .identity
                  self?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                 },
                 completion: nil )
 }
 
 private final func animateJumpLeft(_ duration: TimeInterval, _ damping: CGFloat)
 {
  setNeedsDisplay()
  
  guard bounds != .zero  else { return }
  
  guard let widthConst = (superview?.constraints.first { $0.firstItem === self &&
                                                         $0.secondItem === superview &&
                                                         $0.firstAttribute == .width &&
                                                         $0.secondAttribute == .width }) else { return }
  
  alpha = 0
  
  transform = CGAffineTransform(translationX: bounds.width, y: 0 )
  
  UIView.animate(withDuration: duration * 0.25,
                 delay: 0.0, options: [.curveEaseInOut],
                 animations: {[ weak self ] in
                  self?.alpha = 1
                  self?.transform = .identity
                 },
                 completion: { [ weak self ] success in
                  guard success else { return }
                  guard let self = self else { return }
                  widthConst.constant = self.bounds.width * 2
                  self.superview?.layoutIfNeeded()
                  UIView.animate(withDuration: duration * 0.75, delay: 0.0,
                                 usingSpringWithDamping: damping,
                                 initialSpringVelocity: 0,  options: [.curveEaseInOut],
                                 animations: { [ weak self ] in
                                                widthConst.constant = 0
                                                self?.superview?.layoutIfNeeded()
                   
                                             },
                                 completion: nil)
                  
                 })
 }
 
 private final func animateJumpDown(_ duration: TimeInterval, _ damping: CGFloat)
 {
 
  setNeedsDisplay()
  
  guard bounds != .zero  else { return }
  
  guard let heightConst = (superview?.constraints.first{ $0.firstItem === self &&
                                                         $0.secondItem === superview &&
                                                         $0.firstAttribute == .height &&
                                                         $0.secondAttribute == .height }) else { return }
  
  alpha = 0
 
  transform = CGAffineTransform(translationX: 0, y: -bounds.height)
  
  UIView.animate(withDuration: duration * 0.25,
                 delay: 0.0, options: [.curveEaseInOut],
                 animations: {[ weak self ] in
                  self?.alpha = 1
                  self?.transform = .identity
                
                },
                 completion: { [ weak self ] success in
                  guard success else { return }
                  guard let self = self else { return }
                  heightConst.constant = self.bounds.height * 2.5
                  self.superview?.layoutIfNeeded()
                  UIView.animate(withDuration: duration * 0.75, delay: 0.0,
                                 usingSpringWithDamping: damping,
                                 initialSpringVelocity: 0,  options: [.curveEaseInOut],
                                 animations: { [ weak self ] in
                                                heightConst.constant = 0
                                                self?.superview?.layoutIfNeeded()
                   
                                             },
                                 completion: nil)
                  
                 })
 }
 

 private final func updateFlagColor()
 {

  guard animated else { setNeedsDisplay(); return }
  
  switch animation
  {
   case .none: setNeedsDisplay()
   case let .transition(options: options, duration: duration):
    UIView.transition(with: self,
                      duration: duration,
                      options: options,
                      animations: { [ weak self] in self?.setNeedsDisplay() })
   
   case let .jumpDown (duration: duration,  damping: damping) : animateJumpDown (duration, damping)
   case let .jumpLeft (duration: duration,  damping: damping) : animateJumpLeft (duration, damping)
   case let .swingDown(duration: duration,  damping: damping) : animateSwingDown(duration, damping)
  
  }
  
 }
 override static var layerClass: AnyClass { FlagMarkerLayer.self }
 
 var flagMarkerLayer: FlagMarkerLayer { layer as! FlagMarkerLayer }
 
 init(frame: CGRect = .zero, markerColor: UIColor = .clear, animation:  FlagChangeAnimation = .randomAll())
 {
  self.animation = animation
  self.markerColor = .clear
  
  super.init(frame: frame)
  
  flagMarkerLayer.markerColor = markerColor
  backgroundColor = UIColor.clear
  flagMarkerLayer.needsDisplayOnBoundsChange = true
  flagMarkerLayer.contentsScale = UIScreen.main.scale
 }
 
 required init?(coder aDecoder: NSCoder)
 {
  animation = .transition()
  markerColor = .clear
  
  super.init(coder: aDecoder)
  
  flagMarkerLayer.markerColor = .clear
  flagMarkerLayer.needsDisplayOnBoundsChange = true
  flagMarkerLayer.contentsScale = UIScreen.main.scale
 }
 
 override func draw(_ rect: CGRect) {}
}

