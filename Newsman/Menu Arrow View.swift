//
//  Menu Arrow View.swift
//  Newsman
//
//  Created by Anton2016 on 08.10.2019.
//  Copyright © 2019 Anton2016. All rights reserved.
//

import UIKit

class MenuArrowView: UIView
{
 weak var boundingSuperView: UIView?
 
 var fillColor: UIColor
 var sharpnessRatio: CGFloat

 unowned var baseView: MenuBaseView!
 
 init(frame: CGRect = .zero,
      bounder: UIView?,
      fillColor: UIColor,
      sharpnessRatio: CGFloat = 1/5 /* from the baseView bounds */)
 {
  self.fillColor = fillColor
  self.sharpnessRatio = sharpnessRatio
  self.boundingSuperView = bounder
  
  super.init(frame: frame)
  
  setupArrowView()
  
 }
 
 private func setupArrowView()
 {
  backgroundColor = .clear
 }
 
 override func draw(_ rect: CGRect)
 {
  let h = bounds.height
  let w = bounds.width

  let x0 = center.x
  let y0 = center.y
  
  let c = baseView.center
  let xr = c.x
  let yr = c.y
  
  let R = min(baseView.bounds.height, baseView.bounds.width) * sharpnessRatio
  let r = sqrt((xr - x0) * (xr - x0) + (yr - y0) * (yr - y0))
  let t = R / r // 2 * tan( sharpAngle / 2 )
  let p1 = CGPoint(x: w / 2, y: h / 2)
  let p2 = CGPoint(x: xr + t * (yr - y0), y: yr - t * (xr - x0))
  let p3 = CGPoint(x: xr - t * (yr - y0), y: yr + t * (xr - x0))
  
  let arrowPath = UIBezierPath(points: [p1, p2, p3])
  
  fillColor.setFill()
  arrowPath.fill()
 }
 

 
 required init?(coder: NSCoder)
 {
  fatalError("init(coder:) has not been implemented")
 }
 
}
