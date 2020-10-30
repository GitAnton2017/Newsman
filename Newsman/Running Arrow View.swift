//
//  Running Arrow View.swift
//  Newsman
//
//  Created by Anton2016 on 27.05.2020.
//  Copyright © 2020 Anton2016. All rights reserved.
//

import UIKit
import Combine

final class RunningArrowView: UIView
{
 
 private final var drawTimerSubscription: AnyCancellable?
 private final var runningArrowNumber = -1
 
 var isRunning = true
 {
  didSet
  {
   switch (oldValue, isRunning)
   {
    case (true, false):
     drawTimerSubscription?.cancel()
     drawTimerSubscription = nil
     runningArrowNumber = -1
    case (false, true): configueDrawTimer()
    default: break
   }
  }
 }
 
 private final var h: CGFloat { bounds.width / (2 * tan(arrowSharpness / 2 )) }
 private final var N: Int
 {
  Int((bounds.height + arrowPhase - h) / (arrowWidth + arrowPhase))
 }

 private final let arrowColor: UIColor
 private final let arrowWidth: CGFloat
 private final let arrowPhase: CGFloat
 private final let arrowSharpness: CGFloat
 
 private final func drawRunningArrows()
 {
  let N = self.N
  let dA = 1.5 / CGFloat(N)
  
  for i in 0..<N
  {
   let dh = (arrowWidth + arrowPhase) * CGFloat(i)
   let p1 = CGPoint(x: 0, y: h + dh)
   let p2 = CGPoint(x: bounds.width / 2, y: dh)
   let p3 = CGPoint(x: bounds.width , y: h + dh)
   let p4 = CGPoint(x: bounds.width, y: h + dh + arrowWidth )
   let p5 = CGPoint(x: bounds.width / 2 , y: dh + arrowWidth)
   let p6 = CGPoint(x: 0, y: h + dh + arrowWidth)
   let path = UIBezierPath(points: [p1, p2 ,p3, p4, p5, p6])
   arrowColor.withAlphaComponent(1 - CGFloat(abs(i - runningArrowNumber)) * dA).setFill()
   //if i == count { arrowColor.setFill() } else { UIColor.clear.setFill() }
   path.fill()
  }
 }
 
 init(arrowColor: UIColor, arrowWidth: CGFloat, arrowPhase: CGFloat, arrowSharpness: CGFloat)
 {
  self.arrowColor = arrowColor
  self.arrowWidth = arrowWidth
  self.arrowPhase = arrowPhase
  self.arrowSharpness = arrowSharpness
  
  super.init(frame: .zero)
 }
 
 
 override func layoutSubviews()
 {
  super.layoutSubviews()
  guard bounds != .zero else { return }
  runningArrowNumber = -1
  configueDrawTimer()
 }
 
 
 private final func configueDrawTimer()
 {
  let N = self.N
  drawTimerSubscription = Timer.publish(every: 1.0 / TimeInterval(N), on: .main, in: .common)
   .autoconnect()
   .sink { [ unowned self ] _ in
     if self.runningArrowNumber > 0 { self.runningArrowNumber -= 1 }
     else
     {
      self.runningArrowNumber = N
     }
    
     self.setNeedsDisplay()
   }
 }
 
 required init?(coder: NSCoder) {
  fatalError("init(coder:) has not been implemented")
 }
 
 
 override func draw(_ rect: CGRect)
 {
  if ( runningArrowNumber == -1 )
  {
   runningArrowNumber = N - 1
  }
  drawRunningArrows()
 }
 
}

