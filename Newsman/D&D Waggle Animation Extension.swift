//
//  Photo D&D Cell Waggle Animation.swift
//  Newsman
//
//  Created by Anton2016 on 10/01/2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

extension DragWaggleAnimatable
{
 func startWaggleAnimation()
 {
  //print (#function)
  
  var slt = CATransform3DIdentity
  slt.m34 = -1.0/600
  self.waggleView.layer.superlayer!.sublayerTransform = slt
  
  let ag = CAAnimationGroup()
  
  let bc = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
  bc.fromValue = UIColor.brown.cgColor
  bc.toValue = UIColor.red.cgColor
  
  let bw = CABasicAnimation(keyPath: #keyPath(CALayer.borderWidth))
  bw.fromValue = 0.5
  bw.toValue = 1.25
  
  let kft = CAKeyframeAnimation(keyPath: #keyPath(CALayer.transform))
  kft.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
  kft.values =
   [
    CATransform3DMakeScale(0.98, 0.98, 1),
    CATransform3DMakeRotation( .pi/15, 1, 1, 0),  CATransform3DMakeRotation(-.pi/15, 1, 1, 0),
    CATransform3DMakeRotation( .pi/15, -1, 1, 0), CATransform3DMakeRotation(-.pi/15, -1, 1, 0),
    CATransform3DMakeRotation( .pi/90, 0, 0, 1),  CATransform3DMakeRotation(-.pi/90, 0, 0, 1),
    CATransform3DMakeScale(1.02, 1.02, 1)
  ]
  
  kft.calculationMode = kCAAnimationCubic
  kft.rotationMode = kCAAnimationRotateAuto
  
  ag.duration = 0.35
  ag.autoreverses = true
  ag.repeatCount = .infinity
  
  ag.animations = [bc, bw, kft]
  
  self.waggleView.layer.add(ag, forKey: "waggle")
 }
 
 func stopWaggleAnimation()
 {
  //print (#function)
  self.waggleView.layer.removeAnimation(forKey: "waggle")
 }
 
 var isDragAnimating: Bool
 {
  get {return self.waggleView.layer.animation(forKey: "waggle") != nil}
  set
  {
   if newValue {dragWaggleBegin()} else {dragWaggleEnd()}
  }
 }
 
 func dragWaggleBegin()
 {
  //print (#function)
  startWaggleAnimation()
 }
 
 func dragWaggleEnd()
 {
  //print (#function)
  stopWaggleAnimation()
 }
 
}
